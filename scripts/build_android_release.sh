#!/bin/bash

# Build Android release APK
# Usage: ./scripts/build_android_release.sh

set -e

echo "🔨 Building Android Release APK..."
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

# Check for signing configuration
if [ ! -f "android/key.properties" ]; then
  echo "⚠️  Warning: android/key.properties not found."
  echo "   Release builds should be signed. See ANDROID_SIGNING.md"
  read -p "Continue without signing? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted. Set up signing first."
    exit 1
  fi
fi

# Get dependencies
echo "📦 Getting dependencies..."
fvm flutter pub get

# Build release APK
echo ""
echo "🔨 Building release APK..."
fvm flutter build apk --release

echo ""
echo "✅ Release APK built successfully!"
echo ""
echo "Output: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Note: For Play Store, use build_android_bundle.sh to create an AAB file."

