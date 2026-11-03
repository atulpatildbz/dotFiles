// Floating recording pill, modelled on superwhisper's mini recorder.
//
// Values marked [sw] were read out of superwhisper 3.1.0's binary (WaveformNSView /
// WaveformView / AuroraView); everything else is a design choice.
//
//   recording     dark blurred capsule, white bars driven by the mic level
//   transcribing  bars roll as a sine wave, a colour glow orbits the pill border
//   finish        glow blooms outward and the pill fades away
//
// All methods except feed(rms:) must be called on the main thread.

import AppKit
import Metal
import QuartzCore

final class Pill {
    static let shared = Pill()

    // Geometry (points).
    private let barCount = 9                 // ≤ 9 uses superwhisper's flat envelope [sw]
    private let barWidth: CGFloat = 2        // [sw]
    private let barPitch: CGFloat = 4        // [sw]
    private let barMaxHeight: CGFloat = 16
    private let pillSize = CGSize(width: 64, height: 28)
    private let margin: CGFloat = 34         // transparent room around the pill for the glow
    private let bottomInset: CGFloat = 14    // gap between the pill and the dock / screen edge

    private enum Phase { case hidden, recording, transcribing, finishing }
    private var phase = Phase.hidden

    private var panel: NSPanel?
    private var barsLayer = CALayer()
    private var bars: [CAShapeLayer] = []
    private var glow: GlowView?
    private var timer: Timer?
    private var frame = 0
    private var visibleBars = 0
    private var samples: [Double] = []
    private var sinePhase = 0.0
    private var glowStart = 0.0
    private var finishStart = 0.0
    private var envelope = 0.0
    private var peakLevel = 0.5

    private let levelLock = NSLock()
    private var pendingRMS: Float = 0

    // MARK: Public API

    /// Audio thread: report the RMS of the latest buffer.
    func feed(rms: Float) {
        levelLock.lock(); pendingRMS = max(pendingRMS, rms); levelLock.unlock()
    }

