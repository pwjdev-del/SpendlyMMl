#!/bin/bash
set -e

# Strip extended attributes that cause codesign failures
find "$(dirname "$0")/Spendly" -type f \( -name "*.swift" -o -name "*.plist" -o -name "*.json" -o -name "*.ttf" -o -name "*.otf" -o -name "*.png" -o -name "*.pdf" \) -exec xattr -c {} \; 2>/dev/null || true
find "$(dirname "$0")/SpendlyCore/Sources" -type f -exec xattr -c {} \; 2>/dev/null || true

# Build for iPad Air simulator
cd "$(dirname "$0")"
xcodebuild \
  -project Spendly.xcodeproj \
  -scheme Spendly \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M4)' \
  -derivedDataPath /tmp/SpendlyBuild \
  clean build 2>&1 | tail -20

echo ""
echo "BUILD RESULT: $?"
