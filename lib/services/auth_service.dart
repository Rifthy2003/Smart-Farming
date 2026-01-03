import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  // These MUST be defined here so the functions below can use them
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- EMAIL/PASSWORD SIGN UP ---
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  // --- EMAIL/PASSWORD SIGN IN ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Signin Error: $e");
      return null;
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For Web, we use the GoogleAuthProvider directly with a popup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        // For Mobile, we use the google_sign_in package flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User canceled the selection

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print("Google Auth Error: $e");
      return null;
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}