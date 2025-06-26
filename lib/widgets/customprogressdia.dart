import 'package:advplus/widgets/DailyHabitCounter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomProgressDia extends StatelessWidget {
  const CustomProgressDia({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

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
          return _buildProgressContainer(0.0, xpTotal: 0);
        }

        final habitDocs = snapshot.data!.docs;

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        int completedXp = 0;
        int totalDailyXp = 0;

        for (var doc in habitDocs) {
          final habit = doc.data() as Map<String, dynamic>;

          // ✅ Validamos que `xp` sea `int`
          int xp = 0;
          if (habit.containsKey('xp')) {
            final rawXp = habit['xp'];
            if (rawXp is num) {
              xp = rawXp.toInt();
            } else if (rawXp is String) {
              final parsed = int.tryParse(rawXp);
              xp = parsed ?? 0;
            } else if (rawXp is int) {
              xp = rawXp;
            }
          }

          final completed = habit['completed'] == true;
          final lastCompleted = _parseTimestamp(habit['lastCompleted']);

          totalDailyXp += xp;

          if (completed &&
              lastCompleted != null &&
              lastCompleted.isAfter(todayStart)) {
            completedXp += xp;
          }
        }

        double progress = totalDailyXp == 0 ? 0.0 : completedXp / totalDailyXp;

        return _buildProgressContainer(progress, xpTotal: completedXp);
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

  Widget _buildProgressContainer(double progress, {required int xpTotal}) {
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
                  'Progreso de Hoy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Fredoka',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 90),
                  child: Text(
                    '$xpTotal XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                  Image.asset(
                    'assets/images/probarback.png',
                    width: barWidth,
                    height: 65,
                    fit: BoxFit.fitWidth,
                  ),
                  ClipRect(
                    clipper: ProgressRectClipper(progress: progress),
                    child: Image.asset(
                      'assets/images/progressfill.png',
                      width:barWidth,
                      height: 55,
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
              Text(
                'Hoy :',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fredoka',
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Text(
                      '$percent% Completado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 85),
                  child: DailyHabitCounter(), // Muestra cuántos hábitos completaste hoy
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
