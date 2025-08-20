import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_note_app/note_model.dart';


class FirestoreService  {
  // get collection of notes
  final CollectionReference notes;

  FirestoreService({required this.notes});
  // CREATE: add new note
  
  Future<NoteModel> addnote(String note) async {
    final docRef = await notes.add({
      'note': note,
      'timestamp': Timestamp.now(),
    });

    return NoteModel(
        note: note, timestamp: DateTime.now(), firebaseDocId: docRef.id);
  }

  // READ: get notes from database

  // @override
  // Stream<List<NoteModel>> getnotesStream(){
  // Query orderedQuery = notes.orderBy('timestamp', descending: true);

  // Stream<List<NoteModel>> notesScream = orderedQuery.snapshots().map((snapshot){
  //   List<NoteModel> notesList = [];
  //   for (QueryDocumentSnapshot doc in snapshot.docs) {
  //     NoteModel note = NoteModel.fromFirestore(doc);
  //     notesList.add(note);
  //   }
  //   return notesList;
  // });

  //   return notesScream;
  // }

  Stream<QuerySnapshot> getnotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // Update: editing and updating the note

  Future updateNote(NoteModel note, String newNoteText) async {
    if (note.firebaseDocId == null) {
      throw ArgumentError('can note update without id');
    }
    await notes.doc(note.firebaseDocId).update({
      'note': newNoteText,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE: delete notes from given doc id

  Future deleteNote(NoteModel note) async {
    await notes.doc(note.firebaseDocId).delete();
  }

// MIGRATION: Get all notes for data transfer

  Future<List<NoteModel>> getAllnotes() async {
    final snapshot = await notes.get();
    return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  Future<void> clearAllData() async {
    final snapshot = await notes.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
