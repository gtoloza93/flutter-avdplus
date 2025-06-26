import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyHabitCounter extends StatelessWidget {
  const WeeklyHabitCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Text('0 / 0');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('frequency', isEqualTo: 'SEMANAL')
          .snapshots(),
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('0 / 0');
        }

        // Sin datos o error
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('0 / 0');
        }

        final habitDocs = snapshot.data!.docs;
        final now = DateTime.now();
        final startOfWeek = _getStartOfWeek(now);

        int completedThisWeek = 0;

        for (var doc in habitDocs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            
            // Debug: Imprime los datos del hábito
            debugPrint('Hábito ${doc.id}: ${data.toString()}');
            
            // Verifica si es un hábito semanal completado
            if (data['frequency'] != 'SEMANAL') continue;
            
            // Verifica si está marcado como completado
            if (data['completed'] != true) continue;
            
            // Verifica la fecha de completado
            final lastCompleted = data['lastCompleted'] as Timestamp?;
            if (lastCompleted == null) continue;
            
            final completionDate = lastCompleted.toDate();
            if (completionDate.isAfter(startOfWeek)) {
              completedThisWeek++;
            }
          } catch (e) {
            debugPrint('Error procesando hábito ${doc.id}: $e');
          }
        }

        return Text(
          '$completedThisWeek/${habitDocs.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Retorna el lunes de esta semana a las 00:00:00
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }
}