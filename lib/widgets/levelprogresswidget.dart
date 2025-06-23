import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LevelProgressWidget extends StatefulWidget {
  const LevelProgressWidget({super.key});

  @override
  State<LevelProgressWidget> createState() => _LevelProgressWidgetState();

  // Fórmula: XP necesario = 200 × nivel^1.5 + 100
  static int calculateXpForNextLevel(int currentLevel) {
    return (200 * pow(currentLevel, 1.5)).toInt() + 100;
  }

  // Devuelve las monedas según el nivel alcanzado
  static int getBonusCoinsForLevel(int level) {
    if (level == 5) return 50;
    if (level == 25) return 150;
    if (level == 50) return 300;
    if (level == 100) return 500;
    return 40; // Recompensa genérica por subir de nivel
  }

  // Llamamos esta función cuando el usuario completa XP suficiente
  static Future<void> checkLevelUp(
      int newXpTotal, String userId, BuildContext context) async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final data = userData.data() ?? {};
    final currentLevel = data['level'] ?? 1;

    final neededXp = calculateXpForNextLevel(currentLevel);

    if (newXpTotal >= neededXp) {
      final newLevel = currentLevel + 1;
      final coinsToAdd = getBonusCoinsForLevel(newLevel);

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Reinicia xpTotal a 0 al subir de nivel
      await userDocRef.update({
        'level': newLevel,
        'xpTotal': 0,
        'coins': FieldValue.increment(coinsToAdd),
      });

      // Solo muestra SnackBar si el contexto sigue siendo válido
      if (context.mounted) {
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
      }
    }
  }
}

class _LevelProgressWidgetState extends State<LevelProgressWidget> {
  int _xpTotal = 0;
  int _level = 1;
  int _coins = 0;
  String _bonusMessage = "Empieza desde el nivel 1";

  late Stream<DocumentSnapshot> userStream;
  late StreamSubscription<DocumentSnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos iniciales
    _setupRealtimeListener(); // Escuchar cambios en tiempo real
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userData.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'xpTotal': 0,
        'level': 1,
        'coins': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'username': user.email?.split('@')[0] ?? 'Usuario',
      });
    } else {
      setState(() {
        _xpTotal = userData['xpTotal'] ?? 0;
        _level = userData['level'] ?? 1;
        _coins = userData['coins'] ?? 0;
        _bonusMessage = _getSpecialBonus(_level);
      });
    }
  }

  void _setupRealtimeListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 👇 Cambio clave: Usar un StreamSubscription para poder cancelarlo después
    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return; // ✅ Evita setState() si el widget ya fue eliminado

      final data = snapshot.data() ?? {};

      setState(() {
        _xpTotal = data['xpTotal'] ?? 0;
        _level = data['level'] ?? 1;
        _coins = data['coins'] ?? 0;
        _bonusMessage = _getSpecialBonus(_level);
      });
    });
  }

  @override
  void dispose() {
    // ❌ Cancela la escucha cuando el widget se elimina
    _subscription.cancel();
    super.dispose();
  }

  String _getSpecialBonus(int level) {
    if (level >= 1 && level <= 10) {
      return level == 5 ? "Nivel 5: +50 monedas" : "Completa 10 niveles";
    } else if (level >= 11 && level <= 20) {
      return level == 10 ? "Nivel 10: Avatar exclusivo" : "Completa 20 niveles";
    } else if (level >= 21 && level <= 50) {
      return level == 25 ? "Nivel 25: +150 monedas" : "Avanza más";
    } else if (level >= 51 && level <= 80) {
      return level == 50 ? "Insignia dorada" : "Sigue acumulando XP";
    } else if (level >= 81 && level <= 100) {
      return level == 100 ? "Trofeo virtual" : "Casi llegas a 100";
    } else {
      return "Empieza desde el nivel 1";
    }
  }

  @override
  Widget build(BuildContext context) {
    final neededXp = LevelProgressWidget.calculateXpForNextLevel(_level);
    final progress = neededXp == 0 ? 0.0 : _xpTotal / neededXp;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(181, 0, 0, 0), // Fondo gris oscuro
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/boton.png',
                width: 20,
                height: 20,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(width: 10),
              Text(
                "Nivel: $_level",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Image.asset(
                    'assets/images/probarback.png',
                    width: double.infinity,
                    height: 65,
                    fit: BoxFit.fitWidth,
                  ),
                  ClipRect(
                    clipper: ProgressRectClipper(progress: progress),
                    child: Image.asset(
                      'assets/images/progressfilll.png',
                      width: double.infinity,
                      height: 56,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$_xpTotal / $neededXp XP",
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Image.asset('assets/icons/coin.png', width: 22, height: 22),
              SizedBox(width: 8),
              Text(
                "$_coins Coins",
                style: TextStyle(
                  color: Colors.amber,
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          Text(
            _bonusMessage,
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontFamily: 'Fredoka',
              fontSize: 16,
            ),
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