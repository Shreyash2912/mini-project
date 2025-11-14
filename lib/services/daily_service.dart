import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  static String get _todayKey {
    final now = DateTime.now().toUtc();
    return "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
  }

  static Future<Map<String, dynamic>> getToday({
    required Future<Map<String, dynamic>> Function() generator,
  }) async {
    try {
      final ref = _db.collection('users').doc(_uid).collection('daily').doc(_todayKey);
      final snap = await ref.get();
      
      if (snap.exists) {
        final data = snap.data()!;
        return {
          'prompt': data['prompt'] ?? '',
          'answer': data['answer'] ?? '',
        };
      }
      
      // Generate new challenge
      final data = await generator();
      await ref.set({
        'prompt': data['prompt'],
        'answer': data['answer'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return data;
    } catch (e) {
      // Guest mode or error - generate without saving
      return await generator();
    }
  }
}
