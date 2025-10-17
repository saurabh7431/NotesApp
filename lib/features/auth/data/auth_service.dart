import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;


  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent!: $email");
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  String _mapException(FirebaseAuthException exception) {
  final code = exception.code.toLowerCase();

  switch (code) {
    // Email related errors
    case 'invalid-email':
      return 'Email address is invalid.';
    case 'email-already-in-use':
      return 'This email is already registered.';
    case 'user-not-found':
      return 'No account found for this email.';

    // Password related errors
    case 'wrong-password':
      return 'Incorrect email or password.';
    case 'weak-password':
      return 'Please choose a stronger password (at least 6 characters).';

    // Account state errors
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-token-expired':
      return 'Session expired. Please log in again.';
    case 'user-mismatch':
      return 'This credential does not match the logged-in user.';

    // Network / quota / internal errors
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'internal-error':
      return 'Server error. Please try again later.';
    case 'operation-not-allowed':
      return 'This operation is not allowed. Please contact support.';

    // Credential / provider errors
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different sign-in method.';
    case 'invalid-credential':
      return 'The credentials provided are invalid.';
    case 'invalid-verification-code':
      return 'Invalid verification code.';
    case 'invalid-verification-id':
      return 'Invalid verification ID.';
    case 'credential-already-in-use':
      return 'This credential is already associated with another user.';

    // Default fallback
    default:
      return exception.message ?? 'Something went wrong, please try again.';
  }
}

  }