    func showRecording() {
        build()
        guard let panel else { return }
        phase = .recording
        samples = Array(repeating: 0, count: barCount)
        envelope = 0; peakLevel = 0.5
        visibleBars = 1
        glow?.isHidden = true
        position(panel)
        layoutBars(animated: false)
        bars.forEach { $0.opacity = 0.3 }    // initial dot opacity [sw]

        // Entrance: bars un-blur and scale up while the pill fades in.
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            panel.animator().alphaValue = 1
        }
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.6; scale.toValue = 1
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0; fade.toValue = 1
        let blur = CABasicAnimation(keyPath: "filters.blur.inputRadius")
        blur.fromValue = 4; blur.toValue = 0
        let group = CAAnimationGroup()
        group.animations = [scale, fade, blur]
        group.duration = 0.28
        group.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.9, 0.3, 1.0)
        barsLayer.add(group, forKey: "entrance")
        startTimer()
    }

    func showTranscribing() {
        guard phase == .recording else { return }
        phase = .transcribing
        visibleBars = barCount
        sinePhase = 0
        glowStart = CACurrentMediaTime()
        glow?.isHidden = false
        glow?.alphaValue = 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.25
            glow?.animator().alphaValue = 1
        }
    }

    /// Transcription finished: bloom the glow, then fade out.
    func finish() {
        guard phase == .transcribing else { return hide() }
        phase = .finishing
        finishStart = CACurrentMediaTime()
        for bar in bars { bar.opacity = 0 }
    }

    func hide() {
        guard phase != .hidden, let panel else { return }
        phase = .hidden
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self, self.phase == .hidden else { return }
            panel.orderOut(nil)
            self.timer?.invalidate(); self.timer = nil
        })
    }

    // MARK: Construction

    private func build() {
        guard panel == nil else { return }
        let size = CGSize(width: pillSize.width + 2 * margin, height: pillSize.height + 2 * margin)
        let panel = NSPanel(contentRect: CGRect(origin: .zero, size: size),
                            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        let root = NSView(frame: CGRect(origin: .zero, size: size))
        root.wantsLayer = true
        panel.contentView = root
        let pillRect = CGRect(x: margin, y: margin, width: pillSize.width, height: pillSize.height)
        let radius = pillSize.height / 2

        // Soft drop shadow under the capsule.
        let shadow = hostingView(pillRect)
        shadow.layer!.shadowPath = CGPath(roundedRect: shadow.bounds, cornerWidth: radius, cornerHeight: radius, transform: nil)
        shadow.layer!.shadowColor = NSColor.black.cgColor
        shadow.layer!.shadowOpacity = 0.35
        shadow.layer!.shadowRadius = 8
        shadow.layer!.shadowOffset = CGSize(width: 0, height: -2)
        root.addSubview(shadow)

        // Blurred capsule (superwhisper: DynamicRoundedCornerView = rounded NSVisualEffectView [sw]).
        let blur = NSVisualEffectView(frame: pillRect)
        blur.material = .hudWindow
        blur.blendingMode = .behindWindow
        blur.state = .active
        blur.appearance = NSAppearance(named: .darkAqua)
        blur.maskImage = Pill.capsuleMask(pillSize)
        root.addSubview(blur)

        // Darkening tint + hairline border.
        let tint = hostingView(pillRect)
        tint.layer!.backgroundColor = NSColor(white: 0.02, alpha: 0.62).cgColor
        tint.layer!.cornerRadius = radius
        tint.layer!.borderWidth = 0.5
        tint.layer!.borderColor = NSColor(white: 1, alpha: 0.14).cgColor
        root.addSubview(tint)

        // Waveform bars.
        let barsView = hostingView(pillRect)
        barsView.layerUsesCoreImageFilters = true
        barsLayer.frame = barsView.bounds
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.name = "blur"
        blurFilter.setValue(0, forKey: kCIInputRadiusKey)
        barsLayer.filters = [blurFilter]
        barsView.layer!.addSublayer(barsLayer)
        root.addSubview(barsView)

        // Path / opacity changes animate implicitly over 0.15 s [sw].
        let barAnim = CABasicAnimation()
        barAnim.duration = 0.15
        for _ in 0..<barCount {
            let bar = CAShapeLayer()
            bar.fillColor = NSColor.white.cgColor
            bar.actions = ["path": barAnim, "opacity": barAnim, "position": NSNull(), "bounds": NSNull()]
            barsLayer.addSublayer(bar)
            bars.append(bar)
        }

        // Processing glow, drawn over everything so the rim sits on the border.
        if let glow = GlowView(frame: root.bounds, pillRect: pillRect) {
            glow.isHidden = true
            root.addSubview(glow)
            self.glow = glow
        }
        self.panel = panel
    }

    private func hostingView(_ rect: CGRect) -> NSView {
        let v = NSView(frame: rect)
        v.layer = CALayer()
        v.wantsLayer = true
        return v
    }

    private static func capsuleMask(_ size: CGSize) -> NSImage {
        let r = size.height / 2
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect, xRadius: r, yRadius: r).fill()
            return true
        }
        image.capInsets = NSEdgeInsets(top: r, left: r, bottom: r, right: r)
        image.resizingMode = .stretch
        return image
    }

    /// Bottom-centre of the screen under the mouse (superwhisper's default snap point).
    private func position(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let vf = screen?.visibleFrame else { return }
        panel.setFrameOrigin(CGPoint(x: (vf.midX - panel.frame.width / 2).rounded(),
                                     y: vf.minY + bottomInset - margin))
        if let scale = screen?.backingScaleFactor { glow?.setScale(scale) }
    }

    // MARK: Animation loop

    private func startTimer() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        frame += 1
        let now = CACurrentMediaTime()
        switch phase {
        case .hidden:
            return
        case .recording:
            if visibleBars < barCount, frame % 2 == 0 { visibleBars += 1 }   // bars count in [sw]
            if frame % 3 == 0 { pushLevel(); layoutBars(animated: true) }
        case .transcribing:
            if frame % 5 == 0 { rollSine(); layoutBars(animated: true) }
            glow?.render(time: now - glowStart, completion: 0)
        case .finishing:
            let c = min((now - finishStart) / 0.6, 1)
            glow?.render(time: now - glowStart, completion: Float(c))
            if c >= 1 { hide() }
        }
    }

    /// Mic level -> bar sample. Newest level sits in the centre and flows outward.
    private func pushLevel() {
        levelLock.lock(); let rms = Double(pendingRMS); pendingRMS = 0; levelLock.unlock()
        let db = 20 * log10(max(rms, 1e-7))
        var level = min(max((db + 52) / 40, 0), 1)          // ~-52 dBFS floor .. -12 dBFS full
        peakLevel = max(level, peakLevel * 0.985, 0.45)      // slow adaptive gain
        level = min(level / peakLevel, 1)
        if level < 0.12 { level = 0 }                        // noise gate
        envelope = level > envelope ? level : envelope * 0.7 + level * 0.3
        let s = envelope * Double(barMaxHeight) * 1.15

        // samples[k] = level k ticks ago; bars mirror it out from the middle.
        samples.insert(s, at: 0)
        samples.removeLast()
    }

    /// Transcribing: a sine wave rolls through the bars [sw].
    private func rollSine() {
        let n = Double(barCount)
        let step = barCount < 11 ? Double.pi / n : 4 * Double.pi / n
        sinePhase += Double.pi / 4
        if sinePhase >= 2 * Double.pi { sinePhase -= 2 * Double.pi }
        samples = (0..<barCount).map { 5 + 10 * sin(Double($0) * step + sinePhase) }
    }

    private func layoutBars(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        let w = barsLayer.bounds.width, h = barsLayer.bounds.height
        let n = phase == .recording ? visibleBars : barCount
        let maxH = Double(barMaxHeight)
        for (i, bar) in bars.enumerated() {
            guard i < n else { bar.opacity = 0; continue }
            let s: Double
            if phase == .recording {
                let k = Int(abs(Double(i) - Double(n - 1) / 2).rounded())
                s = samples[min(k, samples.count - 1)]
            } else {
                s = samples[i]
            }
            // Height model [sw]: dots below 3, otherwise 0.8·max·tanh(s/max) shaped by an envelope.
            let env = barCount <= 9
                ? sin((Double(i) + 0.5) * Double.pi / Double(barCount)) * 0.4 + 0.6
                : sin(Double.pi / Double(barCount) * (Double(i) + 0.5))
            var bh = 2.0
            if s >= 3 {
                let v = 0.8 * maxH * tanh(s / maxH)
                bh = min(max(v < 2 ? 2 * env : env * v, 2), maxH)
            }
            let x = w / 2 - CGFloat(n) * 0.5 * barPitch + CGFloat(i) * barPitch + (barPitch - barWidth) / 2
            let rect = CGRect(x: x, y: h / 2 - bh / 2, width: barWidth, height: bh)
            bar.path = CGPath(roundedRect: rect, cornerWidth: 1, cornerHeight: 1, transform: nil)
            bar.opacity = 1
        }
        CATransaction.commit()
    }
}

