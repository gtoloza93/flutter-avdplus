import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:advplus/widgets/customtextfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  BackButton(),
                  Align(
                    alignment: Alignment.center,

                    child: Image.asset(
                      'assets/images/logo.png',
                      width:
                          380, // Puedes cambiar esto para hacerlo más grande o pequeño

                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 0,
                      left: 40,
                    ), // Mueve el texto 20 píxeles a la izquierda
                    child: Text(
                      '¡Convierte el reto en diversión!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    suffixIconPath: 'assets/icons/email.png',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Contraseña',
                    suffixIconPath: 'assets/icons/llave.png',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );
                          Navigator.pushReplacementNamed(context, '/home');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error al iniciar sesión : Contraseña o email erroneo"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: const Color.fromARGB(255, 163, 61, 25),
                        padding: EdgeInsets.symmetric(
                          horizontal: 100,
                          vertical: 5,
                        ),
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

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '');
                      },
                      child: Text(
                        "Recuperar Contraseña",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontFamily: 'Fredoka',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 220),
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

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
