import 'package:firebase_note_app/auth/login_page.dart';
import 'package:firebase_note_app/note_model.dart';
import 'package:firebase_note_app/services/objectbox_storage.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

class OfflineHomePage extends StatefulWidget {
  final Store store;
  const OfflineHomePage({super.key, required this.store});

  @override
  State<OfflineHomePage> createState() => _OfflineHomePageState();
}

class _OfflineHomePageState extends State<OfflineHomePage> {
  final _controller = TextEditingController();
  late final ObjectBoxStorageService objectboxService;

  @override
  void initState() {
    super.initState();
    objectboxService = ObjectBoxStorageService(widget.store);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void openNoteBox({NoteModel? notemodel}) {
    if (notemodel != null) {
      _controller.text = notemodel.note;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _controller,
                autocorrect: true,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (notemodel == null) {
                      objectboxService.addnote(_controller.text);
                    } else {
                      objectboxService.updateNote(notemodel, _controller.text);
                    }
                    _controller.clear();
                    Navigator.of(context).pop();
                  },
                  child: notemodel == null
                      ? const Text('Add')
                      : const Text('Edit'),
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
        appBar: AppBar(
          title: const Text('Offline Notes'),
          actions: [
            // Add a buttton to navigate tot he login page
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(store: widget.store,),
                    ),
                  );
                },
                child: Icon(Icons.login),),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<NoteModel>>(
                  stream: objectboxService.getnotesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final noteList = snapshot.data!;

                    if (noteList.isNotEmpty) {
                      return ListView.builder(
                          itemCount: noteList.length,
                          itemBuilder: (context, index) {
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 10),
                              child: ListTile(
                                title: Text(noteList[index].note),
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
                                          objectboxService.deleteNote(noteList[index]),
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
