# Mock vs Live Backend Configuration

## Overview
The karmgyan app now supports **independent configuration** for authentication and backend services.

## Configuration Flags

### 1. `EnvConfig.useMockData`
Controls whether **astrological calculations** use mock data or real backend:
- `false` (default): Use real backend for charts, panchang, dasha, etc.
- `true`: Use mock/sample data (no backend needed)

### 2. `EnvConfig.useMockAuth`
Controls whether **authentication** uses mock data or real backend:
- `true` (default): Use mock authentication (any email/password works)
- `false`: Use real backend authentication (requires user database)

## Current Configuration (main.dart)

```dart
// Configuration:
// - Use REAL BACKEND for astrology calculations (charts, panchang, etc.)
// - Use MOCK AUTH for easy testing without backend authentication
EnvConfig.overrideMockData(false);  // false = real backend for astrology
EnvConfig.overrideMockAuth(true);   // true = mock auth (test@test.com works)
```

## Testing Credentials (Mock Auth Mode)

When `useMockAuth = true`, you can log in with:
- **Email**: test@test.com (or any email)
- **Password**: (any password)
- **Phone OTP**: 123456

## Backend Services Status

| Service | Status | Notes |
|---------|--------|-------|
| Birth Chart Calculation | ✅ Live Backend | Using Python compute_chart.py |
| Panchang (Calendar) | ✅ Live Backend | Real astronomical calculations |
| Dasha Calculation | ✅ Live Backend | Vimshottari Dasha system |
| Divisional Charts (Vargas) | ✅ Live Backend | D1-D60 charts |
| Authentication | 🎭 Mock Mode | test@test.com works |
| Payment Processing | 🎭 Mock Mode | No real charges |
| Video Consultations | 🎭 Mock Mode | Uses Agora mock |
| Chat | 🎭 Mock Mode | Local storage |

## Changing Configuration

### To enable real authentication:
```dart
EnvConfig.overrideMockAuth(false);
```
**Note**: Requires backend auth database setup with user records.

### To use all mock data (no backend needed):
```dart
EnvConfig.overrideMockData(true);
EnvConfig.overrideMockAuth(true);
```

## Backend Requirements

### For Astrology Features (Current Setup)
- **Node.js backend** running on `http://localhost:3000`
- **Python** with `swisseph` library for calculations
- **No database required** for astrological calculations

### For Authentication (Not Currently Setup)
- User database (MongoDB, PostgreSQL, etc.)
- JWT token generation
- Password hashing (bcrypt)
- Email verification service

## Verifying Backend Status

Check if the backend is running:
```bash
lsof -i :3000
```

Test panchang API directly:
```bash
curl "http://localhost:3000/api/panchang/daily?date=2026-01-01&timezone=Asia/Kolkata"
```

## Debug Output

The app logs its mode on startup:
```
🔧 App Mode: LIVE BACKEND
🔐 Auth Mode: MOCK AUTH
🌐 Backend URL: http://localhost:3000
```

## File Locations

- Configuration: `lib/config/env_config.dart`
- Main entry: `lib/main.dart`
- Auth service: `lib/services/auth_service.dart`
- Panchang service: `lib/services/panchang_service.dart`
- Backend server: `backend/server.js`
- Python calculations: `backend/python/compute_chart.py`

