import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("Botón de retroceso presionado");
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // 👈 Regresa a la pantalla anterior
        } else {
          debugPrint("No hay pantalla anterior");
        }
      },
      child: Container(
       
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Image.asset(
            'assets/icons/atras.png', // Reemplaza con tu propia imagen
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}