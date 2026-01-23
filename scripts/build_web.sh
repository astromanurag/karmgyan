#!/bin/bash
# Build script for Flutter web that converts environment variables to --dart-define flags

set -e

# List of environment variables to pass to Flutter build
ENV_VARS=(
  "USE_MOCK_DATA"
  "USE_MOCK_AUTH"
  "BACKEND_URL"
  "SUPABASE_URL"
  "SUPABASE_PUBLISHABLE_KEY"
  "SUPABASE_ANON_KEY"
  "SUPABASE_SECRET_KEY"
  "RAZORPAY_KEY_ID"
  "AGORA_APP_ID"
  "AGORA_APP_CERTIFICATE"
  "GOOGLE_PLACES_API_KEY"
  "GOOGLE_OAUTH_CLIENT_ID_WEB"
  "GOOGLE_OAUTH_CLIENT_ID_ANDROID"
  "GOOGLE_OAUTH_CLIENT_ID_IOS"
  "CASHFREE_APP_ID"
  "CASHFREE_SECRET_KEY"
  "CASHFREE_MODE"
  "CLERK_PUBLISHABLE_KEY"
  "CLERK_SECRET_KEY"
  "PERPLEXITY_API_KEY"
)

# Build the --dart-define arguments
DART_DEFINES=""

for var in "${ENV_VARS[@]}"; do
  # Check if the environment variable is set
  if [ -n "${!var}" ]; then
    # Get the value and properly quote it to handle special characters
    value="${!var}"
    # Add to dart-define flags (Flutter handles quoting internally)
    DART_DEFINES="$DART_DEFINES --dart-define=$var=$value"
  fi
done

# Build Flutter web app with dart-define flags
echo "Building Flutter web app..."
flutter build web --release --web-renderer canvaskit $DART_DEFINES

echo "Build completed successfully!"

