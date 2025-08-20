import 'package:objectbox/objectbox.dart';

@Entity()
class NoteModel {
  @Id()
  int id;

  String note;

  @Property(type: PropertyType.date)
  DateTime timestamp;

  String? firebaseDocId;

  NoteModel({
    this.id = 0,
    required this.note,
    required this.timestamp,
    this.firebaseDocId,
  });

  // Factory constructor for Firebase DocumentSnapshot
  factory NoteModel.fromFirestore(dynamic doc) {
    return NoteModel(
      note: doc.data()['note'] ?? '',
      timestamp: doc.data()['timestamp'].toDate() ?? DateTime.now(),
      firebaseDocId: doc.id,
    );
  }
  // Convert to Map for Firebase (without IDs)
  Map<String, dynamic> toFirestore(){
    return {
      'note': note,
      'timestamp': timestamp,
    };
  }
   // Helper methods for different ID types

  // String get displayId => firebaseDocId ?? id.toString();
  // bool get isFirebaseNote => firebaseDocId != null;
  // bool get isOfflineNote => firebaseDocId == null;

  String displayId(){
    return firebaseDocId ?? id.toString();
  }

  bool isFirebaseNote(){
    return firebaseDocId != null;
  }

  bool isOfflineNote(){
    return firebaseDocId == null;
  }
}

