# karmgyan Architecture

## Overview

karmgyan is a comprehensive cross-platform personal advisory services platform built with Flutter (frontend) and Node.js (backend), integrated with Supabase for database and authentication.

## Tech Stack

### Frontend
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI Theme**: Custom royal blue, cream, and gold theme
- **Local Storage**: Hive + SharedPreferences
- **HTTP Client**: Dio
- **Internationalization**: Easy Localization

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **Computation Engine**: Python 3.8+ with pyswisseph
- **Payment**: Razorpay

### Infrastructure
- **Database**: Supabase PostgreSQL
- **Authentication**: Supabase Auth
- **File Storage**: Supabase Storage (for reports, images)
- **Real-time**: Supabase Realtime

## Project Structure

```
karmgyan/
├── lib/
│   ├── config/              # Configuration files
│   │   ├── supabase_config.dart
│   │   └── app_theme.dart
│   ├── core/                # Core utilities
│   │   ├── providers/       # Riverpod providers
│   │   ├── router/          # Navigation routing
│   │   └── services/        # Core services
│   ├── data/                # Data models (future)
│   ├── domain/              # Business logic (future)
│   ├── presentation/        # UI layer
│   │   └── screens/         # All app screens
│   └── services/            # External service integrations
├── backend/
│   ├── routes/              # API routes
│   ├── python/              # Computation scripts
│   └── server.js            # Express server
├── database/
│   └── schema.sql           # Database schema
└── assets/                  # Images, fonts, translations
```

## Key Features

### 1. Authentication & Authorization
- Email/password authentication via Supabase Auth
- Role-based access control (client, advisor, admin)
- Multi-profile management
- Session management

### 2. Client Profile Management
- Create and manage multiple client profiles
- Store birth details (date, time, place, coordinates)
- Profile history tracking

### 3. Computation Engine
- Birth chart generation using pyswisseph
- Dasha period calculations
- Divisional charts (D1, D2, D3, D9, D10, D16, etc.)
- Indian reference system (Lahiri ayanamsa)

### 4. Services & Orders
- Service catalog browsing
- Order placement and tracking
- Invoice generation
- Payment integration (Razorpay)

### 5. Compatibility Matching
- Guna Milan calculation
- Dosha analysis (Nadi, Mangal, Bhakut)
- Overall compatibility scoring
- Detailed matching reports

### 6. Panchang & Calendar
- Daily panchang (Tithi, Nakshatra, Yoga, Karana)
- Hindu calendar integration
- Muhurat finder
- Festival and event tracking

### 7. Consultations
- Video calls (WebRTC/Agora)
- Voice calls
- Chat messaging
- AI-powered instant queries

### 8. Reports
- Birth chart reports
- Dasha reports
- Compatibility reports
- PDF generation and download

### 9. Admin Dashboard
- User management
- Order management
- Content management
- System configuration
- Analytics

### 10. Social Features
- Community forum
- Article and video magazine
- Social sharing
- Push notifications

## Data Flow

1. **User Action** → Flutter UI
2. **State Update** → Riverpod Provider
3. **API Call** → Backend Service (Dio)
4. **Backend Processing** → Express.js Route
5. **Database/Computation** → Supabase or Python Script
6. **Response** → Flutter UI Update

## Security

- Supabase Row Level Security (RLS) policies
- JWT-based authentication
- Encrypted payment transactions
- Secure API endpoints
- Input validation and sanitization

## Scalability Considerations

- Stateless backend API
- Database indexing for performance
- Caching strategies for computations
- CDN for static assets
- Horizontal scaling capability

## Deployment

### Frontend
- iOS: App Store
- Android: Google Play Store
- Web: Hosting service (Firebase Hosting, Vercel, etc.)
- Desktop: Platform-specific stores

### Backend
- Node.js hosting (Heroku, Railway, AWS, etc.)
- Python environment for computation engine
- Supabase cloud database

## Future Enhancements

- AI-powered personalized advisories
- Machine learning for predictions
- Advanced analytics dashboard
- Multi-language support expansion
- Offline mode with sync
- Advanced matching algorithms
- Video consultation recording
- Referral program implementation
- 2FA security enhancement

