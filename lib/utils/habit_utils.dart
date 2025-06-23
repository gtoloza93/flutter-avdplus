import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitUtils {
  static Future<void> resetAllDailyHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .where('frequency', isEqualTo: 'DIARIO')
        .get();

    for (var doc in habitsSnapshot.docs) {
      await doc.reference.update({
        'completed': false,
        'lastCompleted': null,
      });
    }
  }

  static Future<void> resetXP() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'xpTotal': 0});
  }
}