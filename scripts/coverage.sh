#!/bin/sh
#
# Run the test suite with code coverage enabled and print a per-file summary
# for the Caffeinate app target.
#
# Usage: ./scripts/coverage.sh
#
set -e

# Use Xcode's toolchain explicitly (matches this repo's known xcodebuild quirk).
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

RESULT_BUNDLE="build/Coverage.xcresult"
rm -rf "$RESULT_BUNDLE"

xcodebuild test \
  -project Caffeinate.xcodeproj \
  -scheme Caffeinate \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  -resultBundlePath "$RESULT_BUNDLE"

echo ""
echo "===== Code coverage (Caffeinate.app target) ====="
xcrun xccov view --report --only-targets "$RESULT_BUNDLE"
echo ""
echo "===== Per-file coverage ====="
xcrun xccov view --report --files-for-target Caffeinate.app "$RESULT_BUNDLE"
