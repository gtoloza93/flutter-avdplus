import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomProgressBar extends StatelessWidget {
  const CustomProgressBar({
    super.key,
  });

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
          return _buildProgressContainer(0.0);
        }

        final habitDocs = snapshot.data!.docs;

        final today = DateTime.now();
        final completedToday = habitDocs.map((doc) => doc.data() as Map<String, dynamic>).where((habit) {
          final lastCompleted = (habit['lastCompleted'] as Timestamp?)?.toDate();
          return habit['completed'] == true &&
              lastCompleted != null &&
              isSameDay(lastCompleted, today);
        }).length;

        final totalHabits = habitDocs.length;
        final progress = totalHabits == 0 ? 0.0 : completedToday / totalHabits;

        return _buildProgressContainer(progress);
      },
    );
  }

  Widget _buildProgressContainer(double progress) {
    final percent = (progress * 100).toInt(); // Progreso en porcentaje

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
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Fredoka',
            ),
          ),

          SizedBox(height: 10),

          Row(
            children: [
              SizedBox(width: 10),
              Image.asset(
                'assets/icons/progreso.png',
                width: 25,
                height: 25,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Tu Progreso hoy : $percent%',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

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
                    height:50,
                    fit: BoxFit.fitWidth,
                  ),

                  // Barra llena naranja - clippeada dinámicamente
                  ClipRect(
                    clipper: ProgressRectClipper(progress: progress),
                    child: Image.asset(
                      'assets/images/progressfill.png',
                      width: barWidth,
                      height: 50,
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}

// Clase auxiliar para recortar la barra de progreso
class ProgressRectClipper extends CustomClipper<Rect> {
  final double progress;

  ProgressRectClipper({required this.progress});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}