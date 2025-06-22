import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitCounter extends StatelessWidget {
  const HabitCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('frequency', isEqualTo: 'DIARIO')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              Image.asset('assets/icons/Hoy.png', width: 30, height: 30),
              SizedBox(width: 10),
              Text(
                'Objetivos de Hoy :',
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

        final thisToday = habitDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        final completedToday = thisToday.where((h) => h['completed']).length;


        return Row(
          children: [
            Image.asset('assets/icons/Hoy.png', width: 30, height: 30),
            SizedBox(width: 10),
            Text(
              'Objetivos de Hoy :',
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
                color: const Color.fromARGB(115, 0, 0, 0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$completedToday / ${habitDocs.length}',
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}