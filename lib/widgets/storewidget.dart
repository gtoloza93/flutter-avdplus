import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreWidget extends StatelessWidget {
  const StoreWidget({super.key});

  // Lista de avatares con sus propiedades (incluyendo color)
  final List<Map<String, dynamic>> availableAvatars = const [
    {
      'image': 'assets/icons/astronauta.png',
      'price': 100,
      'color': Color(0xFF94E6F7),
      'name': 'Explorador',
    },
    {
      'image': 'assets/icons/momia.png',
      'price': 150,
      'color': Color(0xFFA594F7),
      'name': 'Magico',
    },
    {
      'image': 'assets/icons/piloto.png',
      'price': 200,
      'color': Color(0xFFF794E5),
      'name': 'Piloto',
    },
    {
      'image': 'assets/icons/mecanico.png',
      'price': 250,
      'color': Color(0xFFF7E594),
      'name': 'Autonomo',
    },
    {
      'image': 'assets/icons/asesino.png',
      'price': 300,
      'color': Color(0xFF94F7A5),
      'name': 'Ninja',
    },
    {
      'image': 'assets/icons/hacker.png',
      'price': 500,
      'color': Color(0xFFF7B794),
      'name': 'Hacker',
    },
  ];

  Future<void> _buyAvatar(BuildContext context, Map<String, dynamic> avatar) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final price = avatar['price'] as int;
    
    try {
      // Usamos transacción para asegurar consistencia
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);
        final currentCoins = doc.get('coins') ?? 0;

        if (currentCoins >= price) {
          // Actualizamos todos los datos necesarios
          transaction.update(userRef, {
            'coins': FieldValue.increment(-price),
            'unlockedAvatars': FieldValue.arrayUnion([avatar['image']]),
            'avatarColors': FieldValue.arrayUnion([{
              'image': avatar['image'],
              'color': avatar['color'].value.toString(),
            }])
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡${avatar['name']} comprado!'),
              backgroundColor: Colors.green,
            )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Necesitas ${price - currentCoins} coins más'),
              backgroundColor: Colors.red,
            )
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la tienda
          Row(
            children: [
              Image.asset(
                'assets/icons/boton.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => Icon(Icons.shopping_cart, color: Colors.amber),
              ),
              const SizedBox(width: 10),
              const Text(
                "Tienda",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/icons/tienda.png',
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) => Icon(Icons.store, color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Sección de avatares disponibles
          SizedBox(
            height: 110,
            child: StreamBuilder<DocumentSnapshot>(
              stream: user != null 
                  ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData || user == null) {
                  return const Center(
                    child: Text(
                      "Inicia sesión para ver la tienda",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                final currentCoins = userData?['coins'] ?? 0;
                final unlockedAvatars = List<String>.from(userData?['unlockedAvatars'] ?? []);

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = availableAvatars[index];
                    final isUnlocked = unlockedAvatars.contains(avatar['image']);

                    return GestureDetector(
                      onTap: () => isUnlocked ? null : _buyAvatar(context, avatar),
                      child: Container(
                        width: 70,
                       
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: avatar['color'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      avatar['image'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 36),
                                    ),
                                  ),
                                ),
                                if (isUnlocked)
                                  const Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(Icons.check_circle, color: Colors.green, size: 24),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              avatar['name'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            
                            Text(
                              isUnlocked ? 'Obtenido' : '${avatar['price']} coins',
                              style: TextStyle(
                                color: isUnlocked ? Colors.green : Colors.amber,
                                fontFamily: 'Fredoka',
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
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
    );
  }
}