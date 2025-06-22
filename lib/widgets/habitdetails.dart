import 'package:advplus/widgets/edithabitwidget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HabitDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> habit;

  const HabitDetailsScreen({super.key, required this.habit});

  void _mostrarCalendario(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Aquí puedes manejar la fecha seleccionada
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return "No definida";

    if (date is Timestamp) {
      final DateTime dateTime = date.toDate();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (date is String) {
      // Si es una cadena con formato de fecha
      try {
        final parsedDate = DateTime.tryParse(date);
        if (parsedDate != null) {
          return DateFormat('dd/MM/yyyy').format(parsedDate);
        }
      } catch (e) {}
    }

    return "----";
  }

  Future<bool?> showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              "Eliminar Hábito",
              style: TextStyle(color: Colors.amber),
            ),
            content: Text(
              "¿Estás seguro de que quieres eliminar este hábito?",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text("Cancelar", style: TextStyle(color: Colors.amber)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("Eliminar", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background.jpg',
            ), // Fondo imagen general
            fit: BoxFit.cover,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(15.0),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 35),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        179,
                        0,
                        0,
                        0,
                      ), // Fondo gris transparente
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Para separar los elementos
                      children: [
                        // Parte izquierda (Botón de retroceso y título)
                        Row(
                          children: [
                            BackButton(),
                            Text(
                              "Detalles del Habito:",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Parte derecha (Imagen con texto para calendario)
                        GestureDetector(
                          onTap: () {
                            _mostrarCalendario(
                              context,
                            ); // Asegúrate de tener esta función implementada
                          },
                          child: Row(
                            children: [
                              Text(
                                "Hoy",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ), // Espacio entre texto e imagen
                              Image.asset(
                                'assets/icons/calendario.png', // Asegúrate de tener esta imagen en tus assets
                                width: 34,
                                height: 34,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 👇 Contenedor con todo el formulario dentro de BoxDecoration gris
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(113, 0, 0, 0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 👇 Nombre del Hábito
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Nombre del hábito:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        initialValue: habit['name'] ?? "Sin nombre",
                        enabled: false, // 🔒 No editable
                        style: TextStyle(
                          color: const Color.fromARGB(197, 255, 255, 255),
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: "Ej: Tomar agua",
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 0, 0, 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          isDense: true,
                          constraints: BoxConstraints(maxWidth: 350),
                        ),
                      ),

                      SizedBox(height: 5),

                      // 👇 Frecuencia
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Frecuencia:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          Text(
                            habit['frequency'] ?? "Desconocida",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // 👇 Horario
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Hora:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          Text(
                            habit['startTime'] ?? "--:--",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // 👇 Fecha Inicio
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Fecha inicio:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(habit['startDate']),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // 👇 Fecha Fin
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Fecha fin:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          Text(
                            _formatDate(habit['endDate']),
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // 👇 Recordatorio
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Recordatorio:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: null, // Botón deshabilitado
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  habit['reminder'] == true
                                      ? Colors.amber[700]
                                      : const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              habit['reminder'] == true ? "SI" : "NO",
                              style: TextStyle(
                                color:
                                    !habit['reminder']
                                        ? Colors.white
                                        : const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // 👇 Dificultad
                      Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: true,
                            onChanged: (_) {},
                            activeColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Dificultad:",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontFamily: 'Fredoka',
                            ),
                          ),
                          Spacer(),
                          Text(
                            habit['difficulty'] ?? "No definida",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),
                    ],
                  ),
                ),

                Align(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        221,
                        0,
                        0,
                        0,
                      ), // Fondo gris transparente
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
                            fontSize: 18,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "${habit['xp'] ?? 0} XP",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 👇 Botones: Editar y Eliminar Hábito
                SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botón para EDITAR el hábito
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(223, 2, 2, 2),
                            foregroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Navegar a AddHabitScreen con los datos del hábito para editar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditHabitWidget(habit: habit),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/edit.png',
                                width: 34,
                                height: 34,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Editar",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 10),

                        // Botón para ELIMINAR el hámito
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(233, 2, 2, 2),
                            foregroundColor: Colors.amber,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            // Mostrar diálogo de confirmación
                            final action = await showDeleteDialog(context);
                            if (action == true) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('habits')
                                    .doc(habit['id'])
                                    .delete();

                                // Mostrar mensaje de éxito
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Hábito eliminado correctamente",
                                    ),
                                    backgroundColor: Colors.red[800],
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );

                                Navigator.pop(
                                  context,
                                ); // Regresar a pantalla anterior
                              }
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/eliminar.png',
                                width: 34,
                                height: 34,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Eliminar",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
