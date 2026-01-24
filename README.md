# karmgyan - Personal Advisory Services Platform

A comprehensive cross-platform application for personal advisory services built with Flutter and Supabase.

## Features

- 🔐 Secure authentication with role-based access control
- 📊 Advanced computation engine with pyswisseph integration
- 💳 Integrated payment gateways (Razorpay, Paytm)
- 📅 Hindu calendar and Panchang integration
- 💬 Real-time consultations (video, voice, messaging)
- 🤖 AI-powered personalized advisories
- 👥 Compatibility matching engine
- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🌍 Multilingual support
- 📈 Analytics and reporting
- 🎨 Premium royal blue, cream, and gold theme

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend API**: External API at https://karmgyan-api.onrender.com (FastAPI)
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth, Clerk (Phone OTP)
- **Computation**: Swiss Ephemeris (via external API)
- **Payments**: Cashfree
- **Communication**: WebRTC, Agora
- **AI**: Perplexity Pro

## Quick Start

1. Install Flutter SDK (3.27.0 or higher)
2. Install dependencies: `flutter pub get`
3. **Demo API key is already configured** - No setup needed for testing!
4. Run the app: `flutter run`

The app uses a demo API key (`demo_pro_key_123456789`) by default, which provides 10,000 requests/day for testing.

## API Configuration

### Using Demo Keys (Default)

The app is pre-configured with a demo API key for testing:
- **Default**: `demo_pro_key_123456789` (10,000 requests/day)
- All features enabled

### Using Your Own API Key

For production, generate your own API key and add it to `.env`:

```env
API_KEY=your_generated_api_key_here
BACKEND_URL=https://karmgyan-api.onrender.com
```

See [API_TOKEN_GUIDE.md](API_TOKEN_GUIDE.md) for detailed instructions.

### Available Demo Keys

- `demo_free_key_12345678` - 100 requests/day (Birth Chart, Panchang)
- `demo_basic_key_12345678` - 1,000 requests/day (+ Dasha, Divisional)
- `demo_pro_key_123456789` - 10,000 requests/day (All features) - **DEFAULT**
- `sk_test_astro_enterprise` - 100,000 requests/day (All features + Priority)

See [DEMO_KEY_SETUP.md](DEMO_KEY_SETUP.md) for more details.

## Project Structure

```
lib/
├── config/          # Configuration files
├── core/            # Core utilities and constants
├── data/            # Data models and repositories
├── domain/          # Business logic
├── presentation/    # UI components and screens
├── services/        # External service integrations
└── main.dart        # App entry point
```

## License

Proprietary - All rights reserved

