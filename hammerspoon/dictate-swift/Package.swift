// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "dictated",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/soniqo/speech-swift", exact: "0.0.28"),
    ],
    targets: [
        .executableTarget(
            name: "dictated",
            dependencies: [
                .product(name: "AudioCommon", package: "speech-swift"),
                .product(name: "CohereTranscribeASR", package: "speech-swift"),
                .product(name: "ParakeetASR", package: "speech-swift"),
                .product(name: "WhisperASR", package: "speech-swift"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
