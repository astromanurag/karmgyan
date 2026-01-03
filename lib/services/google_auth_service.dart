import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';
import '../config/env_config.dart';
import 'auth_service.dart';
import '../core/models/user_model.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<UserModel> signIn() async {
    try {
      if (EnvConfig.useMockAuth) {
        // Mock Google sign in
        await Future.delayed(const Duration(seconds: 1));
        return await AuthService.signInWithGoogle('mock_google_token_12345');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Use the access token to authenticate with backend
      return await AuthService.signInWithGoogle(googleAuth.idToken ?? '');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    if (!EnvConfig.useMockAuth) {
      await _googleSignIn.signOut();
    }
    await AuthService.signOut();
  }

  static Future<bool> isSignedIn() async {
    if (AppConfig.useMockData) {
      return false;
    }
    return await _googleSignIn.isSignedIn();
  }
}

