import 'dart:math';

import 'package:advplus/widgets/habitdetails.dart';
import 'package:advplus/widgets/levelprogresswidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advplus/widgets/customcheckbox.dart';

class HabitItem extends StatelessWidget {
  final String text;
  final String id; // Requerido para identificar en Firebase
  final bool isChecked;
  final int xp; // XP ganado al completar
  final Map<String, dynamic> habit;
  final ValueChanged<bool?>? onCheckedChange;

  const HabitItem({
    super.key,
    required this.text,
    required this.id,
    required this.isChecked,
    required this.xp,
    required this.habit,
    this.onCheckedChange,
  });

  void _markAsCompleted(BuildContext context, bool? value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final habitDocId = habit['id'];
      final habitXp = habit['xp'] is int ? habit['xp'] : 0;
      final habitFrequency = habit['frequency'] ?? '';

      final habitStartDate = _parseDate(habit['startDate']);
      final habitEndDate = _parseDate(habit['endDate']);

      final today = DateTime.now();

      if ((habitStartDate != null && habitStartDate.isAfter(today)) ||
          (habitEndDate != null && habitEndDate.isBefore(today))) {
        return;
      }

      final habitRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitDocId);

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final habitSnapshot = await habitRef.get();
      final habitData = habitSnapshot.data() ?? {};
      final wasCompleted = habitData['completed'] == true;

      final userDataSnapshot = await userDocRef.get();
      final data = userDataSnapshot.data() ?? {};
      final currentXp = data['xpTotal'] is int ? data['xpTotal'] : 0;

      if (value == true && !wasCompleted) {
        await habitRef.update({
          'completed': true,
          'lastCompleted': FieldValue.serverTimestamp(),
        });

        final newXpTotal = currentXp + habitXp;
        await userDocRef.update({'xpTotal': newXpTotal});

        // ✅ Ahora usamos la función estática de LevelProgressWidget
        LevelProgressWidget.checkLevelUp(newXpTotal, user.uid, context);
      } else if (value == false && wasCompleted) {
        await habitRef.update({'completed': false, 'lastCompleted': null});

        final newXpTotal = max(currentXp - habitXp, 0);
        await userDocRef.update({'xpTotal': newXpTotal});

        // ✅ También aquí
        LevelProgressWidget.checkLevelUp(newXpTotal, user.uid, context);
      }
    } catch (e, s) {
      // 👇 Captura errores y muestra en consola
      print("Error al actualizar hábito: $e");
      print(s); // Stack trace completo

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hubo un error al actualizar el hábito"),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

 
  // Reinicia los hábitos diarios cada mañana a las 00:00
  static void scheduleDailyReset() {
    final now = DateTime.now();
    final nextDay = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ); // Mañana a las 00:00
    final difference = nextDay.difference(now);

    Future.delayed(difference, () async {
      await resetDailyHabits(); // Llama a la función de reinicio

      scheduleDailyReset(); // Programa el siguiente reinicio
    });
  }

  // Reinicia hábitos diarios → completed: false, lastCompleted: null
  static Future<void> resetDailyHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits');

    final habitsSnapshot = await habitsCollection.get();

    for (var doc in habitsSnapshot.docs) {
      final habitData = doc.data();
      final frequency = habitData['frequency'] ?? '';
      final lastCompleted = _parseTimestamp(habitData['lastCompleted']);

      if (frequency == 'DIARIO' && lastCompleted != null) {
        final completionDate = lastCompleted;
        if (!isSameDay(completionDate, DateTime.now())) {
          await doc.reference.update({
            'completed': false,
            'lastCompleted': null,
          });
        }
      }
    }
  }

  // Reinicia hábitos semanales → una vez por semana
  static void scheduleWeeklyReset() {
    final now = DateTime.now();
    final daysUntilMonday =
        (now.weekday % 7) + 1; // Desde hoy hasta el próximo lunes
    final nextMonday = DateTime(now.year, now.month, now.day + daysUntilMonday);
    final difference = nextMonday.difference(now);

    Future.delayed(difference, () async {
      await resetWeeklyHabits();
      scheduleWeeklyReset(); // Reiniciar la cuenta
    });
  }

  static Future<void> resetWeeklyHabits() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits');

    final habitsSnapshot = await habitsCollection.get();

    for (var doc in habitsSnapshot.docs) {
      final habitData = doc.data();
      final frequency = habitData['frequency'] ?? '';
      final lastCompleted = _parseTimestamp(habitData['lastCompleted']);

      if (frequency == 'SEMANAL' && lastCompleted != null) {
        final completionDate = lastCompleted;
        if (!isSameWeek(completionDate, DateTime.now())) {
          await doc.reference.update({
            'completed': false,
            'lastCompleted': null,
          });
        }
      }
    }
  }

  // Verifica si dos fechas están en la misma semana
  static bool isSameWeek(DateTime date1, DateTime date2) {
    final diff = date1.difference(date2).inDays;
    return diff < 7 && diff >= 0 && date1.weekday == date2.weekday;
  }

  // Convierte Timestamp a DateTime
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  // Convierte fecha dinámica a DateTime
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;

    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return null;
      }
    } else if (date is DateTime) {
      return date;
    }

    return null;
  }

  // Compara días iguales
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailsScreen(habit: habit),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        child: Row(
          children: [
            CustomCheckboxImage(
              emptyPath: 'assets/icons/checkbox.png',
              checkmarkPath: 'assets/icons/checkmark.png',
              isChecked: isChecked,
              onTap: (value) {
                onCheckedChange?.call(value);
                _markAsCompleted(context, value);
              },
            ),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
            // Muestra el XP ganado
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                "$xp XP",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
