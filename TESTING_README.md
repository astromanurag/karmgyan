# karmgyan App - Testing & Implementation Guide

## Overview

This document provides comprehensive testing instructions and implementation details for the karmgyan astrological platform. The app includes authentication, role-based access control, admin/consultant portals, chart generation, reports, predictions, and e-commerce features.

## Prerequisites

### Required Software
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Node.js (18+)
- Python (3.8+) with pyswisseph
- PostgreSQL (optional, for production)

### Required Packages
Run the following commands to install dependencies:

```bash
# Flutter dependencies
cd /Users/mgupta5/personal_projects/karmgyan
flutter pub get

# Backend dependencies
cd backend
npm install

# Python dependencies
pip install -r backend/requirements.txt
```

## Configuration

### 1. Backend Configuration

Create a `.env` file in the `backend/` directory:

```env
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
RAZORPAY_KEY_ID=your_razorpay_key
RAZORPAY_KEY_SECRET=your_razorpay_secret
```

**Note**: The app runs in MOCK MODE by default if these credentials are not set.

### 2. Flutter Configuration

Update `lib/config/app_config.dart`:

```dart
static const bool useMockData = true; // Set to false for production
static const String backendUrl = 'http://localhost:3000'; // Update for production
```

### 3. Google Sign-In Setup

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Sign-In API
3. Create OAuth 2.0 credentials
4. Add package name and SHA-1 fingerprint
5. Update `android/app/build.gradle` with your package name

## Running the Application

### Start Backend Server

```bash
cd backend
npm start
# or for development with auto-reload
npm run dev
```

The backend will run on `http://localhost:3000`

### Start Flutter App

```bash
# From project root
flutter run
```

For specific platforms:
```bash
flutter run -d chrome  # Web
flutter run -d macos   # macOS
flutter run -d ios     # iOS
flutter run -d android # Android
```

## Testing Guide

### 1. Authentication Testing

#### Email/Password Authentication

**Test Credentials (Mock Mode)**:
- Email: `test@karmgyan.com`
- Password: `Test@123`
- Any email/password combination works in mock mode

**Test Flow**:
1. Navigate to Login screen
2. Enter email and password
3. Click "Login"
4. Should redirect to home screen

**Sign Up Flow**:
1. Click "Sign up" on login screen
2. Fill in name, email, password, confirm password
3. Submit form
4. Should create account and log in

#### Phone OTP Authentication

**Test OTP**: `123456` (works for any phone number in mock mode)

**Test Flow**:
1. Navigate to "Sign in with Phone Number"
2. Enter phone number (e.g., `9876543210`)
3. Click "Send OTP"
4. Enter OTP: `123456`
5. Should verify and log in

#### Google Sign-In

**Mock Mode**: Automatically creates a Google user account

**Test Flow**:
1. Click "Sign in with Google"
2. In mock mode, automatically signs in
3. In production, opens Google sign-in flow

#### Forgot Password

**Test Reset Code**: `123456`

**Test Flow**:
1. Click "Forgot Password" on login screen
2. Enter email or phone
3. Enter reset code: `123456`
4. Enter new password
5. Should reset password successfully

### 2. Role-Based Access Testing

#### Admin Access

**Test Admin User**:
- Email: `admin@karmgyan.com`
- Password: `Admin@123`
- Role: `admin`

**Test Features**:
1. Login as admin
2. Should redirect to `/admin/dashboard`
3. Access consultant management
4. View analytics
5. Manage data uploads

#### Consultant Access

**Test Consultant User**:
- Email: `consultant@karmgyan.com`
- Password: `Consultant@123`
- Role: `consultant`

**Test Features**:
1. Login as consultant
2. Should redirect to `/consultant/dashboard`
3. View schedule
4. Check earnings
5. Manage consultations

#### Client Access

**Test Client User**:
- Email: `test@karmgyan.com`
- Password: `Test@123`
- Role: `client`

**Test Features**:
1. Login as client
2. Should redirect to `/home`
3. Generate birth charts
4. Book consultations
5. View reports

### 3. Chart Generation Testing

#### Birth Chart

**Test Flow**:
1. Navigate to "Birth Chart" from home
2. Enter birth details:
   - Name: `Test User`
   - Date: `15/05/1990`
   - Time: `10:30`
   - Latitude: `28.6139` (Delhi)
   - Longitude: `77.2090`
3. Click "Generate Chart"
4. Should display diamond chart with planets and houses

#### Divisional Charts

**Test Flow**:
1. Generate birth chart first (uses stored data)
2. Navigate to "Divisional Charts"
3. Click "Generate Divisional Charts"
4. Should display grid of all 16 divisional charts (D1-D16)

### 4. Reports Testing

**Test Flow**:
1. Navigate to "Reports" screen
2. Select a report type (e.g., "Birth Chart Report")
3. Click to view report details
4. Click "Generate Report"
5. Click "Download PDF" to export

### 5. Predictions Testing

#### Dasha Predictions

**Test Flow**:
1. Generate birth chart first
2. Navigate to "Dasha Predictions"
3. Should automatically load and display dasha periods
4. View timeline of planetary periods

#### Yearly Forecast

**Test Flow**:
1. Navigate to "Yearly Forecast"
2. View predictions for different life aspects
3. Check important dates

### 6. Kundli Milan Testing

**Test Flow**:
1. Navigate to "Kundli Milan" or "Matching"
2. Enter Person 1 details:
   - Date: `15/05/1990`
   - Time: `10:30`
   - Latitude: `28.6139`
   - Longitude: `77.2090`
