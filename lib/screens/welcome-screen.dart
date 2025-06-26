import 'package:flutter/material.dart';
import 'package:advplus/screens/login-screen.dart';
import 'package:advplus/screens/register-screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // 👈 Ahora comienza desde arriba
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 105,
              ), // Ajusta este valor para subir o bajar el contenido
              // Logo - Centralizado horizontalmente
              Align(
                alignment: Alignment.centerRight,

                child: Image.asset(
                  'assets/images/logo.png',
                  width:
                      365, // Puedes cambiar esto para hacerlo más grande o pequeño

                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 0), // Espacio entre logo y texto
              // Texto motivacional
              Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  left: 65,
                ), // Mueve el texto 20 píxeles a la izquierda
                child: Text(
                  '¡Convierte el reto en diversión!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 180), // Espacio antes de los botones
              // Botón Registrarse
              Align(
                alignment: Alignment.center, // Mueve el botón a la izquierda
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: const Color.fromARGB(255, 163, 61, 25),
                    padding: EdgeInsets.symmetric(vertical: 17, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "REGISTRARSE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Botón Iniciar Sesión
              Align(
                alignment: Alignment.center, // Mueve el botón a la izquierda
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: const Color.fromARGB(255, 163, 61, 25),
                    padding: EdgeInsets.symmetric(vertical: 17, horizontal: 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "INICIAR SESIÓN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ),
              ),

              SizedBox(height: 230),

              // Pie de página
              Align(
                alignment: Alignment.center,
                child: Text(
                  'By Subgrupo 15',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
