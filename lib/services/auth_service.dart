import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- EMAIL/PASSWORD SIGN UP (stores username if provided) ---
  Future<User?> signUp(String email, String password, {String? username}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      // Store username -> email mapping in Firestore for username lookups
      // Do not await this write so signup returns quickly; log errors if any.
      if (user != null && username != null && username.trim().isNotEmpty) {
        _firestore.collection('users').doc(user.uid).set({
          'username': username.trim(),
          'email': email.trim(),
        }).then((_) {
          // success
        }).catchError((e) {
          print('Firestore write failed for user ${user.uid}: $e');
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Signup Error: ${e.code} ${e.message}');
      // Re-throw to allow UI to show specific messages
      throw e;
    } catch (e) {
      print('Signup Error: $e');
      rethrow;
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(); 
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) return null; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
      
    } catch (e) {
      print("Google Auth Error: $e");
      return null;
    }
  }

  // --- SIGN IN (email or username) ---
  /// identifier can be an email or a username. If username, looks up the email in Firestore.
  Future<User?> signInWithEmailOrUsername(String identifier, String password) async {
    try {
      String email = identifier.trim();

      // If not an email (no @), attempt to find username in Firestore
      if (!email.contains('@')) {
        final query = await _firestore.collection('users').where('username', isEqualTo: email).limit(1).get();
        if (query.docs.isEmpty) {
          // No username mapping found
          throw FirebaseAuthException(code: 'user-not-found', message: 'No user found with that username');
        }
        final data = query.docs.first.data();
        if (data['email'] == null) {
          throw FirebaseAuthException(code: 'user-not-found', message: 'No email mapped for this username');
        }
        email = data['email'] as String;
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Re-throw so UI can inspect error codes
      print('Sign-in error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign-in unexpected error: $e');
      throw FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  // --- SIGN OUT ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Signout Error: $e");
    }
  }
}