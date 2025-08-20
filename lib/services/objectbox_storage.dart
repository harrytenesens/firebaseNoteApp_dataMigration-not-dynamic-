import 'package:firebase_note_app/note_model.dart';
import 'package:firebase_note_app/objectbox.g.dart';
import 'package:firebase_note_app/state/storage_service.dart';



class ObjectBoxStorageService implements StorageService {
  late final Box<NoteModel> _noteBox;

  ObjectBoxStorageService(Store store) {
    _noteBox = store.box<NoteModel>();
  }
  //adding note
  @override
  Future<NoteModel> addnote(String note) async {
    // firebaseDocId stays null for offline notes
    final newNote = NoteModel(
      note: note,
      timestamp: DateTime.now(),
    );

    newNote.id = _noteBox.put(newNote); // ObjectBox assigns ID
    return newNote;
  }

  @override
  Stream<List<NoteModel>> getnotesStream() {
    // ObjectBox stream (you'll need to implement this with ObjectBox queries)
    return _noteBox.query()
        .order(NoteModel_.timestamp, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Future<void> updateNote(NoteModel notemodel, String newNoteText) async{
    notemodel.note = newNoteText;
    notemodel.timestamp = DateTime.now();
    _noteBox.put(notemodel);
  }

  @override
  Future<void> deleteNote(NoteModel notemodel) async {
    _noteBox.remove(notemodel.id);
  }

  @override
  Future<List<NoteModel>> getAllnotes() async {
    return _noteBox.getAll();
  }

  @override
  Future<void> clearAllData() async {
    _noteBox.removeAll();
  }
}
