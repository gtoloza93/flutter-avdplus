import 'dart:math';

import 'package:advplus/widgets/customprogressbar.dart';
import 'package:advplus/widgets/habititem.dart';
import 'package:advplus/widgets/notificationwidget.dart';
import 'package:advplus/widgets/profilewidget.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Para Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:advplus/widgets/habitcounter.dart';

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
      HabitItem.scheduleDailyReset(); // ✅ Reinicio automático de hábitos diarios
      HabitItem.scheduleWeeklyReset(); // ✅ Reinicio de hábitos semanales
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

  DateTime? _parseDate(dynamic date) {
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

  Future<void> updateHabitInFirebase(String habitDocId, bool? value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(habitDocId);

    final habitSnapshot = await habitRef.get();
    final habitData = habitSnapshot.data() ?? {};
    final xp = habitData['xp'] ?? 0;

    final userDataRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final userDataSnapshot = await userDataRef.get();
    final currentXp =
        (userDataSnapshot.data() as Map<String, dynamic>)['xpTotal'] ?? 0;

    if (value == true && !(habitData['completed'] ?? false)) {
      await habitRef.update({
        'completed': true,
        'lastCompleted': FieldValue.serverTimestamp(),
      });

      final newXpTotal = currentXp + xp;
      await userDataRef.update({'xpTotal': newXpTotal});
    } else if (value == false && (habitData['completed'] ?? false)) {
      await habitRef.update({'completed': false, 'lastCompleted': null});

      final newXpTotal = max(currentXp - xp, 0);
      await userDataRef.update({'xpTotal': newXpTotal});
    }
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

  Widget _buildHomeContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileWidget(),
        SizedBox(height: 0),
        // 👇 Notificación con sonido de hábito próximo
        if (FirebaseAuth.instance.currentUser != null)
          NotificationWidget(
            userId: FirebaseAuth.instance.currentUser!.uid,
            navigatorKey: null,
          ),

        SizedBox(height: 0),

        MotivationalQuote(
          quote: _quote ?? "Cargando frase...",
          iconPath: 'assets/icons/quote.png',
        ),
        SizedBox(height: 5),

       CustomProgressBar(),

        SizedBox(height: 15),
        HabitCounter(),
        SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: habitsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final habitDocs =
                  snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id;
                    return data;
                  }).toList();

              final today = DateTime.now();
              final dailyHabits =
                  habitDocs.where((habit) {
                    final frequency = habit['frequency'] ?? '';
                    final startDate = _parseDate(habit['startDate']);
                    final endDate = _parseDate(habit['endDate']);

                    final activeToday =
                        frequency == 'DIARIO' &&
                        (startDate == null || !startDate.isAfter(today)) &&
                        (endDate == null || !endDate.isBefore(today));

                    return activeToday;
                  }).toList();

              return HabitList(
                habits: dailyHabits,
                onCheck: (index, value) {
                  if (index >= 0 && index < dailyHabits.length) {
                    final habit = dailyHabits[index];
                    updateHabitInFirebase(habit['id'], value);
                  }
                },
              );
            },
          ),
        ),
        SizedBox(height: 5),
        HabitCounterSem(),
        SizedBox(height: 10),
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

        SizedBox(height: 10),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/addhabit');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 248, 178, 16),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/añdirhabits.png'),
                SizedBox(width: 5),
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
