# karmgyan Setup Guide

## Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Install from: https://flutter.dev/docs/get-started/install
   - Verify: `flutter doctor`

2. **Node.js** (18.x or higher)
   - Install from: https://nodejs.org/

3. **Python** (3.8 or higher)
   - Install from: https://www.python.org/downloads/

4. **Supabase Account**
   - Sign up at: https://supabase.com
   - Create a new project

5. **Razorpay Account** (for payments)
   - Sign up at: https://razorpay.com
   - Get API keys from dashboard

## Setup Steps

### 1. Flutter Frontend Setup

```bash
cd karmgyan
flutter pub get
```

### 2. Configure Supabase

1. Create a Supabase project
2. Copy your project URL and anon key
3. Update `lib/config/supabase_config.dart`:
   ```dart
   static const String url = 'YOUR_SUPABASE_URL';
   static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. Run the database schema:
   - Go to Supabase SQL Editor
   - Copy and run `database/schema.sql`

### 3. Backend Setup

```bash
cd backend
npm install
```

Install Python dependencies:
```bash
pip install -r requirements.txt
```

Create `.env` file:
```bash
cp .env.example .env
```

Update `.env` with your credentials:
```
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_supabase_service_key
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

Start the backend server:
```bash
npm run dev
```

### 4. Update Backend URL in Flutter

Update the base URLs in service files:
- `lib/services/payment_service.dart`
- `lib/services/computation_service.dart`
- `lib/services/matching_service.dart`
- `lib/services/panchang_service.dart`

Change `http://localhost:3000` to your actual backend URL.

### 5. Run the Application

```bash
flutter run
```

## Platform-Specific Setup

### iOS
```bash
cd ios
pod install
```

### Android
- Ensure Android SDK is installed
- No additional setup required

### Web
```bash
flutter run -d chrome
```

### Desktop
```bash
flutter run -d macos  # or windows, linux
```

## Features Overview

- ✅ Authentication (Login/Signup with role-based access)
- ✅ Client Profile Management
- ✅ Service Browsing and Ordering
- ✅ Payment Integration (Razorpay)
- ✅ Computation Engine (pyswisseph)
- ✅ Compatibility Matching
- ✅ Panchang & Calendar
- ✅ Consultations (Video/Voice/Chat)
- ✅ Reports Management
- ✅ Admin Dashboard
- ✅ Community Forum
- ✅ Magazine (Articles & Videos)
- ✅ Analytics Dashboard

## Troubleshooting

### Flutter Issues
- Run `flutter clean` and `flutter pub get`
- Check `flutter doctor` for missing dependencies

### Backend Issues
- Ensure Python 3.8+ is installed
- Check that pyswisseph is installed: `pip list | grep pyswisseph`
- Verify Node.js version: `node --version`

### Supabase Issues
- Verify your project URL and keys
- Check database tables are created
- Review Supabase logs for errors

## Next Steps

1. Customize the theme colors if needed
2. Add your branding assets
3. Configure push notifications (Firebase)
4. Set up production environment variables
5. Deploy backend to a hosting service
6. Configure domain and SSL certificates

## Support

For issues or questions, refer to the documentation or contact support.

