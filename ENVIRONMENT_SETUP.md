# Environment Configuration Guide

## Overview

karmgyan supports both **mock data mode** (for development) and **production API mode** (for live deployment). The app automatically switches between modes based on environment configuration.

## Configuration Methods

### Method 1: Environment Variables (Recommended for Production)

Set environment variables when building/running the app:

```bash
# Flutter run with environment variables
flutter run --dart-define=USE_MOCK_DATA=false \
           --dart-define=SUPABASE_URL=your_supabase_url \
           --dart-define=SUPABASE_ANON_KEY=your_key \
           --dart-define=RAZORPAY_KEY_ID=your_razorpay_key
```

### Method 2: Build Configuration Files

Create platform-specific configuration files:

**Android**: `android/app/build.gradle`
```gradle
android {
    defaultConfig {
        resValue "string", "supabase_url", project.findProperty("SUPABASE_URL") ?: ""
        resValue "string", "razorpay_key", project.findProperty("RAZORPAY_KEY_ID") ?: ""
    }
}
```

**iOS**: `ios/Runner/Info.plist`
```xml
<key>SupabaseURL</key>
<string>$(SUPABASE_URL)</string>
<key>RazorpayKey</key>
<string>$(RAZORPAY_KEY_ID)</string>
```

### Method 3: Code-Based Configuration (Current Implementation)

Edit `lib/config/env_config.dart` to set default values or load from package info.

## Environment Variables

### Required for Production

| Variable | Description | Example |
|----------|-------------|---------|
| `USE_MOCK_DATA` | Enable/disable mock data mode | `false` |
| `BACKEND_URL` | Backend API URL | `https://api.karmgyan.com` |
| `SUPABASE_URL` | Supabase project URL | `https://xxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | `eyJhbGc...` |
| `RAZORPAY_KEY_ID` | Razorpay API key | `rzp_test_xxx` |
| `AGORA_APP_ID` | Agora.io application ID | `your_app_id` |
| `AGORA_APP_CERTIFICATE` | Agora.io certificate | `your_certificate` |

## Mode Detection

The app automatically detects which mode to use:

```dart
// Mock mode if:
- USE_MOCK_DATA = true, OR
- Supabase credentials not configured, OR
- Razorpay credentials not configured

// Production mode if:
- USE_MOCK_DATA = false, AND
- All required credentials are configured
```

## Switching Modes

### Development (Mock Data)
```dart
// In env_config.dart or via environment variable
USE_MOCK_DATA=true
```

### Production (Real APIs)
```dart
USE_MOCK_DATA=false
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_key
RAZORPAY_KEY_ID=your_key
// ... other credentials
```

## Testing Both Modes

1. **Test with Mock Data**:
   - Set `USE_MOCK_DATA=true`
   - All features work with local data
   - No external API calls

2. **Test with Production APIs**:
   - Set `USE_MOCK_DATA=false`
   - Configure all API credentials
   - Test real integrations

## Fallback Behavior

The app gracefully falls back to mock data if:
- API credentials are missing
- Network connection fails
- API calls timeout or error

This ensures the app always works, even if external services are unavailable.

## Security Notes

⚠️ **Never commit `.env` files or API keys to version control!**

- Add `.env` to `.gitignore`
- Use environment variables in CI/CD
- Store secrets in secure vaults (AWS Secrets Manager, etc.)
- Use different keys for development and production

## Example Setup

### Development
```bash
# .env (local, not committed)
USE_MOCK_DATA=true
BACKEND_URL=http://localhost:3000
```

### Production
```bash
# Set via CI/CD or deployment platform
USE_MOCK_DATA=false
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
RAZORPAY_KEY_ID=rzp_live_xxx
AGORA_APP_ID=your_app_id
```

## Verification

Check which mode is active:

```dart
print('Mock mode: ${AppConfig.useMockData}');
print('Has Supabase: ${AppConfig.hasSupabaseConfig}');
print('Has Razorpay: ${AppConfig.hasRazorpayConfig}');
print('Has Agora: ${AppConfig.hasAgoraConfig}');
```

