#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

DERIVED_DATA="${DERIVED_DATA:-/tmp/TrafficGetawayVerifyDerivedData}"
DESTINATION="${DESTINATION:-generic/platform=iOS Simulator}"

echo "Traffic Getaway Mac verification"
echo "Project: $ROOT/Traffic Getaway.xcodeproj"
echo "Destination: $DESTINATION"

plutil -lint "Traffic Getaway.xcodeproj/project.pbxproj"
plutil -lint "Traffic Getaway/Info.plist"

SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
find "Traffic Getaway" -name "*.swift" -print0 \
  | xargs -0 xcrun swiftc -typecheck -sdk "$SDK" -target arm64-apple-ios17.0-simulator -swift-version 5

xcodebuild \
  -project "Traffic Getaway.xcodeproj" \
  -scheme "Traffic Getaway" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -jobs 1 \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build

echo "Traffic Getaway Mac verification complete."
