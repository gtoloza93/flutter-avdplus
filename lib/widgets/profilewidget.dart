import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String? _username;

  int _level = 1;
  int _coins = 0; // Inicializamos en 0 por defecto

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      // 👇 Si el usuario no existe → créalo con todos los campos necesarios
      await userDocRef.set({
        'username': user.email?.split('@')[0] ?? 'Usuario',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'xpTotal': 0,
        'level': 1,
        'coins': 0,
      });

      setState(() {
        _username = user.email?.split('@')[0] ?? 'Usuario';
        _level = 1;
        _coins = 0;
      });
    } else {
      final data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _username = data['username'] ?? user.email?.split('@')[0] ?? 'Usuario';
        _level = data['level'] ?? 1;
        _coins = data['coins'] ?? 0;
      });
    }
  }

  Future<void> _mostrarCalendario(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Fecha seleccionada: ${DateFormat('dd/MM/yyyy').format(picked)}",
          ),
          backgroundColor: Colors.amber[700],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          220,
          0,
          0,
          0,
        ), // Fondo negro semi-transparente
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 👈 Imagen de perfil editable
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Función de edición de foto no implementada aún",
                  ),
                  backgroundColor: Colors.amber[700],
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 29, // Esto controla el tamaño del círculo
                  backgroundColor:
                      const Color.fromARGB(255, 241, 166, 2), // Color de fondo del CircleAvatar
                  child: SizedBox(
                    width: 36, // Ancho de la imagen
                    height: 36, // Alto de la imagen
                    child: Image.asset(
                      'assets/icons/user.png',
                      fit:
                          BoxFit
                              .contain, // Ajusta la imagen dentro del contenedor
                    ),
                  ),
                ),

                // Icono de lápiz encima de la imagen
              ],
            ),
          ),

          SizedBox(width: 16),

          // 👇 Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "¡Hola, $_username!",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),
                // 👉 Monedas + Nivel
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/coin.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "$_coins",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 6),
                    Text(
                      "Niv: $_level",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10),

          // 👉 Botón para abrir calendario
          GestureDetector(
            onTap: () => _mostrarCalendario(context),
            child: Row(
              
              children: [
                Text(
                      "Hoy",
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                Column(
                  children: [
                    
                    Image.asset(
                      'assets/icons/calendario.png', // Tu icono de calendario
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
