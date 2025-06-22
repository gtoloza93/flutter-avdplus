import 'package:advplus/widgets/rewarddisplay.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para fechas formateadas

class EditHabitWidget extends StatefulWidget {
  final Map<String, dynamic> habit;

  const EditHabitWidget({super.key, required this.habit});

  @override
  State<EditHabitWidget> createState() => _EditHabitWidgetState();
}

class _EditHabitWidgetState extends State<EditHabitWidget> {
  late TextEditingController _nameController;
  late String _frequency;
  late String _difficulty;
  late TimeOfDay _startTime;
  late DateTime? _startDate;
  late DateTime? _endDate;

  int get xpToShow {
    if (_frequency == 'DIARIO') {
      switch (_difficulty) {
        case 'FÁCIL':
          return 15;
        case 'INTERMEDIO':
          return 35;
        case 'DIFÍCIL':
          return 70;
        default:
          return 15;
      }
    } else {
      switch (_difficulty) {
        case 'FÁCIL':
          return 90;
        case 'INTERMEDIO':
          return 180;
        case 'DIFÍCIL':
          return 360;
        default:
          return 90;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Cargar datos del hábito desde Firebase
    _nameController = TextEditingController(text: widget.habit['name'] ?? '');

    _frequency = widget.habit['frequency'] ?? 'DIARIO';
    _difficulty = widget.habit['difficulty'] ?? 'FÁCIL';

    // Parsea startTime (String)
    final startTimeStr = widget.habit['startTime'] ?? '08:00';
    final timeParts = startTimeStr.split(':');
    _startTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 8,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );

    // Parsea fechas
    _startDate = _parseDate(widget.habit['startDate']);
    _endDate = _parseDate(widget.habit['endDate']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return null;
      }
    }
    if (date is DateTime) return date;
    return null;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (newTime != null) {
      setState(() {
        _startTime = newTime;
      });
    }
  }

  Future<void> _saveHabitToFirebase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final habitRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('habits')
        .doc(widget.habit['id']);

    await habitRef.update({
      'name': _nameController.text.trim(),
      'frequency': _frequency,
      'difficulty': _difficulty,
      'startTime': '${_startTime.hour}:${_startTime.minute}',
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'xp': xpToShow, // Actualiza XP según frecuencia y dificultad
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Hábito actualizado"),
        backgroundColor: Colors.amber[700],
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de nombre
              Text(
                "Nombre del Hábito",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return "El nombre no puede estar vacío";
                  }
                  return null;
                },
                style: TextStyle(color: Colors.white, fontFamily: 'Fredoka'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 30, 30, 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Ej: Tomar agua",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Fredoka',
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Frecuencia
              Text(
                "Frecuencia",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              Row(
                children:
                    ['DIARIO', 'SEMANAL'].map((freq) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _frequency = freq),
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _frequency == freq
                                      ? Colors.amber.withOpacity(0.2)
                                      : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                freq,
                                style: TextStyle(
                                  color:
                                      _frequency == freq
                                          ? Colors.amber
                                          : Colors.white,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              SizedBox(height: 16),

              // Dificultad
              Text(
                "Dificultad",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              Row(
                children:
                    ['FÁCIL', 'INTERMEDIO', 'DIFÍCIL'].map((diff) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _difficulty = diff),
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _difficulty == diff
                                      ? Colors.amber.withOpacity(0.2)
                                      : Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                diff,
                                style: TextStyle(
                                  color:
                                      _difficulty == diff
                                          ? Colors.amber
                                          : Colors.white,
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              SizedBox(height: 16),

              // Hora de inicio
              Text(
                "Hora de Inicio",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectStartTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_startTime.format(context)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Fecha de inicio
              Text(
                "Fecha de Inicio",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _startDate != null
                            ? DateFormat('dd/MM/yyyy').format(_startDate!)
                            : "Selecciona fecha",
                        style: TextStyle(
                          color:
                              _startDate != null
                                  ? Colors.white
                                  : Colors.grey[500],
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Fecha de fin
              Text(
                "Fecha de Fin",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Fredoka',
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDate != null
                            ? DateFormat('dd/MM/yyyy').format(_endDate!)
                            : "Selecciona fecha",
                        style: TextStyle(
                          color:
                              _endDate != null
                                  ? Colors.white
                                  : Colors.grey[500],
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Muestra la recompensa dinámica
              RewardDisplay(
                frequency: _frequency,
                difficulty: _difficulty,
                xp: xpToShow,
              ),

              SizedBox(height: 24),

              // Botón para guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _saveHabitToFirebase(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/edit.png', width: 24, height: 24),
                    SizedBox(width: 10),
                    Text(
                      "Guardar Cambios",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
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
    );
  }
}
