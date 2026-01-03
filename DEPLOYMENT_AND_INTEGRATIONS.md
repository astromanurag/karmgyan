# Deployment, Realtime DB, and Payments

This guide summarizes how to enable realtime database (Supabase), payments, and platform builds (Web, Android, iOS) for the karmgyan app.

---

## 1) Realtime Database with Supabase

### Create a Supabase project
1. Go to https://app.supabase.com and create a new project.
2. Note the **Project URL** and **anon key** (Settings → API).
3. In Supabase SQL editor, create tables as needed. Common tables:
   - `users (id uuid primary key, email text, role text, created_at timestamptz)`
   - `charts (id uuid pk, user_id uuid fk, chart_json jsonb, created_at timestamptz)`
   - `orders (id uuid pk, user_id uuid fk, amount numeric, status text, created_at timestamptz)`
   - `messages (id uuid pk, user_id uuid fk, text text, created_at timestamptz)`
4. Enable Row-Level Security and add policies so users read/write their own rows:
   ```sql
   alter table charts enable row level security;
   create policy "charts-own-rows" on charts
   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
   ```
5. Realtime: in Supabase Dashboard → Realtime, enable for the tables you want to subscribe to (e.g., `messages`, `charts`).

### Wire up the Flutter app
The app already has `lib/services/supabase_service.dart` and env hooks in `lib/config/env_config.dart`.
1. Add your keys at build time (see section 4 for platform-specific env):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
2. On app start (e.g., in `main.dart`), ensure `SupabaseService.initialize()` is invoked after `EnvConfig.initialize()` / `AppConfig` setup.
3. Use `SupabaseService.queryWithCache()` / `insertWithQueue()` / `updateWithQueue()` for offline-friendly flows.
4. For realtime listeners:
   ```dart
   final channel = SupabaseService.client
       ?.channel('public:messages')
       .on(RealtimeListenTypes.postgresChanges,
           ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
           (payload, [ref]) {
             // handle new message
           })
       ..subscribe();
   ```

---

## 2) Payments (Razorpay primary, Stripe optional)

### Razorpay (current implementation hook)
The code uses `PaymentService` → `EnhancedPaymentService` (Razorpay-first).

Backend:
1. Set up Razorpay account; get **Key ID** and **Key Secret**.
2. Expose an endpoint to create orders securely (amount, currency, receipt) and sign payloads. Never expose the secret in the client.
3. Verify signatures server-side on webhook events (`payment.captured`, etc.).

Frontend (Flutter):
1. Provide `RAZORPAY_KEY_ID` at build time (see env section).
2. For Android:
   - `android/app/build.gradle`: ensure `minSdkVersion >= 21`.
   - Add internet permission to `android/app/src/main/AndroidManifest.xml`.
3. For iOS:
   - `ios/Runner/Info.plist`: allow arbitrary loads if needed or configure ATS exceptions for Razorpay domains.
   - Run `cd ios && pod install` after adding the plugin.
4. Call `PaymentService.processPayment(...)` with amount/orderId/items/customer.

### Stripe (optional web-friendly flow)
If you prefer Stripe for web + mobile:
1. Create prices and products in Stripe Dashboard.
2. Backend: create a Checkout Session or Payment Intent endpoint; return `clientSecret` (for PI) or `url` (for Checkout).
3. Flutter:
   - Add `stripe_payment` / `flutter_stripe` package.
   - On mobile, use `flutter_stripe` with PaymentSheet + publishable key.
   - On web, you can open the Checkout Session URL or use Stripe.js via a webview.
4. Securely store Stripe secret keys on the backend only.

---

## 3) Build Targets: Web, Android, iOS

### Web
1. Enable web once: `flutter config --enable-web`
2. Build: `flutter build web --release`
3. Deploy the `build/web` folder to your hosting (Netlify, Vercel, Firebase Hosting, S3+CloudFront).
4. If using custom domain/https, ensure backend URL uses https and CORS allows the domain.

### Android
1. Ensure Java 17 and Android SDK are installed; run `flutter doctor`.
2. Keystore for release:
   ```bash
   keytool -genkey -v -keystore ~/keys/karmgyan.jks -keyalg RSA -keysize 2048 -validity 10000 -alias karmgyan
   ```
3. Set signing in `android/key.properties` and reference in `android/app/build.gradle`.
4. Build: `flutter build apk --release` or `flutter build appbundle --release`.
5. For Play Store, use the AAB.

### iOS
1. Install CocoaPods: `sudo gem install cocoapods`.
2. From `ios/`, run `pod install`.
3. Open `Runner.xcworkspace` in Xcode, set your Team & Bundle ID, ensure signing certificates are in place.
4. Build/Archive via Xcode for TestFlight/App Store.

### Common env for all platforms
Use `--dart-define` to inject runtime values:
```bash
flutter run -d chrome \
  --dart-define=BACKEND_URL=https://your-backend.com \
  --dart-define=SUPABASE_URL=https://xyz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=RAZORPAY_KEY_ID=rzp_test_123
```
For release builds, add the same `--dart-define` flags to `flutter build ...`.

---

## 4) Environment Variables Mapping

The app reads from `EnvConfig`/`AppConfig` via `const String.fromEnvironment`:
- `BACKEND_URL`
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `RAZORPAY_KEY_ID`
- (Optional) `USE_MOCK_DATA`, `AGORA_APP_ID`, `AGORA_APP_CERTIFICATE`

Provide them with `--dart-define` as shown above or via your CI/CD.

---

## 5) Realtime + Payments Checklist

- [ ] Supabase project created; tables & RLS policies applied.
- [ ] Realtime enabled on required tables.
- [ ] `SUPABASE_URL` and `SUPABASE_ANON_KEY` set in build args.
- [ ] Backend payment endpoints (Razorpay/Stripe) secured; secrets not in client.
- [ ] `RAZORPAY_KEY_ID` (or Stripe publishable key) set in build args.
- [ ] Android/iOS platform permissions and signing configured.
- [ ] Web CORS allowed for your domain.

---

## 6) Dark Buttons / Contrast

The theme sets elevated buttons to gold-on-navy. If you add custom buttons, prefer:
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: AppTheme.accentGold,
  foregroundColor: AppTheme.primaryNavy,
)
```
or
```dart
backgroundColor: AppTheme.primaryBlue,
foregroundColor: Colors.white,
```
to avoid dark-on-dark text.

---

## 7) Quick Commands Reference

```bash
# Enable web once
flutter config --enable-web

# Run web (dev)
flutter run -d chrome --dart-define=BACKEND_URL=http://localhost:3000

# Build web
flutter build web --release

# Run Android (emulator/device)
flutter run -d android --dart-define=BACKEND_URL=http://10.0.2.2:3000

# Build Android APK
flutter build apk --release

# Run iOS (simulator)
flutter run -d ios --dart-define=BACKEND_URL=http://localhost:3000

# Tests
flutter test
```

