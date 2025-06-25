import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NextRewards extends StatelessWidget {
  const NextRewards({super.key});

  String _getRewardDescription(int level) {
    if (level == 5) return "+50 monedas";
    if (level == 10) return "Avatar exclusivo";
    if (level == 25) return "+150 monedas";
    if (level == 50) return "Insignia dorada";
    if (level == 100) return "Trofeo virtual";
    return "+20 monedas";
  }

  List<Map<String, dynamic>> _getRewardsToShow(int currentLevel) {
    List<Map<String, dynamic>> allRewards = [];
    
    // Generamos recompensas para los próximos 10 niveles
    for (int i = 1; i <= 10; i++) {
      final level = currentLevel + i;
      allRewards.add({
        'level': level,
        'reward': _getRewardDescription(level),
        'isMilestone': [5, 10, 25, 50, 100].contains(level),
      });
    }
    
    // Filtramos para mostrar:
    // - Los últimos 2 niveles alcanzados (si existen)
    // - Las próximas 3 recompensas
    final achieved = currentLevel > 1 
        ? List.generate(2, (i) => currentLevel - 1 - i)
            .where((l) => l > 0)
            .map((level) => {
              'level': level,
              'reward': _getRewardDescription(level),
              'isMilestone': [5, 10, 25, 50, 100].contains(level),
              'achieved': true,
            }).toList()
        : [];
    
    final upcoming = allRewards.take(3).toList();
    
    // Combinamos y ordenamos
    return [...achieved.reversed, ...upcoming];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null 
          ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
          : null,
      builder: (context, snapshot) {
        if (!snapshot.hasData || user == null) {
          return _buildPlaceholder();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final currentLevel = userData?['level'] as int? ?? 1;
        final rewards = _getRewardsToShow(currentLevel);

        return Container(
          height: 170,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Image.asset(
                    'assets/icons/boton.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (_, __, ___) => const Icon(Icons.help_outline, color: Colors.amber),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Próximas recompensas",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/icons/gift.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (_, __, ___) => const Icon(Icons.help_outline, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              
              // Lista de recompensas con scroll
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final isAchieved = reward['achieved'] == true || currentLevel >= reward['level'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Checkbox con checkmark si está alcanzado
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/checkbox.png',
                                width: 28,
                                height: 28,
                                errorBuilder: (_, __, ___) => const Icon(Icons.check_box_outline_blank, size: 28, color: Colors.grey),
                              ),
                              if (isAchieved)
                                Image.asset(
                                  'assets/icons/checkmark.png',
                                  width: 16,
                                  height: 16,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.check, size: 16, color: Colors.green),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Nivel ${reward['level']}",
                            style: TextStyle(
                              color: isAchieved ? Colors.green : Colors.white,
                              fontSize: 16,
                              fontFamily: 'Fredoka',
                              decoration: isAchieved ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            reward['reward'],
                            style: TextStyle(
                              color: isAchieved 
                                  ? Colors.green 
                                  : (reward['isMilestone'] ? Colors.amber : Colors.white),
                              fontSize: 16,
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                              decoration: isAchieved ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: const Text(
        "Inicia sesión para ver tus próximas recompensas",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Fredoka',
        ),
      ),
    );
  }
}