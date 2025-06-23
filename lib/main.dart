import 'package:advplus/widgets/edithabitwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:advplus/screens/welcome-screen.dart';
import 'package:advplus/screens/login-screen.dart';
import 'package:advplus/screens/register-screen.dart';
import 'package:advplus/screens/home-screen.dart';
import 'package:advplus/screens/addhabits-screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
    
  );

  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advance+',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Fredoka'),
        ),
      ),
   
      initialRoute: '/welcome', // O '/login' si prefieres
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/welcome':
            return MaterialPageRoute(builder: (_) => WelcomeScreen());

          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());

          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());

          case '/addhabit':
            return MaterialPageRoute(builder: (_) => AddHabitScreen());

          
          case '/edithabit':
            return MaterialPageRoute(builder: (_) => EditHabitWidget(habit: {},));


          default:
            return null;
        }
      },
    );
  }
}