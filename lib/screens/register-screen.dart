import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advplus/widgets/customtextfield.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Registro en Firebase
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Guardar datos en Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'username': googleUser.displayName ?? 'Usuario Google',
              'email': googleUser.email,
              'createdAt': FieldValue.serverTimestamp(),
              'xpTotal': 0,
              'level': 1,
              'coins': 0,
              'habits': [],
              'isGoogleUser': true, // Para identificar usuarios de Google
            }, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar con Google';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Registro en Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Guardar datos adicionales en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'xpTotal': 0, // ✅ Agregamos este campo
            'level': 1, // ✅ Y este también
            'coins': 0, // ✅ Y las monedas
            'habits': [],
          });

      // ✅ Navegación a LoginScreen - Cambio importante aquí
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      String message = "Ocurrió un error desconocido";
      switch (e.code) {
        case 'weak-password':
          message = 'La contraseña es muy débil';
          break;
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          message = 'Correo electrónico inválido';
          break;
        default:
          message = e.message ?? message;
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    BackButton(),

                    // Logo
                    Align(
                      alignment: Alignment.centerRight,

                      child: Image.asset(
                        'assets/images/logo.png',
                        width:
                            400, // Puedes cambiar esto para hacerlo más grande o pequeño

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Frase motivacional
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

                    const SizedBox(height: 30),

                    // Mostrar mensaje de error si existe
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),

                    // Campo Username
                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Username',
                      suffixIconPath: 'assets/icons/user.png',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre de usuario';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Campo Email
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      suffixIconPath: 'assets/icons/email.png',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un correo electrónico';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Campo Contraseña
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Contraseña',
                      suffixIconPath: 'assets/icons/llave.png',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 5),

                    // Confirmar Contraseña
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirmar Contraseña',
                      suffixIconPath: 'assets/icons/llave.png',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Botón Registrar
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: const Color.fromARGB(
                            255,
                            163,
                            61,
                            25,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 112,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                )
                                : Text(
                                  "REGISTRARSE",
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 53,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'REGISTRARSE CON GOOGLE',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 163, 61, 25),
                                fontFamily: 'Fredoka',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón para ir a Login
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          "¿Ya tienes cuenta? Inicia sesión",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontFamily: 'Fredoka',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 150),
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
          ),
        ],
      ),
    );
  }
}
