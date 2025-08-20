import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/auth/forgot_page.dart';
import 'package:firebase_note_app/auth/register_page.dart';
import 'package:firebase_note_app/note_model.dart';
import 'package:firebase_note_app/objectbox.g.dart';
import 'package:firebase_note_app/services/objectbox_storage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Store store;
  const LoginPage({super.key, required this.store});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // controllers
  final emailController = TextEditingController();
  final passswordController = TextEditingController();
  bool _isloading = false;
// custom message method
  void _customSnackbar({required String text}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // Reusable migration
  Future<void> _migrateData(User user) async {
    final objectboxService = ObjectBoxStorageService(widget.store);
    final List<NoteModel> localNotes = await objectboxService.getAllnotes();

    // If there's nothing to migrate, just exit
    if (localNotes.isEmpty) {
      return;
    }

    _customSnackbar(text: 'Migrating offline notes..');

    final firestoreNotesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes');

    // Use a batch write for efficiency
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    for (final note in localNotes) {
      final docRef = firestoreNotesCollection.doc();
      batch.set(docRef, note.toFirestore());
    }
    await batch.commit();

    // after successful migration, clear the local database
    await objectboxService.clearAllData();
  }

  //sign in method
  Future signIn() async {
    final objectboxService = ObjectBoxStorageService(widget.store);
    setState(() {
      _isloading = true;
    });
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passswordController.text.trim(),
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Do you want to add Offline data?'),
          actions: [
            TextButton(
                onPressed: () {
                  _migrateData(credential.user!);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Yes',
                )),
            TextButton(
                onPressed: () {
                  credential.user!;
                   objectboxService.clearAllData();
                  Navigator.of(context).pop();
                },
                child: const Text('No'))
          ],
        ),
      );

      if (mounted) {
        // This removes the login page from the screen
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isloading = false;
      });
      _customSnackbar(text: e.message.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: _isloading == true
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // welcome text
                      const Text(
                        'Welcome to your Adventure!',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 8, 49, 110)),
                      ),
                      const SizedBox(height: 25),
                      // email section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Your Email',
                              ),
                            ),
                          ),
                        ),
                      ),
                      // passoword textfield
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: TextField(
                              controller: passswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Password',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      // forgot passowrd
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotPass(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      // sign in button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: ElevatedButton(
                          onPressed: () => signIn(),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13)),
                            minimumSize: const Size(double.infinity, 60),
                            backgroundColor:
                                const Color.fromARGB(255, 8, 49, 110),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 17),
                      // register button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Not a memeber?',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(
                                    store: widget.store,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              ' Register now',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
