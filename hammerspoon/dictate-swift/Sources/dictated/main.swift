// dictated: resident dictation helper for Hammerspoon.
//
// Same engines superwhisper uses for offline models: Cohere Transcribe on MLX (GPU),
// Parakeet / Whisper on CoreML. The model stays warm and the mic is recorded
// in-process, so a dictation costs only inference time.
//
// Line protocol on stdin, one JSON object per line on stdout:
//   load <model id>          load (downloading first if needed) and keep warm
//   download <model id>      download only
//   language <code|auto>
//   start [device uid]       empty = system default input
//   stop                     -> {"event":"text","text":...}
//   cancel
//   unload
//   file <wav>               transcribe a file (for testing)
//
// While recording / transcribing it shows a floating pill (Pill.swift).

import AppKit
import AVFoundation
import AudioCommon
import CohereTranscribeASR
import CoreAudio
import Foundation
import ParakeetASR
import WhisperASR

setvbuf(stdout, nil, _IOLBF, 0)

func emit(_ obj: [String: Any]) {
    guard let data = try? JSONSerialization.data(withJSONObject: obj),
          let line = String(data: data, encoding: .utf8) else { return }
    print(line)
}

func fail(_ message: String) { emit(["event": "error", "message": message]) }

func onMain(_ body: @escaping () -> Void) { DispatchQueue.main.async(execute: body) }

enum Engine { case cohere, parakeet, whisper }

func engine(for modelId: String) -> Engine? {
    let id = modelId.lowercased()
    if id.contains("cohere") { return .cohere }
    if id.contains("parakeet") { return .parakeet }
    if id.contains("whisper") { return .whisper }
    return nil
}

func loadModel(_ modelId: String, progress: @escaping (Double) -> Void) async throws -> SpeechRecognitionModel {
    switch engine(for: modelId) {
    case .cohere:
        return try await CohereTranscribeModel.load(modelId, progressHandler: progress)
    case .parakeet:
        let m = try await ParakeetASRModel.fromPretrained(modelId: modelId) { p, _ in progress(p) }
        try m.warmUp()
        return m
    case .whisper:
        return try await WhisperASRModel.fromPretrained(modelId: modelId) { p, _ in progress(p) }
    case nil:
        throw NSError(domain: "dictated", code: 1, userInfo: [NSLocalizedDescriptionKey: "unknown model \(modelId)"])
    }
}

// MARK: - Model state (serial queue so loads and transcriptions never overlap)

let modelQueue = DispatchQueue(label: "dictated.model")
var model: SpeechRecognitionModel?
var language: String?

func runBlocking(_ body: @escaping () async -> Void) {
    let done = DispatchSemaphore(value: 0)
    Task { await body(); done.signal() }
    done.wait()
}

func progressReporter(_ modelId: String) -> (Double) -> Void {
    var last = -1
    return { p in
        let pct = Int(p * 100)
        if pct != last { last = pct; emit(["event": "progress", "model": modelId, "percent": pct]) }
    }
}

func load(_ modelId: String) {
    modelQueue.async {
        model = nil
        let start = Date()
        runBlocking {
            do {
                let m = try await loadModel(modelId, progress: progressReporter(modelId))
                // Warm-up pass: the first inference pays one-off kernel/graph compilation.
                _ = m.transcribe(audio: [Float](repeating: 0, count: 16000), sampleRate: 16000, language: language)
                model = m
                emit(["event": "loaded", "model": modelId, "ms": Int(Date().timeIntervalSince(start) * 1000)])
            } catch {
                fail("load \(modelId): \(error.localizedDescription)")
            }
        }
    }
}

let downloadQueue = DispatchQueue(label: "dictated.download")

func download(_ modelId: String) {
    downloadQueue.async {
        runBlocking {
            do {
                _ = try await loadModel(modelId, progress: progressReporter(modelId))
                emit(["event": "downloaded", "model": modelId])
            } catch {
                fail("download \(modelId): \(error.localizedDescription)")
            }
        }
    }
}