3. Enter Person 2 details:
   - Date: `20/08/1992`
   - Time: `14:00`
   - Latitude: `28.6139`
   - Longitude: `77.2090`
4. Click "Compute Compatibility"
5. View 36-point Guna Milan results
6. Check Dosha analysis

### 7. Panchang & Muhurat Testing

#### Daily Panchang

**Test Flow**:
1. Navigate to "Calendar" screen
2. View daily panchang for selected date
3. Check Tithi, Nakshatra, Yoga, Karana

#### Muhurat Finder

**Test Flow**:
1. Navigate to "Muhurat Finder"
2. Select event type (Marriage, Business, etc.)
3. Select date
4. Click "Find Muhurat"
5. View auspicious timings

### 8. E-Commerce Testing

#### Add to Cart

**Test Flow**:
1. Navigate to "Services" screen
2. Browse available services
3. Click on a service
4. Click "Add to Cart"
5. Item should be added to cart

#### Checkout

**Test Flow**:
1. Navigate to cart (from services or home)
2. Review cart items
3. Click "Proceed to Checkout"
4. Fill customer details
5. Click "Pay"
6. In mock mode, payment succeeds immediately

### 9. Admin Dashboard Testing

**Test Flow**:
1. Login as admin
2. View dashboard with statistics
3. Navigate to "Consultants"
4. View pending/approved consultants
5. Click on consultant to view details
6. Approve or reject consultant
7. Navigate to "Data Management"
8. Upload services/reports (JSON files)

### 10. Consultant Portal Testing

**Test Flow**:
1. Login as consultant
2. View dashboard with upcoming consultations
3. Navigate to "Schedule"
4. View/manage availability
5. Navigate to "Earnings"
6. View earnings history and pending payouts

## Unit Testing

Run unit tests:

```bash
flutter test
```

### Test Files

- `test/auth_test.dart` - Authentication tests
- `test/role_test.dart` - Role-based access tests

### Running Specific Tests

```bash
# Run auth tests only
flutter test test/auth_test.dart

# Run role tests only
flutter test test/role_test.dart
```

## Integration Testing

### Backend API Testing

Test backend endpoints using curl or Postman:

```bash
# Health check
curl http://localhost:3000/health

# Sign up
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","name":"Test User"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

## Known Issues & Limitations

### Mock Mode

When running in mock mode (`useMockData = true`):

1. **Authentication**: All credentials are accepted
2. **OTP**: Use `123456` for any phone number
3. **Google Sign-In**: Automatically succeeds
4. **Payment**: Automatically succeeds
5. **Data**: Uses local mock data files

### Production Considerations

1. **Database**: Currently uses in-memory storage. For production:
   - Set up PostgreSQL/Supabase
   - Update backend to use database
   - Configure connection strings

2. **Authentication**: 
   - Set up Firebase for Google OAuth
   - Configure Twilio for phone OTP
   - Set up email service for password reset

3. **Payment**: 
   - Configure Razorpay credentials
   - Implement webhook handlers
   - Add payment verification

4. **Video/Audio Calls**:
   - Set up Agora.io or Twilio Video
   - Configure API keys
   - Implement signaling server

## Troubleshooting

### Backend Not Starting

1. Check Node.js version: `node --version` (should be 18+)
2. Install dependencies: `npm install`
3. Check port 3000 is available
4. Verify `.env` file exists (optional in mock mode)

### Flutter Build Errors

1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Dart version: `dart --version` (should be 3.0+)
4. Verify all dependencies in `pubspec.yaml`

### Chart Generation Fails

1. Verify Python is installed: `python --version`
2. Install pyswisseph: `pip install pyswisseph`
3. Check backend is running
4. Verify date/time format

### Authentication Issues

1. In mock mode, any credentials work
2. Check backend is running
3. Verify API endpoints in `app_config.dart`
4. Check network connectivity

## Development Workflow

### Making Changes

1. **Frontend Changes**:
   - Edit files in `lib/`
   - Hot reload: Press `r` in terminal
   - Hot restart: Press `R` in terminal

2. **Backend Changes**:
   - Edit files in `backend/`
   - Restart server: `npm run dev` (auto-restarts)

3. **Testing Changes**:
   - Run `flutter test` after changes
   - Test manually in app
   - Check console for errors

### Adding New Features

1. Create feature branch
2. Implement feature
3. Add tests
4. Update documentation
5. Test thoroughly
6. Submit for review

## File Structure

```
karmgyan/
├── lib/
│   ├── core/              # Core utilities, providers, models
│   ├── presentation/      # UI screens and widgets
│   ├── services/          # API services
│   └── config/           # Configuration
├── backend/
│   ├── routes/           # API routes
│   ├── middleware/       # Auth/role middleware
│   └── python/          # Chart computation scripts
├── assets/
│   └── mock_data/       # Mock data files
└── test/                # Unit tests
```

## Support & Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Riverpod Documentation**: https://riverpod.dev
- **GoRouter Documentation**: https://pub.dev/packages/go_router
- **Backend API**: http://localhost:3000/health

## Next Steps

1. Set up production database
2. Configure external services (Firebase, Twilio, Razorpay)
3. Implement real video/audio calling
4. Add comprehensive error handling
5. Set up CI/CD pipeline
6. Deploy to production

---

**Last Updated**: 2024-03-15
**Version**: 1.0.0

