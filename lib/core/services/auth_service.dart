import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  Future<bool> hasCompletedOnboarding(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return false;
      }
      final data = doc.data();
      if (data == null) {
        return false;
      }
      final value = data['hasCompletedOnboarding'];
      return value == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboardingCompleted(String uid) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'hasCompletedOnboarding': true,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> saveOnboardingData(String uid, Map<String, dynamic> data) async {
    log(data.toString());
    await _firestore.collection('users').doc(uid).set(
      {
        'onboarding': data,
      },
      SetOptions(merge: true),
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}

