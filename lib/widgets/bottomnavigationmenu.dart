import 'package:flutter/material.dart';

class BottomNavigationMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavigationMenu({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabTapped,
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/inicio.png'),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/mishabitos.png'),
          label: 'Mis hábitos',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/miprogreso.png'),
          label: 'Progreso',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Premios.png'),
          label: 'Premios',
        ),
      ],
    );
  }
}