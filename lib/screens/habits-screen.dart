import 'package:advplus/widgets/profilewidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:advplus/widgets/habitlist.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String _filter = 'Activos'; // ACTIVOS, COMPLETADOS, INCOMPLETOS
  final List<String> _filters = ['Activos', 'Completados', 'Incompletos'];

  late Stream<QuerySnapshot> habitsStream;

  int activeCount = 0;
  int completedCount = 0;
  int incompletedCount = 0;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      habitsStream =
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('habits')
              .snapshots();
    }
  }

  Widget _buildFilterButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _filters.map((type) {
              final isActive = type == _filter;

              int count = 0;
              switch (type) {
                case 'Activos':
                  count = activeCount;
                  break;
                case 'Completados':
                  count = completedCount;
                  break;
                case 'Incompletos':
                  count = incompletedCount;
                  break;
                default:
                  count = 0;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filter = type;
                    });
                  },
                  style: ElevatedButton.styleFrom(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: type,
                        groupValue: _filter,
                        onChanged: (value) {
                          setState(() {
                            _filter = value!;
                          });
                        },
                        activeColor: Colors.amber,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        "$type: $count",
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileWidget(),
              SizedBox(height: 5),
              // 👇 Sección con icono + texto
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(211, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/milisthabits.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Mis Hábitos :",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // 👇 Botones con Radio y Contador
              _buildFilterButtons(context),

              SizedBox(height: 10),

              // 👇 Lista de hábitos filtrada
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: habitsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final habitDocs = snapshot.data!.docs;

                    List<Map<String, dynamic>> filteredHabits = [];

                    // Calcula contadores
                    activeCount = habitDocs.length;
                    completedCount =
                        habitDocs
                            .where(
                              (doc) =>
                                  (doc.data()
                                      as Map<String, dynamic>)['completed'] ==
                                  true,
                            )
                            .length;
                    incompletedCount = activeCount - completedCount;

                    final today = DateTime.now();

                    switch (_filter) {
                      case 'Activos':
                        filteredHabits =
                            habitDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              data['id'] = doc.id;
                              return data;
                            }).toList();
                        break;

                      case 'Completados':
                        filteredHabits =
                            habitDocs
                                .map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  data['id'] = doc.id;
                                  return data;
                                })
                                .where((h) => h['completed'] == true)
                                .toList();
                        break;

                      case 'Incompletos':
                        filteredHabits =
                            habitDocs
                                .map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  data['id'] = doc.id;
                                  return data;
                                })
                                .where((h) => h['completed'] != true)
                                .toList();
                        break;
                      default:
                        filteredHabits =
                            habitDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              data['id'] = doc.id;
                              return data;
                            }).toList();
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 10,
                        bottom: 80,
                      ), // Ajusta este valor según necesites
                      child: HabitList(
                        habits: filteredHabits,
                        onCheck: (index, value) {
                          // Aquí va tu lógica de update en Firebase
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),

              // 👇 Botón para añadir nuevo hábito
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/addhabit');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(214, 3, 3, 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          " Iniciar un nuevo hábito",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Fredoka',
                          ),
                        ),
                        SizedBox(height: 10),
                        Image.asset(
                          'assets/icons/añdirhabits.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
