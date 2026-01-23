import 'package:google_sign_in/google_sign_in.dart';
import '../config/app_config.dart';
import '../config/env_config.dart';
import 'auth_service.dart';
import '../core/models/user_model.dart';

class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;
  
  static GoogleSignIn get _signIn {
    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Use platform-specific client IDs if available
        clientId: AppConfig.hasGoogleOAuthConfig 
            ? (AppConfig.googleOAuthClientIdWeb.isNotEmpty 
                ? AppConfig.googleOAuthClientIdWeb 
                : null)
            : null,
      );
    }
    return _googleSignIn!;
  }

  static Future<UserModel> signIn() async {
    try {
      if (EnvConfig.useMockAuth) {
        // Mock Google sign in
        await Future.delayed(const Duration(seconds: 1));
        return await AuthService.signInWithGoogle('mock_google_token_12345');
      }

      final GoogleSignInAccount? googleUser = await _signIn.signIn();
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
      await _signIn.signOut();
    }
    await AuthService.signOut();
  }

  static Future<bool> isSignedIn() async {
    if (AppConfig.useMockData) {
      return false;
    }
    return await _signIn.isSignedIn();
  }
}

