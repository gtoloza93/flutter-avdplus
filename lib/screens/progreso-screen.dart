import 'package:advplus/widgets/customprogressdia.dart';
import 'package:advplus/widgets/customprogresssem.dart';
import 'package:advplus/widgets/levelprogresswidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:advplus/widgets/profilewidget.dart';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {

  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos iniciales
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final snapshot = await userDocRef.get();

    if (!snapshot.exists) {
      // 👇 Si el usuario no existe → lo creamos con valores por defecto
      await userDocRef.set({
        'username': user.email?.split('@')[0] ?? 'Usuario',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'xpTotal': 0,
        'level': 1,
        'coins': 0,
      });
    } else {
      setState(() {
      });
    }

    // 👇 Escuchar cambios en tiempo real usando StreamBuilder
    userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    // ❌ Eliminado: .forEach(...) que llamaba a setState fuera de contexto seguro
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Inicia sesión para ver tu progreso")),
      );
    }

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
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(211, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/progreso.png',
                      width: 25,
                      height: 25,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Mi Progreso :",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // 👇 LevelProgressWidget escucha automáticamente los cambios
              LevelProgressWidget(),

              // 👇 Progreso diario
              CustomProgressDia(),

              SizedBox(height: 5),

              // 👇 Progreso semanal
              CustomProgressSem(),
            ],
          ),
        ),
      ),
    );
  }
}