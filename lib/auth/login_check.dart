import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/logged_in.dart';

import 'package:firebase_note_app/objectbox.g.dart';
import 'package:firebase_note_app/offline_homescreen.dart';
import 'package:flutter/material.dart';

class LogInCheck extends StatelessWidget {
  const LogInCheck({super.key, required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const LoggedIn();
            } else {
              return OfflineHomePage(store: store);
            }
          }),
    );
  }
}
