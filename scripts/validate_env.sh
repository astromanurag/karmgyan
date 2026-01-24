#!/bin/bash

# Environment variable validation script
# Checks that all required API keys are configured

set -e

echo "🔍 Validating environment variables..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Required variables
REQUIRED_VARS=(
  "SUPABASE_URL"
  "SUPABASE_PUBLISHABLE_KEY"
  "SUPABASE_SECRET_KEY"
  "CASHFREE_APP_ID"
  "CASHFREE_SECRET_KEY"
  "CASHFREE_MODE"
  "GOOGLE_OAUTH_CLIENT_ID_WEB"
  "GOOGLE_OAUTH_CLIENT_ID_ANDROID"
  "CLERK_PUBLISHABLE_KEY"
  "CLERK_SECRET_KEY"
  "PERPLEXITY_API_KEY"
  "AGORA_APP_ID"
  "AGORA_APP_CERTIFICATE"
  "BACKEND_URL"
)

# Optional variables
OPTIONAL_VARS=(
  "GOOGLE_OAUTH_CLIENT_ID_IOS"
)

# Check if .env file exists
if [ -f ".env" ]; then
  echo "📄 Loading .env file..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo -e "${YELLOW}⚠️  .env file not found. Checking environment variables...${NC}"
fi

# Track missing variables
MISSING_VARS=()
WARNINGS=()

# Validate required variables
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    MISSING_VARS+=("$var")
    echo -e "${RED}❌ Missing: $var${NC}"
  else
    # Basic format validation
    case $var in
      "SUPABASE_URL")
        if [[ ! "${!var}" =~ ^https://.*\.supabase\.co$ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: https://*.supabase.co)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "SUPABASE_PUBLISHABLE_KEY")
        if [[ ! "${!var}" =~ ^sb_publishable_ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: sb_publishable_...)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "SUPABASE_SECRET_KEY")
        if [[ ! "${!var}" =~ ^sb_secret_ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: sb_secret_...)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "CASHFREE_MODE")
        if [[ ! "${!var}" =~ ^(sandbox|production)$ ]]; then
          WARNINGS+=("$var must be 'sandbox' or 'production'")
          echo -e "${YELLOW}⚠️  $var must be 'sandbox' or 'production'${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "GOOGLE_OAUTH_CLIENT_ID_WEB"|"GOOGLE_OAUTH_CLIENT_ID_ANDROID"|"GOOGLE_OAUTH_CLIENT_ID_IOS")
        if [[ ! "${!var}" =~ \.apps\.googleusercontent\.com$ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: *.apps.googleusercontent.com)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "CLERK_PUBLISHABLE_KEY")
        if [[ ! "${!var}" =~ ^pk_(test|live)_ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: pk_test_... or pk_live_...)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "CLERK_SECRET_KEY")
        if [[ ! "${!var}" =~ ^sk_(test|live)_ ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: sk_test_... or sk_live_...)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "PERPLEXITY_API_KEY")
        if [[ ! "${!var}" =~ ^pplx- ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: pplx-...)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      "BACKEND_URL")
        if [[ ! "${!var}" =~ ^https?:// ]]; then
          WARNINGS+=("$var format may be incorrect")
          echo -e "${YELLOW}⚠️  $var format may be incorrect (expected: http:// or https://)${NC}"
        else
          echo -e "${GREEN}✅ $var${NC}"
        fi
        ;;
      *)
        echo -e "${GREEN}✅ $var${NC}"
        ;;
    esac
  fi
done

# Check optional variables
echo ""
echo "📋 Optional variables:"
for var in "${OPTIONAL_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo -e "${YELLOW}⚠️  Optional: $var (not set)${NC}"
  else
    echo -e "${GREEN}✅ $var${NC}"
  fi
done

# Summary
echo ""
if [ ${#MISSING_VARS[@]} -eq 0 ]; then
  if [ ${#WARNINGS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All required environment variables are set and valid!${NC}"
    exit 0
  else
    echo -e "${YELLOW}⚠️  All required variables are set, but some have format warnings.${NC}"
    exit 0
  fi
else
  echo -e "${RED}❌ Missing ${#MISSING_VARS[@]} required environment variable(s)${NC}"
  echo ""
  echo "Please set the following variables:"
  for var in "${MISSING_VARS[@]}"; do
    echo "  - $var"
  done
  echo ""
  echo "See KEYS_SETUP_GUIDE.md for setup instructions."
  exit 1
fi

