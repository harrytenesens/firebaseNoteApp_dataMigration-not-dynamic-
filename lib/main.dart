import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_note_app/firebase_options.dart';
import 'package:firebase_note_app/auth/login_check.dart';
import 'package:firebase_note_app/objectbox.g.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //objectbox setup
  final store = await openStore();
  runApp( MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store store;
  const  MyApp({super.key, required this.store});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  LogInCheck(store: store),
    );
  }
}