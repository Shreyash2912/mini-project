import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data();
      return {
        'uid': user.uid,
        'email': user.email,
        'name': data?['name'],
        'isVip': data?['isVip'] ?? false,
      };
    } catch (e) {
      return null;
    }
  }

  static Future<bool> signUp(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) return false;
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'isVip': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.updateDisplayName(name);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data();
    return {
      'uid': user.uid,
      'email': user.email,
      'name': data?['name'] ?? user.displayName,
      'isVip': data?['isVip'] ?? false,
    };
  }

  static Future<void> updateUserName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'name': name});
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
    }
  }

  static Future<void> setVipStatus(String uid, bool isVip) async {
    await _db.collection('users').doc(uid).update({'isVip': isVip});
  }
}
