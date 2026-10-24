#!/usr/bin/env bash
# Run an xcodebuild action (build, test) against an iPhone simulator. The package is iOS only,
# so `swift build` and `swift test`, which target the host Mac, cannot build it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

device="$("$ROOT/scripts/simulator.sh")"

xcodebuild "$@" \
  -scheme platform-ui-swift \
  -destination "platform=iOS Simulator,id=$device" \
  -derivedDataPath .build/xcode \
  -quiet
