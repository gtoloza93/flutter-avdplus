import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Container();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .where('frequency', isEqualTo: 'DIARIO')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildProgressContainer(0.0);
        }

        final habitDocs = snapshot.data!.docs;

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        

        int completedToday = 0;
        int totalDailyHabits = habitDocs.length;

        for (var doc in habitDocs) {
          final habit = doc.data() as Map<String, dynamic>;
          final completed = habit['completed'] is bool ? habit['completed'] : false;
          final lastCompleted = _parseTimestamp(habit['lastCompleted']);

          if (completed && lastCompleted != null) {
            if (lastCompleted.isAfter(todayStart) 
               ) {
              completedToday++;
            }
          }
        }

        double progress =
            totalDailyHabits == 0 ? 0.0 : completedToday / totalDailyHabits;

       
        return _buildProgressContainer(progress);
      },
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  Widget _buildProgressContainer(double progress) {
    final percent = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      margin: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(204, 3, 3, 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "¿Listo para seguir construyendo hábitos hoy?",
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Fredoka',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),
              Image.asset(
                'assets/icons/progreso.png',
                width: 24,
                height: 24,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Tu Progreso Hoy : $percent%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Fondo vacío
                  Image.asset(
                    'assets/images/probarback.png',
                    width: barWidth,
                    height: 65,
                    fit: BoxFit.fitWidth,
                  ),

                  // Barra llena naranja - clippeada dinámicamente
                  ClipRect(
                    clipper: ProgressRectClipper(progress: progress),
                    child: Image.asset(
                      'assets/images/progressfill.png',
                      width: barWidth,
                      height: 56,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Clase auxiliar para recortar la barra de progreso
class ProgressRectClipper extends CustomClipper<Rect> {
  final double progress;

  const ProgressRectClipper({required this.progress});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}