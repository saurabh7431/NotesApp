import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesapp/features/notes/models/note.dart';

class NotesService {
  NotesService._();

  static final NotesService instance = NotesService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _notesCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not authenticated');
    }

    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  Stream<List<Note>> watchNotes() {
    return _notesCollection()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Note.fromDocument(doc))
              .toList(growable: false),
        );
  }

  Future<void> saveNote(Note note) async {
    final now = DateTime.now();
    final payload = note.saveToFirestore(now);

    try {
      if (note.id == null) {
        await _notesCollection().add(payload);
      } else {
        await _notesCollection().doc(note.id).set(payload, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      throw e.message ?? 'Could not save the note, please try again later.';
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _notesCollection().doc(id).delete();
    } on FirebaseException catch (e) {
      throw e.message ?? 'Unable to delete the note.';
    }
  }

  Future<void> togglePin(Note note) {
    if (note.id == null) return Future.value();
    return saveNote(
      note.copyWith(isPinned: !note.isPinned),
    );
  }
}
