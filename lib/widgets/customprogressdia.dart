import 'package:advplus/widgets/DailyHabitCounter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomProgressDia extends StatelessWidget {
  const CustomProgressDia({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('habits')
              .where('frequency', isEqualTo: 'DIARIO')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildProgressContainer(progress: 0.0, xpTotal: 0);
        }

        final habitDocs =
            snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
        final today = DateTime.now();
        int completedXp = 0;

        for (var habit in habitDocs) {
          final lastCompleted =
              (habit['lastCompleted'] as Timestamp?)?.toDate();
          final xp = (habit['xp'] as int?) ?? 0;

          if (habit['completed'] == true &&
              lastCompleted != null &&
              isSameDay(lastCompleted, today)) {
            completedXp += xp;
          }
        }

        final totalXp = habitDocs.fold<int>(0, (sum, habit) {
          final xp = (habit['xp'] as int?) ?? 0;
          return sum + xp;
        });

        final progress = totalXp == 0 ? 0.0 : completedXp / totalXp;

        return _buildProgressContainer(
          progress: progress,
          xpTotal: completedXp,
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildProgressContainer({
    required double progress,
    required int xpTotal,
  }) {
    final percent = (progress * 100).toInt();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      margin: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(204, 3, 3, 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              Image.asset(
                'assets/icons/boton.png',
                width: 20,
                height: 20,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Progreso de hoy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 110,
                  ), // o right, horizontal, etc.
                  child: Text(
                    '$xpTotal XP',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Fondo vacío
                  Image.asset(
                    'assets/images/probarback.png',
                    width: 350,
                    height: 70,
                    fit: BoxFit.fitWidth,
                  ),

                  // Barra llena naranja - clippeada dinámicamente
                  ClipRect(
                    clipper: ProgressRectClipper(progress: progress),
                    child: Image.asset(
                      'assets/images/progressfilln.png',
                      width: 350,
                      height: 50,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 10),
              Image.asset(
                'assets/icons/hoynow.png',
                width: 28,
                height: 28,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Hoy :',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                    SizedBox(width: 5), // Espacio entre textos
                    Text(
                      ' $percent% Completado',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),



              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 125,
                  ), // o right, horizontal, etc.
                  child: DailyHabitCounter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
