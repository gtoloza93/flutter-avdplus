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
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
     
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 Título arriba de todo
          Text(
            "Frase Reflexion :",
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
            ),
          ),

          SizedBox(height: 8),

          // 👇 Icono + Frase en fila
          Row(
            
            children: [
              // Icono a la izquierda
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),

              SizedBox(width: 5),

              // Frase entre comillas
              Expanded(
               child: Text(
                  '"$quote"',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Fredoka',
                      ),
                   ),
                )
            ],
          ),
        ],
      ),
    );
  }
}