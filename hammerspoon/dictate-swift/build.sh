#!/bin/bash
# Rebuild the dictation helper into bin/. Needs `brew install speech` for the
# prebuilt MLX Metal shaders (no full Xcode required).
set -euo pipefail
cd "$(dirname "$0")"
swift build -c release --product dictated
mkdir -p bin
# Replace (not overwrite in place): rewriting a signed binary's inode gets it killed on launch.
rm -rf bin/dictated bin/swift-crypto_Crypto.bundle bin/swift-transformers_Hub.bundle
cp .build/release/dictated bin/
cp -R .build/release/swift-crypto_Crypto.bundle .build/release/swift-transformers_Hub.bundle bin/
cp "$(brew --prefix speech)/libexec/mlx.metallib" bin/
rm -rf .build
