import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:advplus/widgets/avatarcollections.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String? _username;
  int _level = 1;
  int _coins = 0;
  String? _avatarPath;
  Color _avatarColor = Colors.grey[800]!;
  bool _isLoading = true;
  late AvatarNotifier _avatarNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _avatarNotifier = Provider.of<AvatarNotifier>(context, listen: false);
    if (_isLoading) {
      _avatarNotifier.addListener(_updateAvatar);
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _avatarNotifier.removeListener(_updateAvatar);
    super.dispose();
  }

  void _updateAvatar() {
    if (mounted) {
      setState(() {
        _avatarPath = _avatarNotifier.currentAvatar;
        _avatarColor = _avatarNotifier.currentAvatarColor ?? Colors.grey[800]!;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserDocument(user);
      }

      final data = userDoc.data();

      if (mounted) {
        setState(() {
          _username = data?['username'] ?? user.email?.split('@')[0] ?? 'Usuario';
          _level = data?['level'] ?? 1;
          _coins = data?['coins'] ?? 0;
          _avatarPath = (data?['avatar']?.toString().isNotEmpty ?? false)
              ? data!['avatar']
              : 'assets/icons/user.png';
          _avatarColor = data?['avatarColor'] != null
              ? Color(int.parse(data!['avatarColor'].toString()))
              : Colors.grey[800]!;
          _isLoading = false;
        });
        
        _avatarNotifier.updateAvatar(_avatarPath!, _avatarColor);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _avatarPath = 'assets/icons/user.png';
          _avatarColor = Colors.grey[800]!;
          _isLoading = false;
        });
      }
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _createUserDocument(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'username': user.email?.split('@')[0] ?? 'Usuario',
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'xpTotal': 0,
      'level': 1,
      'coins': 0,
      'avatar': 'assets/icons/user.png',
      'avatarColor': Colors.grey[800]!.value.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingProfile();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      margin: EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 0, 0, 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Implementación modificada del Avatar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: CircleAvatar(
              key: ValueKey<String>(_avatarPath ?? 'default'),
              radius: 26,
              backgroundColor: _avatarColor,
              child: _buildSafeAvatarImage(),
            ),
          ),

          SizedBox(width: 16),

          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "¡Hola, $_username!",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
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
                    SizedBox(width: 8),
                    Text(
                      "Niv: $_level",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Fredoka',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Botón de calendario
          GestureDetector(
            onTap: () => _mostrarCalendario(context),
            child: Row(
              children: [
                Text(
                  "Hoy",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    Image.asset(
                      'assets/icons/calendario.png',
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

  // Nuevo método para manejar la carga segura de imágenes
  Widget _buildSafeAvatarImage() {
    final defaultAvatar = Image.asset(
      'assets/icons/user.png',
      fit: BoxFit.contain,
    );
    
    if (_avatarPath == null || _avatarPath!.isEmpty) {
      return defaultAvatar;
    }

    try {
      return Image.asset(
        _avatarPath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => defaultAvatar,
      );
    } catch (e) {
      return defaultAvatar;
    }
  }

  Widget _buildLoadingProfile() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 0, 0, 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[800],
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                color: Colors.amber,
                strokeWidth: 2,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 18, color: Colors.grey[800]),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(width: 20, height: 20, color: Colors.grey[800]),
                    SizedBox(width: 6),
                    Container(width: 40, height: 14, color: Colors.grey[800]),
                    SizedBox(width: 6),
                    Container(width: 50, height: 16, color: Colors.grey[800]),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 80, height: 34, color: Colors.grey[800]),
        ],
      ),
    );
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
}