// MARK: - Metal glow

private struct GlowUniforms {
    var resolution: SIMD2<Float>
    var time: Float
    var completion: Float
    var center: SIMD2<Float>
    var halfSize: SIMD2<Float>
    var corner: Float
    var alpha: Float
    var inner: SIMD3<Float>
    var mid: SIMD3<Float>
    var outer: SIMD3<Float>
}

private final class GlowView: NSView {
    private let metalLayer = CAMetalLayer()
    private let queue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState
    private let pillRect: CGRect
    private var scale: CGFloat = 2

    init?(frame: CGRect, pillRect: CGRect) {
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else { return nil }
        do {
            let lib = try device.makeLibrary(source: glowShader, options: nil)
            let desc = MTLRenderPipelineDescriptor()
            desc.vertexFunction = lib.makeFunction(name: "glow_vertex")
            desc.fragmentFunction = lib.makeFunction(name: "glow_fragment")
            desc.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipeline = try device.makeRenderPipelineState(descriptor: desc)
        } catch {
            FileHandle.standardError.write("[pill] glow shader: \(error)\n".data(using: .utf8)!)
            return nil
        }
        self.queue = queue
        self.pillRect = pillRect
        super.init(frame: frame)
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.isOpaque = false
        metalLayer.framebufferOnly = true
        layer = metalLayer
        wantsLayer = true
        setScale(2)
    }

    required init?(coder: NSCoder) { nil }

    func setScale(_ s: CGFloat) {
        scale = s
        metalLayer.contentsScale = s
        metalLayer.drawableSize = CGSize(width: bounds.width * s, height: bounds.height * s)
    }

