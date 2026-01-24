#!/bin/bash

# Generate Android app signing keystore
# This script creates a keystore for Android app signing

set -e

echo "🔐 Android Keystore Generator"
echo ""

# Default values
KEYSTORE_NAME="upload-keystore.jks"
KEYSTORE_ALIAS="upload"
KEYSTORE_PATH="$HOME/$KEYSTORE_NAME"
VALIDITY_DAYS=10000

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
  echo "❌ keytool not found. Please install Java JDK."
  echo "   macOS: brew install openjdk"
  echo "   Ubuntu: sudo apt-get install openjdk-11-jdk"
  exit 1
fi

# Check if keystore already exists
if [ -f "$KEYSTORE_PATH" ]; then
  echo -e "${YELLOW}⚠️  Keystore already exists at: $KEYSTORE_PATH${NC}"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
  rm "$KEYSTORE_PATH"
fi

echo "This will generate a new keystore for Android app signing."
echo ""
echo "Keystore details:"
echo "  Path: $KEYSTORE_PATH"
echo "  Alias: $KEYSTORE_ALIAS"
echo "  Validity: $VALIDITY_DAYS days (~27 years)"
echo ""

# Prompt for information
read -p "Enter your name or organization name: " NAME
read -p "Enter your organizational unit (e.g., Development): " ORG_UNIT
read -p "Enter your organization name: " ORG_NAME
read -p "Enter your city: " CITY
read -p "Enter your state/province: " STATE
read -p "Enter your country code (2 letters, e.g., US, IN): " COUNTRY

echo ""
echo "Now you'll be prompted for passwords:"
echo "  1. Keystore password (protects the keystore file)"
echo "  2. Key password (protects the key, can be same as keystore)"
echo ""

# Generate keystore
keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$KEYSTORE_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity $VALIDITY_DAYS \
  -storepass:env KEYSTORE_PASS \
  -keypass:env KEY_PASS \
  -dname "CN=$NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY" \
  2>/dev/null || {
  # Fallback to interactive mode if environment variables don't work
  keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEYSTORE_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY_DAYS \
    -dname "CN=$NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"
}

if [ -f "$KEYSTORE_PATH" ]; then
  echo ""
  echo -e "${GREEN}✅ Keystore generated successfully!${NC}"
  echo ""
  echo "Keystore location: $KEYSTORE_PATH"
  echo ""
  echo "Next steps:"
  echo "1. Create android/key.properties with:"
  echo "   storePassword=your_keystore_password"
  echo "   keyPassword=your_key_password"
  echo "   keyAlias=$KEYSTORE_ALIAS"
  echo "   storeFile=$KEYSTORE_PATH"
  echo ""
  echo "2. Add android/key.properties to .gitignore (already done)"
  echo ""
  echo "3. Keep your keystore and passwords secure!"
  echo "   - Never commit keystore to git"
  - "   - Backup keystore securely"
  echo "   - Store passwords in password manager"
  echo ""
  echo "See ANDROID_SIGNING.md for more details."
else
  echo "❌ Failed to generate keystore"
  exit 1
fi

