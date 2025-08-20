import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_note_app/note_model.dart';
import 'package:firebase_note_app/services/firestore.dart';
import 'package:firebase_note_app/user_header.dart';
import 'package:flutter/material.dart';

class LoggedIn extends StatefulWidget {
  const LoggedIn({super.key});

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  final controller = TextEditingController();
  late final FirestoreService fireService;

  @override
  void initState() {
    super.initState();
    getUserData();
    fireService = FirestoreService(
        notes: userCollection.doc(user.uid).collection('notes'));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Map userdata = {};
  Future getUserData() async {
    // final QuerySnapshot getData = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: user.email).limit(1).get();
    final DocumentSnapshot getData = await userCollection.doc(user.uid).get();
    if (mounted) {
      // Check if the widget is still in the tree
      if (getData.exists) {
        setState(() {
          userdata = getData.data() as Map;
        });
      }
    }
    
  }

  void openNoteBox({NoteModel? notemodel}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (notemodel == null) {
                      fireService.addnote(controller.text);
                    } else {
                      fireService.updateNote(notemodel, controller.text);
                    }
                    controller.clear();
                    Navigator.of(context).pop();
                  },
                  child: notemodel == null ? const Text('Add') : const Text('Edit'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            UserHeader(
                userdata: userdata,
                onPressed: () => FirebaseAuth.instance.signOut()),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: fireService.getnotesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List noteList = snapshot.data!.docs;
                    
                    if (noteList.isNotEmpty) {
                      return ListView.builder(
                          itemCount: noteList.length,
                          itemBuilder: (context, index) {
                            
                            final noteText = noteList[index].data()['note'] as String? ?? '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 10),
                              child: ListTile(
                                title: Text(noteText),
                                tileColor: Colors.blueGrey[700],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                textColor: Colors.white,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // edit button
                                    IconButton(
                                      onPressed: () =>
                                          openNoteBox(notemodel: noteList[index]),
                                      icon: const Icon(
                                        Icons.mode_edit_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // delete button
                                    IconButton(
                                      onPressed: () =>
                                          fireService.deleteNote(noteList[index]),
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Center(child: Text('No data'));
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