    func render(time: Double, completion: Float) {
        guard !isHidden, let drawable = metalLayer.nextDrawable(),
              let buffer = queue.makeCommandBuffer() else { return }
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = drawable.texture
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        pass.colorAttachments[0].storeAction = .store
        let s = Float(scale)
        var u = GlowUniforms(
            resolution: SIMD2(Float(bounds.width) * s, Float(bounds.height) * s),
            time: Float(time), completion: completion,
            center: SIMD2(Float(pillRect.midX) * s, Float(pillRect.midY) * s),
            halfSize: SIMD2(Float(pillRect.width / 2) * s, Float(pillRect.height / 2) * s),
            corner: Float(pillRect.height / 2) * s, alpha: 1,
            inner: SIMD3(0.62, 0.42, 1.00),   // violet
            mid: SIMD3(0.30, 0.62, 1.00),     // sky blue
            outer: SIMD3(1.00, 0.45, 0.75))   // pink
        guard let enc = buffer.makeRenderCommandEncoder(descriptor: pass) else { return }
        enc.setRenderPipelineState(pipeline)
        enc.setFragmentBytes(&u, length: MemoryLayout<GlowUniforms>.stride, index: 0)
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        enc.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
}

// Border glow in the style of superwhisper's aurora_border_fragment: an fbm-noise halo
// hugging the capsule plus a light that orbits its perimeter; `completion` 0→1 blooms the
// halo outward and fades it out.
private let glowShader = """
#include <metal_stdlib>
using namespace metal;

struct VOut { float4 position [[position]]; float2 uv; };

vertex VOut glow_vertex(uint vid [[vertex_id]]) {
    float2 uv = float2((vid << 1) & 2, vid & 2);
    VOut o;
    o.position = float4(uv * 2.0 - 1.0, 0.0, 1.0);
    o.uv = uv;
    return o;
}

struct U {
    float2 resolution; float time; float completion;
    float2 center; float2 halfSize;
    float corner; float alpha;
    float3 inner; float3 mid; float3 outer;
};

static float hash21(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

static float vnoise(float2 p) {
    float2 i = floor(p), f = fract(p);
    float2 w = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash21(i), hash21(i + float2(1, 0)), w.x),
               mix(hash21(i + float2(0, 1)), hash21(i + float2(1, 1)), w.x), w.y);
}

static float fbm(float2 p) {
    float v = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) { v += a * vnoise(p); p = p * 2.02 + float2(13.1, 7.3); a *= 0.5; }
    return v;
}

// Point on the capsule outline, `d` px along its perimeter.
static float2 perimeter(float d, float2 h) {
    float r = h.y, straight = max(0.0, 2.0 * (h.x - r)), arc = M_PI_F * r;
    d = fmod(d, 2.0 * straight + 2.0 * arc);
    if (d < straight) return float2(-straight * 0.5 + d, r);
    if ((d -= straight) < arc) { float a = M_PI_F * 0.5 - d / r; return float2(straight * 0.5, 0) + r * float2(cos(a), sin(a)); }
    if ((d -= arc) < straight) return float2(straight * 0.5 - d, -r);
    d -= straight;
    float a = -M_PI_F * 0.5 - d / r;
    return float2(-straight * 0.5, 0) + r * float2(cos(a), sin(a));
}

fragment half4 glow_fragment(VOut in [[stage_in]], constant U& u [[buffer(0)]]) {
    float2 pos = in.uv * u.resolution;
    float H = u.halfSize.y * 2.0;
    float2 uv = pos / H;
    float t = u.time;

    float2 q = float2(fbm(uv * 1.3 + float2(0.0, t * 0.35)), fbm(uv * 1.3 + float2(4.7, -t * 0.42)));
    float n = smoothstep(0.3, 0.8, fbm(uv * 1.3 + 1.6 * q + float2(t * 0.2, 0.0)));

    float2 d2 = abs(pos - u.center) - u.halfSize + u.corner;
    float sdf = length(max(d2, float2(0.0))) + min(max(d2.x, d2.y), 0.0) - u.corner;

    float bloom = smoothstep(0.0, 0.55, u.completion);
    float reach = H * mix(0.75, 1.75, bloom);
    float outside = smoothstep(0.0, 1.5, sdf);
    float halo = 1.0 - smoothstep(0.0, reach, max(sdf, 0.0));
    float aHalo = n * halo * halo * outside * mix(0.75, 0.95, bloom);

    float wob = (fbm(uv * 2.0 + 0.6 * q + float2(t * 0.2, 5.0)) - 0.5) * reach * 0.6;
    float d01 = clamp((sdf + wob) / reach, 0.0, 1.0);
    float3 pal = mix(u.inner, u.mid, smoothstep(0.0, 0.5, d01));
    pal = mix(pal, u.outer, smoothstep(0.5, 1.0, d01));

    float per = 2.0 * max(0.0, 2.0 * (u.halfSize.x - u.halfSize.y)) + 2.0 * M_PI_F * u.halfSize.y;
    float along = fract(t / 2.4) * per;
    float spot = exp(-pow(length(pos - u.center - perimeter(along, u.halfSize)) / (H * 0.85), 2.0))
               + 0.6 * exp(-pow(length(pos - u.center - perimeter(along + per * 0.5, u.halfSize)) / (H * 0.7), 2.0));
    float rim = exp(-pow(sdf / max(fwidth(sdf) * 1.2, 1.0), 2.0));
    float wash = exp(-abs(sdf) / (H * 0.18)) * 0.25 * outside;
    float phase = 0.5 + 0.5 * sin(t * 1.6 + n * 3.0);
    float3 rimRGB = mix(u.inner, u.mid, phase);
    float aRim = clamp(spot * (rim + wash) * (0.75 + 0.25 * n), 0.0, 1.0) * (1.0 - bloom);

    float fade = 1.0 - smoothstep(0.6, 1.0, u.completion);
    float a = clamp((aHalo + aRim) * fade * u.alpha, 0.0, 1.0);
    float3 rgb = min((pal * aHalo + rimRGB * aRim) * fade * u.alpha, float3(a));
    float dither = (hash21(pos + fract(t) * 61.7) - 0.5) / 255.0;
    return half4(half3(rgb + dither * a), half(a));
}
"""
