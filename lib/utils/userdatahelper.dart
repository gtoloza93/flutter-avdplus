import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDataHelper {
  static Future<void> updateXpAndCheckLevel(int newXp, String userId, BuildContext context) async {
    final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final currentLevel = userData['level'] ?? 1;

    final neededXp = calculateXpForNextLevel(currentLevel);

    if (newXp >= neededXp) {
      int newLevel = currentLevel + 1;
      int coinsToAdd = getBonusCoinsForLevel(newLevel);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'level': newLevel,
        'coins': FieldValue.increment(coinsToAdd),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Subiste al Nivel $newLevel! Ganaste $coinsToAdd Coins"),
          backgroundColor: Colors.amber[700],
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'xpTotal': newXp});
    }
  }

  static int calculateXpForNextLevel(int currentLevel) {
    return (200 * pow(currentLevel, 1.5)).toInt() + 100;
  }

  static int getBonusCoinsForLevel(int level) {
    if (level == 5) return 50;
    if (level == 25) return 150;
    if (level == 50) return 300;
    if (level == 100) return 500;
    return 40; // Recompensa genérica
  }
}