# Quick Start Guide - karmgyan App

## Running with Mock Data (No Database/Payment Required)

The app is configured to run with **mock data by default**, so you can start using it immediately without any setup!

### Steps:

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

That's it! The app will run with mock data.

### What Works in Mock Mode:

✅ **Authentication**: Login with any email/password (e.g., `test@test.com` / `password123`)
✅ **Services**: Browse all available services from mock data
✅ **Orders**: View sample orders
✅ **Reports**: See sample reports
✅ **All UI Screens**: Navigate through all features

⚠️ **Requires Backend Server** (even in mock mode):
- **Calendar/Panchang**: Needs backend Python server running
- **Compatibility Matching**: Needs backend Python server running
- **Birth Chart/Dasha**: Needs backend Python server running

These computation features use local Python libraries (pyswisseph) and don't depend on external APIs, but they still need the backend server to be running.

### Switching to Real Database/Payment:

When you're ready to use real Supabase and payment gateway:

1. Edit `lib/config/app_config.dart`:
   ```dart
   static const bool useMockData = false;  // Change to false
   ```

2. Configure Supabase in `lib/config/supabase_config.dart`

3. Set up backend and payment gateway (see `SETUP.md`)

### Mock Data Location:

All mock data files are in `assets/mock_data/`:
- `services.json` - Services catalog (used in mock mode)
- `orders.json` - Sample orders (used in mock mode)
- `reports.json` - Sample reports (used in mock mode)
- `client_profiles.json` - User profiles (used in mock mode)
- `panchang.json` - Reference only (not used - uses local computation)
- `compatibility_result.json` - Reference only (not used - uses local computation)

You can edit the JSON files to customize the mock data for database-dependent features!

**Note**: Panchang and matching computations always use the backend Python server, regardless of mock data flag.

## Enjoy Testing! 🚀

