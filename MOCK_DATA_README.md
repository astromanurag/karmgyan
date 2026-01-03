# Mock Data Mode

The karmgyan app now supports a **mock data mode** that allows you to run the app without requiring:
- Database connection (Supabase)
- Payment gateway integration (Razorpay)
- Backend API server

## Configuration

To enable/disable mock data mode, edit `lib/config/app_config.dart`:

```dart
static const bool useMockData = true;  // Set to false for real database/payment
```

## How It Works

When `useMockData = true`:
- ✅ Database services use mock data from JSON files in `assets/mock_data/`
- ✅ Authentication accepts any credentials (mock user)
- ✅ Payments are simulated (no real transactions)
- ✅ Computation services (birth chart, dasha, panchang, matching) require backend (local Python computation)
- ✅ No Supabase initialization required

When `useMockData = false`:
- ✅ Uses real Supabase database
- ✅ Uses real payment gateway (Razorpay)
- ✅ Calls backend API for computations (same as mock mode - local computation)
- ✅ Full authentication flow

**Note**: 
- **Computation services** (birth chart, dasha, panchang, matching) always use local Python computation via backend API, regardless of mock data flag. These require the backend server to be running.
- **Mock data flag** only affects:
  - Database-dependent features (orders, reports, profiles, services) - uses Supabase when false
  - Payment gateway (Razorpay) - uses real payments when false
  - Authentication - uses Supabase Auth when false

## Mock Data Files

All mock data is stored in `assets/mock_data/`:

- `services.json` - Available services catalog (used when `useMockData = true`)
- `orders.json` - User orders (used when `useMockData = true`)
- `reports.json` - Generated reports (used when `useMockData = true`)
- `client_profiles.json` - User profiles (used when `useMockData = true`)
- `panchang.json` - **Not used** (panchang uses local computation)
- `compatibility_result.json` - **Not used** (matching uses local computation)

**Note**: Panchang and compatibility JSON files are kept for reference but are not used by the app. These services always use local Python computation via the backend API.

## Switching Between Modes

1. **To use mock data** (default):
   - Set `useMockData = true` in `app_config.dart`
   - Run `flutter pub get`
   - Run `flutter run`

2. **To use real database/payment**:
   - Set `useMockData = false` in `app_config.dart`
   - Configure Supabase credentials in `supabase_config.dart`
   - Configure Razorpay in backend `.env`
   - Start backend server
   - Run `flutter run`

## Benefits

- **Development**: Test UI and features without backend setup
- **Demo**: Show app functionality without infrastructure
- **Offline**: Work without internet connection
- **Testing**: Quick iteration on features

## Notes

- All existing database and payment code remains intact
- Simply toggle the flag to switch modes
- Mock data can be customized by editing JSON files
- Real implementations are preserved for production use

