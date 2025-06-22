import 'package:flutter/material.dart';

class MotivationalQuote extends StatelessWidget {
  final String quote;
  final String iconPath;

  const MotivationalQuote({
    super.key,
    required this.quote,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Empuja el texto a la derecha
            children: [
              Image.asset(iconPath, width: 30, height: 30, fit: BoxFit.contain),
              SizedBox(width: 10),
              Text(
                "Frase Motivadora.",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // 👇 Icono + Frase en fila
          Wrap(
            alignment: WrapAlignment.spaceBetween, // Centra el texto
            children: [
              Text(
                '"$quote"',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fredoka',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