func transcribe(_ samples: [Float], sampleRate: Int) {
    modelQueue.async {
        guard let m = model else { onMain { Pill.shared.hide() }; return fail("no model loaded") }
        let start = Date()
        let text = m.transcribe(audio: samples, sampleRate: sampleRate, language: language)
        emit([
            "event": "text",
            "text": text.trimmingCharacters(in: .whitespacesAndNewlines),
            "audio_s": Double(samples.count) / Double(sampleRate),
            "ms": Int(Date().timeIntervalSince(start) * 1000),
        ])
        onMain { Pill.shared.finish() }
    }
}

// MARK: - Recording

final class Recorder {
    private var engine: AVAudioEngine?
    private var samples: [Float] = []
    private let lock = NSLock()
    private(set) var sampleRate = 16000

    func start(deviceUID: String) throws {
        stop()
        let engine = AVAudioEngine()
        let input = engine.inputNode
        if !deviceUID.isEmpty, var id = Recorder.deviceID(uid: deviceUID), let unit = input.audioUnit {
            AudioUnitSetProperty(unit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0,
                                 &id, UInt32(MemoryLayout<AudioDeviceID>.size))
        }
        let format = input.outputFormat(forBus: 0)
        sampleRate = Int(format.sampleRate)
        lock.lock(); samples.removeAll(keepingCapacity: true); lock.unlock()
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let self, let data = buffer.floatChannelData else { return }
            let n = Int(buffer.frameLength), channels = Int(buffer.format.channelCount)
            var mono = [Float](repeating: 0, count: n)
            for c in 0..<channels {
                let ch = data[c]
                for i in 0..<n { mono[i] += ch[i] }
            }
            if channels > 1 { for i in 0..<n { mono[i] /= Float(channels) } }
            var energy: Float = 0
            for v in mono { energy += v * v }
            Pill.shared.feed(rms: n > 0 ? (energy / Float(n)).squareRoot() : 0)
            self.lock.lock(); self.samples.append(contentsOf: mono); self.lock.unlock()
        }
        engine.prepare()
        try engine.start()
        self.engine = engine
    }

    @discardableResult
    func stop() -> [Float] {
        guard let engine else { return [] }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        self.engine = nil
        lock.lock(); defer { lock.unlock() }
        return samples
    }

    static func deviceID(uid: String) -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyTranslateUIDToDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain)
        var cfUID = uid as CFString
        var id = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        let status = withUnsafeMutablePointer(to: &cfUID) { uidPtr in
            AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address,
                                       UInt32(MemoryLayout<CFString>.size), uidPtr, &size, &id)
        }
        return status == noErr && id != 0 ? id : nil
    }
}

// MARK: - Command loop

let recorder = Recorder()

// stdin commands run on a background thread; AppKit (the pill) owns the main thread.
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

Thread {
    emit(["event": "ready"])
    while let line = readLine() {
        let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        let cmd = parts.first.map(String.init) ?? ""
        let arg = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : ""
        switch cmd {
        case "load": load(arg)
        case "download": download(arg)
        case "language": modelQueue.async { language = (arg.isEmpty || arg == "auto") ? nil : arg }
        case "start":
            do {
                try recorder.start(deviceUID: arg)
                emit(["event": "recording"])
                onMain { Pill.shared.showRecording() }
            } catch {
                fail("record: \(error.localizedDescription)")
            }
        case "stop":
            let samples = recorder.stop()
            if samples.count < recorder.sampleRate / 4 {
                onMain { Pill.shared.hide() }
                emit(["event": "text", "text": ""])
            } else {
                onMain { Pill.shared.showTranscribing() }
                transcribe(samples, sampleRate: recorder.sampleRate)
            }
        case "cancel":
            recorder.stop()
            onMain { Pill.shared.hide() }
        case "unload": modelQueue.async { model = nil }
        case "file":
            do {
                let audio = try AudioFileLoader.load(url: URL(fileURLWithPath: arg), targetSampleRate: 16000)
                transcribe(audio, sampleRate: 16000)
            } catch {
                fail("read wav: \(error.localizedDescription)")
            }
        case "quit": exit(0)
        case "": break
        default: fail("unknown command \(cmd)")
        }
    }
    exit(0)   // stdin closed: Hammerspoon went away
}.start()

app.run()
