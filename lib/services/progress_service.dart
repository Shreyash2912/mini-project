import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
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

  static Future<void> recordAttempt({
    required bool correct,
    int minutesStudied = 1,
    String? lang,
    String? difficulty,
  }) async {
    final ref = _db.collection('users').doc(_uid).collection('progress').doc(_todayKey);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() ?? {};
      final currentCorrect = (data['correct'] ?? 0) as int;
      final currentTotal = (data['total'] ?? 0) as int;
      final currentMinutes = (data['minutesStudied'] ?? 0) as int;
      final currentXp = (data['xp'] ?? 0) as int;

      final gainedXp = correct ? 10 : 4;

      txn.set(ref, {
        'correct': currentCorrect + (correct ? 1 : 0),
        'total': currentTotal + 1,
        'minutesStudied': currentMinutes + minutesStudied,
        'xp': currentXp + gainedXp,
        'lang': lang,
        'difficulty': difficulty,
        'updatedAt': FieldValue.serverTimestamp(),
        'date': _todayKey,
      }, SetOptions(merge: true));
    });
  }

  static Future<List<Map<String, dynamic>>> last7Days() async {
    final now = DateTime.now().toUtc();
    final List<Map<String, dynamic>> out = [];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = "${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}";
      final snap = await _db.collection('users').doc(_uid).collection('progress').doc(key).get();
      final data = snap.data() ?? {};
      out.add({
        'key': key,
        'date': DateTime(day.year, day.month, day.day),
        'correct': (data['correct'] ?? 0) as int,
        'total': (data['total'] ?? 0) as int,
        'minutesStudied': (data['minutesStudied'] ?? 0) as int,
        'xp': (data['xp'] ?? 0) as int,
      });
    }
    return out;
  }

  static Future<int> getStreak() async {
    final now = DateTime.now().toUtc();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final key = "${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}";
      final snap = await _db.collection('users').doc(_uid).collection('progress').doc(key).get();
      if (!snap.exists || ((snap.data()?['total'] ?? 0) as int) == 0) break;
      streak++;
    }
    return streak;
  }

  static Future<int> getTotalXp() async {
    final now = DateTime.now().toUtc();
    int totalXp = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final key = "${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}";
      final snap = await _db.collection('users').doc(_uid).collection('progress').doc(key).get();
      totalXp += ((snap.data()?['xp'] ?? 0) as int);
    }
    return totalXp;
  }
}
