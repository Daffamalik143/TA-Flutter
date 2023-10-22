import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String profileType,
    required String username,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    await _firebaseFirestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'username': username,
      'accountType': profileType,
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final snapshot =
          await _firebaseFirestore.collection('users').doc(user.uid).get();
      final userData = snapshot.data();
      if (userData != null) {
        return userData;
      }
    }
    return null;
  }
}
