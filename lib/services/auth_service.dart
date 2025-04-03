import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../env.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.iOS ? Env.firebaseIOSClientId : Env.googleWebClientId,
    scopes: ['email', 'profile'],
  );
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<Map<String, String?>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String? token = await result.user?.getIdToken();
      if (token != null) {
        await _prefs.setString(AppConfig.tokenStorageKey, token);
      }
      return {'token': token, 'error': null};
    } on FirebaseAuthException catch (e) {
      return {'token': null, 'error': e.message};
    }
  }

  Future<Map<String, String?>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'token': null, 'error': 'Google sign in was cancelled'};
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get Google tokens
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        return {'token': null, 'error': 'Failed to get authentication tokens'};
      }

      // Create Firebase credential and sign in
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      await _auth.signInWithCredential(credential);

      // Store tokens
      await _prefs.setString(AppConfig.tokenStorageKey, idToken);
      await _prefs.setString('googleAccessToken', accessToken);

      // Debug token info
      print('ID Token: ${idToken.substring(0, 20)}...');
      print('Access Token: ${accessToken.substring(0, 20)}...');

      return {'token': idToken, 'accessToken': accessToken, 'error': null};
    } catch (e) {
      return {'token': null, 'error': e.toString()};
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _prefs.remove(AppConfig.tokenStorageKey),
      _prefs.remove('googleAccessToken'),
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  String? getStoredToken() {
    return _prefs.getString(AppConfig.tokenStorageKey);
  }

  String? getStoredAccessToken() {
    return _prefs.getString('googleAccessToken');
  }

  Map<String, String?> getStoredTokens() {
    return {'token': getStoredToken(), 'accessToken': getStoredAccessToken()};
  }
}
