import 'package:firebase_note_app/note_model.dart';

abstract class StorageService {
  Future<NoteModel> addnote(String note);

  Stream<List<NoteModel>> getnotesStream();

  Future<void> updateNote(NoteModel note, String newNoteText);

  Future<void> deleteNote(NoteModel note);

// MIGRATION: Get all notes for data transfer
  Future<List<NoteModel>> getAllnotes();

  Future<void> clearAllData();
}