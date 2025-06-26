import 'package:flutter/material.dart';
import 'dart:math'; // Para pow()
import 'package:intl/intl.dart'; // Para fechas
import 'package:advplus/widgets/rewarddisplay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _habitNameController = TextEditingController();
  String _frequency = 'DIARIO';
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _reminder = false;
  String _difficulty = 'DIFÍCIL';

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
      double nivel = difficulty == 'FÁCIL' ? 1 : difficulty == 'INTERMEDIO' ? 2 : 3;
      return (200 * pow(nivel, 1.5).toDouble() + 100).toInt();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  void _mostrarCalendario() async {
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

  @override
  Widget build(BuildContext context) {
    int xpToShow = calculateXP(_frequency, _difficulty);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Esta línea evita que la pantalla se redimensione con el teclado
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
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 15,
            top: 50,
            bottom: 10,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              "Crear Hábito:",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Parte derecha (Imagen con texto para calendario)
                        GestureDetector(
                          onTap: () {
                            // Aquí llamas a tu función para mostrar el calendario
                            _mostrarCalendario(); // Asegúrate de tener esta función implementada
                          },
                          child: Row(
                            children: [
                              Text(
                                "Hoy",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 14,
                                  fontFamily: 'Fredoka',
                                  fontWeight: FontWeight.w600,
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
                SizedBox(height: 0),

                // 👇 Contenedor con todo el formulario dentro de BoxDecoration gris
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          113,
                          0,
                          0,
                          0,
                        ), // Fondo gris transparente
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 👇 Nombre del hábito
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
                              SizedBox(width: 0),
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
                          TextFormField(
                            controller: _habitNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nombre del habito";
                              }
                              return null;
                            },
                            style: TextStyle(
                              color: const Color.fromARGB(197, 255, 255, 255),
                              fontFamily: 'Fredoka',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Ej: Tomar 3lt de agua",
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: const Color.fromARGB(255, 0, 0, 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    10, // Ajusta el ancho interno (izq/der)
                                vertical:
                                    10, // Ajusta el alto interno (arriba/abajo)
                              ),
                              isDense: true, // Reduce el espacio vertical extra
                              constraints: BoxConstraints(
                                maxWidth: 380, // Ancho máximo del campo
                                minHeight: 8, // Altura mínima
                              ),
                            ),
                          ),

                          SizedBox(height: 2),

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
                              SizedBox(width: 0),
                              Text(
                                "Frecuencia :",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                'DIARIO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _frequency = "DIARIO";
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: Text(
                                                'SEMANAL',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _frequency = "SEMANAL";
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    204,
                                    3,
                                    3,
                                    3,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _frequency,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0),

                          // 👇 Hora
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
                              SizedBox(width: 0),
                              Text(
                                "Hora :",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime,
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      _startTime = pickedTime;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _startTime.format(context),
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0),

                          // 👇 Fecha de inicio
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
                              SizedBox(width: 0),
                              Text(
                                "Fecha de Inicio :",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2026),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _startDate = pickedDate;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _startDate != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_startDate!)
                                      : "---",
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0),

                          // 👇 Fecha de fin
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
                              SizedBox(width: 0),
                              Text(
                                "Fecha de Fin:",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(
                                      Duration(days: 7),
                                    ),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2026),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _endDate = pickedDate;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _endDate != null
                                      ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_endDate!)
                                      : "---",
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 0),

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
                              SizedBox(width: 0),
                              Text(
                                "Recordatorio:",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _reminder = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          !_reminder
                                              ? Colors.amber[700]
                                              : Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "NO",
                                      style: TextStyle(
                                        color:
                                            !_reminder
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _reminder = true;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _reminder
                                              ? Colors.amber[700]
                                              : Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "SI",
                                      style: TextStyle(
                                        color:
                                            !_reminder
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 0),

                          // 👇 Nivel de dificultad
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
                              SizedBox(width: 0),
                              Text(
                                "Nivel de Dificultad :",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text(
                                                'FÁCIL',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _difficulty = "FÁCIL";
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: Text(
                                                'INTERMEDIO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _difficulty = "INTERMEDIO";
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              title: Text(
                                                'DIFÍCIL',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Fredoka',
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  _difficulty = "DIFÍCIL";
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _difficulty,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 👇 Recompensa esperada - Fuera del contenedor gris
                SizedBox(height: 0),

                RewardDisplay(frequency: _frequency, difficulty: _difficulty,),

                SizedBox(height: 25),

                // 👇 Botón Guardar Hábito - Al final
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final habitData = {
                          'name': _habitNameController.text.trim(),
                          'frequency': _frequency,
                          'difficulty': _difficulty,
                          'startTime': _formatTime(_startTime),
                          'startDate': _startDate,
                          'endDate': _endDate,
                          'reminder': _reminder,
                          'xp': xpToShow,
                          'completed': false,
                          'createdAt': FieldValue.serverTimestamp(),
                        };

                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('habits')
                              .add(habitData);

                          // 👇 Programa la notificación si está activada
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Hábito guardado con éxito"),
                            backgroundColor: Colors.green[800],
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );

                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(223, 2, 2, 2),
                      foregroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/save.png',
                          width: 34,
                          height: 34,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Guardar",
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 220),
              ],
            ),
          ),
        ),
      ),
    );
  }
}