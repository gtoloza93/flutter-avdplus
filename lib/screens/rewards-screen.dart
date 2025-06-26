
import 'package:advplus/widgets/nextrewards.dart';
import 'package:advplus/widgets/storewidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:advplus/widgets/profilewidget.dart';
import 'package:advplus/widgets/avatarcollections.dart';

class RewardsScreen extends StatelessWidget {
   final AvatarNotifier avatarNotifier = AvatarNotifier();

  RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Inicia sesión para ver tus recompensas")),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              ProfileWidget(),
              Expanded(child: AvatarCollections(avatarNotifier: avatarNotifier)),
              
              SizedBox(height: 0),

              NextRewards(),

              SizedBox(height: 0),

              StoreWidget(),
              SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
