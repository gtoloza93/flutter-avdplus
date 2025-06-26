import 'package:advplus/widgets/avatarcollections.dart';
import 'package:advplus/widgets/edithabitwidget.dart';
import 'package:advplus/widgets/responsivewrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:advplus/screens/welcome-screen.dart';
import 'package:advplus/screens/login-screen.dart';
import 'package:advplus/screens/register-screen.dart';
import 'package:advplus/screens/home-screen.dart';
import 'package:advplus/screens/addhabits-screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

  runApp(
    ResponsiveWrapper(
      designWidth: 360,
      designHeight: 640,
      child: ChangeNotifierProvider(
        create: (context) => AvatarNotifier(),
        child: const MyApp(),
      ),
    ),
  );
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
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Fredoka')),
      ),
      // SOLUCIÓN: Usa routes en lugar de onGenerateRoute con initialRoute
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/addhabit': (context) => const AddHabitScreen(),
        '/edithabit': (context) => EditHabitWidget(habit: {}),
      },
      initialRoute: '/welcome',
    );
  }
}