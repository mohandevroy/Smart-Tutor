import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  // 🔥 REGISTER (Auth + Firestore together)
  static Future<UserCredential> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    UserCredential? userCredential;

    try {
      // 1️⃣ Create Auth user
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2️⃣ Save user in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      // ❗ যদি Firestore fail করে → Auth user delete
      if (userCredential?.user != null) {
        await userCredential!.user!.delete();
      }
      rethrow;
    }
  }

  // 🔐 LOGIN
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // 🚪 LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }
}