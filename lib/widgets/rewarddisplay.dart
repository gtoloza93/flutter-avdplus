import 'package:flutter/material.dart';
import 'dart:math'; // Asegúrate de tener esta línea

class RewardDisplay extends StatelessWidget {
  final String frequency;
  final String difficulty;

  const RewardDisplay({
    super.key,
    required this.frequency,
    required this.difficulty, 
  });

  int calculateXP(String frequency, String difficulty) {
    if (frequency == 'DIARIO') {
      switch (difficulty) {
        case 'FÁCIL':
          return 15;
        case 'INTERMEDIO':
          return 35;
        case 'DIFÍCIL':
          return 70;
        default:
          return 0;
      }
    } else if (frequency == 'SEMANAL') {
      switch (difficulty) {
        case 'FÁCIL':
          return 90;
        case 'INTERMEDIO':
          return 180;
        case 'DIFÍCIL':
          return 360;
        default:
          return 0;
      }
    } else {
      double nivel = difficulty == 'FÁCIL'
          ? 1
          : difficulty == 'INTERMEDIO'
              ? 2
              : 3;

      return (200 * pow(nivel, 1.5).toDouble() + 100).toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int xp = calculateXP(frequency, difficulty);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(221, 0, 0, 0), // Fondo gris transparente
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/trophy.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10),
          Text(
            "Recompensa esperada :",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            "$xp XP",
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}