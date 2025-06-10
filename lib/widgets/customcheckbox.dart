import 'package:flutter/material.dart';

class CustomCheckboxImage extends StatelessWidget {
  final String emptyPath;
  final String checkmarkPath;
  final bool isChecked;
  final ValueChanged<bool?>? onTap;

  const CustomCheckboxImage({
    super.key,
    required this.emptyPath,
    required this.checkmarkPath,
    this.isChecked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(!isChecked); // Cambia de true a false
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Imagen base (checkbox vacío)
          Image.asset(
            emptyPath,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),

          // Imagen del check encima (solo si está marcado)
          if (isChecked)
            Image.asset(
              checkmarkPath,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}