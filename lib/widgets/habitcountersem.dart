import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitCounterSem extends StatelessWidget {
  const HabitCounterSem({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('frequency', isEqualTo: 'SEMANAL')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              Image.asset('assets/icons/cumbre.png', width: 30, height: 30),
              SizedBox(width: 10),
              Text(
                'Objetivo Semanal :',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '0 / 0',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
            ],
          );
        }

        final habitDocs = snapshot.data!.docs;

        final thisWeekHabits = habitDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        final completedThisWeek = thisWeekHabits.where((h) => h['completed']).length;

        return Row(
          children: [
            Image.asset('assets/icons/cumbre.png', width: 30, height: 30),
            SizedBox(width: 10),
            Text(
              'Objetivo Semanal :',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$completedThisWeek / ${habitDocs.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}