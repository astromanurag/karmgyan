#!/bin/bash

# Build Android App Bundle (AAB) for Play Store
# Usage: ./scripts/build_android_bundle.sh

set -e

echo "📦 Building Android App Bundle (AAB) for Play Store..."
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
  echo "❌ Error: android/key.properties not found."
  echo ""
  echo "App bundles must be signed for Play Store upload."
  echo ""
  echo "To set up signing:"
  echo "1. Generate keystore: ./scripts/generate_keystore.sh"
  echo "2. Create android/key.properties (see ANDROID_SIGNING.md)"
  echo ""
  exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
fvm flutter pub get

# Build app bundle
echo ""
echo "📦 Building app bundle..."
fvm flutter build appbundle --release

echo ""
echo "✅ App Bundle built successfully!"
echo ""
echo "Output: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Next steps:"
echo "1. Go to Google Play Console"
echo "2. Navigate to Release → Production (or Testing)"
echo "3. Create new release"
echo "4. Upload: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "See PLAY_STORE_GUIDE.md for complete deployment instructions."

