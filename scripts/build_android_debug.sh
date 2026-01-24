#!/bin/bash

# Build Android debug APK
# Usage: ./scripts/build_android_debug.sh

set -e

echo "🔨 Building Android Debug APK..."
echo ""

# Check if fvm is available
if ! command -v fvm &> /dev/null; then
  echo "❌ fvm not found. Install with: dart pub global activate fvm_cli"
  exit 1
fi

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Not a Flutter project. Run this script from the project root."
  exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
fvm flutter pub get

# Build debug APK
echo ""
echo "🔨 Building debug APK..."
fvm flutter build apk --debug

echo ""
echo "✅ Debug APK built successfully!"
echo ""
echo "Output: build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "Install on device:"
echo "  adb install build/app/outputs/flutter-apk/app-debug.apk"

