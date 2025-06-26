import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarNotifier extends ChangeNotifier {
  String? _currentAvatar;
  Color? _currentAvatarColor;

  String? get currentAvatar => _currentAvatar;
  Color? get currentAvatarColor => _currentAvatarColor;

  void updateAvatar(String newAvatar, Color newColor) {
    _currentAvatar = newAvatar;
    _currentAvatarColor = newColor;
    notifyListeners();
  }
}

class AvatarCollections extends StatefulWidget {
  final AvatarNotifier avatarNotifier;

  const AvatarCollections({super.key, required this.avatarNotifier});

  @override
  State<AvatarCollections> createState() => _AvatarCollectionsState();
}

class _AvatarCollectionsState extends State<AvatarCollections> {
  late String selectedAvatar;
  late Color selectedAvatarColor;
  bool _isLoading = true;
  final List<String> defaultAvatars = [
    'assets/icons/avatar1.png',
    'assets/icons/avatar2.png',
    'assets/icons/avatar3.png',
    'assets/icons/avatar4.png',
    'assets/icons/avatar5.png',
    'assets/icons/user.png',
  ];
  List<Map<String, dynamic>> unlockedAvatars = [];

  @override
  void initState() {
    super.initState();
    selectedAvatarColor = Colors.grey[800]!;
    widget.avatarNotifier.addListener(_handleAvatarChange);
    _loadInitialData();
  }

  void _handleAvatarChange() {
    if (mounted) {
      setState(() {
        selectedAvatar = widget.avatarNotifier.currentAvatar ?? 'assets/icons/user.png';
        selectedAvatarColor = widget.avatarNotifier.currentAvatarColor ?? Colors.grey[800]!;
      });
    }
  }

  @override
  void dispose() {
    widget.avatarNotifier.removeListener(_handleAvatarChange);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = doc.data();
      
      List<dynamic> avatarColorsData = userData?['avatarColors'] ?? [];
      List<Map<String, dynamic>> parsedAvatars = [];
      
      for (var item in avatarColorsData) {
        if (item is Map<String, dynamic>) {
          parsedAvatars.add({
            'image': item['image'] ?? '',
            'color': item['color'] != null 
              ? Color(int.parse(item['color'].toString())) 
              : Colors.grey[800]!,
          });
        }
      }

      if (mounted) {
        setState(() {
          selectedAvatar = doc.get('avatar') ?? 'assets/icons/user.png';
          // Buscar el color correspondiente al avatar seleccionado
          final selectedAvatarData = [...defaultAvatars.map((e) => {'image': e, 'color': Colors.grey[800]!}), ...parsedAvatars]
              .firstWhere((avatar) => avatar['image'] == selectedAvatar, orElse: () => {'color': Colors.grey[800]!});
          selectedAvatarColor = selectedAvatarData['color'];
          unlockedAvatars = parsedAvatars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          selectedAvatar = 'assets/icons/user.png';
          selectedAvatarColor = Colors.grey[800]!;
          _isLoading = false;
        });
      }
      debugPrint('Error loading avatar: $e');
    }
  }

  Future<void> _saveAvatar(String newAvatar, Color newColor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatar': newAvatar,
        'avatarColor': newColor.value.toString(), // Guardamos el valor del color
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.amber));
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(211, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/Premios.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Recompensas",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            int coins = 0;
                            if (snapshot.hasData) {
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>?;
                              coins = data?['coins'] ?? 0;
                            }
                            return Row(
                              children: [
                                Image.asset(
                                  'assets/icons/coin.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.fitWidth,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "$coins Coins",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Fredoka',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<String>(selectedAvatar),
                        width: 115,
                        height: 115,
                        decoration: BoxDecoration(
                          color: selectedAvatarColor, // Usamos el color guardado
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:  Colors.amber,
                            width: 5,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Image.asset(
                            selectedAvatar,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/icons/user.png',
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(
                      "Mi Avatar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    SizedBox(
                      height: 70,
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<Map<String, dynamic>> allAvatars = [
                                  ...defaultAvatars.map((e) => {'image': e, 'color': Colors.grey[800]!}),
                                  ...unlockedAvatars,
                                ];

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: allAvatars.length,
                                  itemBuilder: (context, index) {
                                    final avatar = allAvatars[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        final newAvatar = avatar['image'];
                                        final newColor = avatar['color'];
                                        widget.avatarNotifier.updateAvatar(newAvatar, newColor);
                                        await _saveAvatar(newAvatar, newColor);
                                      },
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: avatar['color'],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color:
                                                selectedAvatar == avatar['image']
                                                    ? Colors.amber
                                                    : Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Image.asset(
                                            avatar['image'],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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
    );
  }
}