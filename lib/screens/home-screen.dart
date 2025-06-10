import 'package:flutter/material.dart';
import 'dart:async'; // Para Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:advplus/widgets/habitcounter.dart';
import 'package:advplus/widgets/customprogressbar.dart';
import 'package:advplus/widgets/habitlist.dart';
import 'package:advplus/utils/localquoteprovider.dart';
import 'package:advplus/widgets/motivationalquote.dart';
import 'package:advplus/widgets/habitcountersem.dart';
import 'package:advplus/widgets/bottomnavigationmenu.dart';
import 'package:advplus/screens/habits-screen.dart';
import 'package:advplus/screens/progreso-screen.dart';
import 'package:advplus/screens/rewards-screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<QuerySnapshot> habitsStream;
  List<Map<String, dynamic>> habits = []; // 👈 Definimos aquí `habits`
  int completedHabits = 0;

  String? _quote;
  late Timer _timer;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 🔁 Carga hábitos desde Firestore
      habitsStream =
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('habits')
              .snapshots();
    }

    _loadRandomQuote();
    _startQuoteTimer();
  }

  Future<void> updateHabitInFirebase(String habitDocId, bool? value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitDocId)
        .update({
          'completed': value ?? false,
          'lastCompleted': value ?? false ? FieldValue.serverTimestamp() : null,
        });
  }

  Future<void> _loadRandomQuote() async {
    try {
      final quote = await LocalQuoteProvider.getRandomQuote();
      setState(() {
        _quote = quote;
      });
    } catch (e) {
      setState(() {
        _quote = "Hoy es un buen día para avanzar";
      });
    }
  }

  void _startQuoteTimer() {
    const duration = Duration(minutes: 5);
    _timer = Timer.periodic(duration, (timer) {
      _loadRandomQuote(); // Recarga frase cada hora
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Función para actualizar estado del hábito en Firebase
  void updateHabit(int index, bool? value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || index < 0 || index >= habits.length) {
      print("Índice inválido: $index");
      return;
    }

    final habitDocId = habits[index]['id'];

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitDocId)
        .update({'completed': value ?? false});
  }

  Widget _buildHomeContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotivationalQuote(
          quote: _quote ?? "Cargando frase...",
          iconPath: 'assets/icons/quote.png',
        ),
        SizedBox(height: 5),
        CustomProgressBar(), // Puedes calcular progreso real si quieres
        SizedBox(height: 16),
        HabitCounter(),
        SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: habitsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final habitDocs = snapshot.data!.docs;

              // Filtra los hábitos SEMANALES
              final dailyHabits =
                  habitDocs.where((doc) => doc['frequency'] == 'DIARIO').map((
                    doc,
                  ) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    data['xp'] = data['xp'] ?? 0;
                    return data;
                  }).toList();

              return HabitList(
                habits: dailyHabits,
                onCheck: (index, value) {
                  if (index >= 0 && index < dailyHabits.length) {
                    updateHabitInFirebase(dailyHabits[index]['id'], value);
                  }
                },
              );
            },
          ),
        ),
        SizedBox(height: 16),
        HabitCounterSem(),
        SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: habitsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final habitDocs = snapshot.data!.docs;

              // Filtra los hábitos SEMANALES
              final weeklyHabits =
                  habitDocs.where((doc) => doc['frequency'] == 'SEMANAL').map((
                    doc,
                  ) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    data['xp'] = data['xp'] ?? 0;
                    return data;
                  }).toList();

              return HabitList(
                habits: weeklyHabits,
                onCheck: (index, value) {
                  if (index >= 0 && index < weeklyHabits.length) {
                    updateHabitInFirebase(weeklyHabits[index]['id'], value);
                  }
                },
              );
            },
          ),
        ),

        Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/addhabit');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 248, 178, 16),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              padding: EdgeInsets.symmetric(horizontal:  15, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/añdirhabits.png'),
                SizedBox(width: 10),
                Text(
                  "Añadir Hábito",
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget get _currentScreen {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(context); // Inicio
      case 1:
        return HabitsScreen(); // Hábitos
      case 2:
        return ProgresoScreen(); // Progreso
      case 3:
        return RewardsScreen(); // Premios
      default:
        return _buildHomeContent(context);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background.jpg',
            ), // 👈 Tu imagen de fondo
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.0), // 👈 Sombra opcional
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _currentScreen,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationMenu(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}
