import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class NotificationWidget extends StatefulWidget {
  final String userId;

  const NotificationWidget({
    super.key,
    required this.userId,
    required navigatorKey,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  late AudioPlayer _audioPlayer;
  bool _isActiveNotification = false;
  Timer? _notificationTimer;
  Map<String, dynamic>? _currentHabit;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _checkTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPeriodicCheck() {
    // Verifica cada 5 segundos para mayor precisión
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForActiveHabits();
    });
  }

  Future<void> _checkForActiveHabits() async {
    try {
      final now = DateTime.now();
      final habitsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('habits')
              .where('completed', isEqualTo: false)
              .get();

      final activeHabits =
          habitsSnapshot.docs
              .map((doc) => doc.data())
              .where((h) => _isHabitDueNow(h, now))
              .toList();

      if (activeHabits.isNotEmpty && !_isActiveNotification) {
        _showTemporaryNotification(activeHabits.first);
      }
    } catch (e) {
      debugPrint('Error checking habits: $e');
    }
  }

  void _showTemporaryNotification(Map<String, dynamic> habit) {
    setState(() {
      _isActiveNotification = true;
      _currentHabit = habit;
    });

    _playNotificationSound();

    // Programa el regreso al estado normal después de 15 segundos
    _notificationTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isActiveNotification = false;
          _currentHabit = null;
        });
      }
      _stopNotificationSound();
    });
  }

  bool _isHabitDueNow(Map<String, dynamic> habit, DateTime now) {
    final startTimeStr = habit['startTime'] as String? ?? '--:--';
    final habitTime = _parseTimeString(startTimeStr);
    if (habitTime == null) return false;

    final habitDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      habitTime.hour,
      habitTime.minute,
    );

    // Verifica si está dentro del periodo de activación (primer minuto)
    return now.isAfter(habitDateTime) &&
        now.isBefore(habitDateTime.add(const Duration(minutes: 1)));
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/alert.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _stopNotificationSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  Future<void> _markHabitAsCompleted() async {
    if (_currentHabit == null || _currentHabit!['id'] == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('habits')
          .doc(_currentHabit!['id'])
          .update({
            'completed': true,
            'lastCompleted': FieldValue.serverTimestamp(),
          });

      _notificationTimer?.cancel();
      await _stopNotificationSound();
      setState(() {
        _isActiveNotification = false;
        _currentHabit = null;
      });
    } catch (e) {
      debugPrint('Error marking habit as completed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotificationContainer(
      child:
          _isActiveNotification && _currentHabit != null
              ? GestureDetector(
                onTap: _markHabitAsCompleted,
                child: Row(
                  children: [
                    // Círculo redondo (viñeta)
                    Container(
                      width: 10, // Diámetro del círculo
                      height: 10, // Diámetro del círculo
                      margin: const EdgeInsets.only(
                        right: 8,
                      ), // Espacio entre el círculo y el texto
                      decoration: BoxDecoration(
                        color: Colors.white, // Color del círculo
                        shape: BoxShape.circle, // Forma circular
                      ),
                    ),
                    // Texto de la notificación
                    Expanded(
                      child: Text(
                        "${_currentHabit!['name']} a las ${_currentHabit!['startTime']}",
                        style: _notificationTextStyle(
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Text(
                "No hay notificaciones ",
                style: _notificationTextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                ).copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.bold, fontSize : 14,),
              ),
    );
  }

  Widget _buildNotificationContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(205, 82, 25, 25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/notifi_icon.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  TextStyle _notificationTextStyle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      color: color ?? Colors.white,
      fontFamily: 'Fredoka',
      fontSize: 16,
      fontWeight: fontWeight,
    );
  }

  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }
}
