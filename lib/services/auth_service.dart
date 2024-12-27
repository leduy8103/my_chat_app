import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user != null) {
        final UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? '',
          status: 'online',
        );

        // Update user status in Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
              'status': 'online',
              'lastSeen': DateTime.now().toIso8601String(),
            });

        return userModel;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserModel?> register(String email, String password, String name) async {
    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user != null) {
        // Create user model
        final UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email!,
          name: name,
          status: 'online',
        );

        // Store in Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toJson());

        // Update display name
        await user.updateDisplayName(name);
        
        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({
      'status': status,
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await updateUserStatus(user.uid, 'offline');
      }
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return UserModel(
      uid: user.uid,
      email: user.email!,
      name: user.displayName ?? '',
    );
  }
}