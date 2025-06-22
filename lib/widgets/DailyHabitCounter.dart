import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DailyHabitCounter extends StatelessWidget {
  const DailyHabitCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Text('0 / 0');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('frequency', isEqualTo: 'DIARIO')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('0/0');
        }

        final habitDocs = snapshot.data!.docs;
        final today = DateTime.now();
        
        final completedToday = habitDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final lastCompleted = (data['lastCompleted'] as Timestamp?)?.toDate();
          return data['completed'] == true &&
              lastCompleted != null &&
              isSameDay(lastCompleted, today);
        }).length;

        return Text(
          '$completedToday/${habitDocs.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Fredoka',
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}