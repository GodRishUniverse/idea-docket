import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idea_docket/data_management/firebase_storage_for_notes.dart';
import 'package:idea_docket/models/note_model.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // get collection of notes
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get the user's notes collection
  CollectionReference get notes {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  // Helper method to get the user's notes collection
  CollectionReference get notesTrash {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notesTrash');
  }
  // CREATE

  Future<void> addNote(Note note) {
    if (note.attachments == null || note.attachments!.isEmpty) {
      return notes.add({
        'id': note.id,
        'title': note.title,
        'contents': note.contents,
        'time': note.createdTime,
        'colorOfTile': note.colorOfTile,
        'attachments': [],
      });
    } else {
      return notes.add({
        'id': note.id,
        'title': note.title,
        'contents': note.contents,
        'time': note.createdTime,
        'colorOfTile': note.colorOfTile,
        'attachments': note.attachments,
      });
    }
  }

  // READ
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream = notes
        .orderBy(
          'time',
          descending: true,
        )
        .snapshots();

    return notesStream;
  }

  // UPDATE

  Future<void> updateNote(String docID, Note updatedNote) async {
    if (updatedNote.attachments == null || updatedNote.attachments!.isEmpty) {
      return notes.doc(docID).update({
        'id': updatedNote.id,
        'title': updatedNote.title,
        'contents': updatedNote.contents,
        'time': updatedNote.createdTime,
        'colorOfTile': updatedNote.colorOfTile,
        'attachments': [],
      });
    } else {
      return notes.doc(docID).update({
        'id': updatedNote.id,
        'title': updatedNote.title,
        'contents': updatedNote.contents,
        'time': updatedNote.createdTime,
        'colorOfTile': updatedNote.colorOfTile,
        'attachments': updatedNote.attachments,
      });
    }
  }

  // DELETE

  Future<void> deleteNote(String docID) async {
    return notes.doc(docID).delete();
  }

  // GET LAST ID TO INCREMENT ON ADD

  Future<int> getLastStoredValue() async {
    QuerySnapshot querySnapshot =
        await notes.orderBy('time', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      var document = querySnapshot.docs.first;
      return document['id'];
    } else {
      return 0;
    }
  }

  // SEARCH

  // Function to search notes by title or contents with local filtering
  Stream<List<DocumentSnapshot>> searchNotes(
      bool searchInTrash, String searchTerm) {
    final lowerCaseSearchTerm = searchTerm.toLowerCase();

    Stream<QuerySnapshot<Object?>> searchStream;

    if (searchInTrash) {
      searchStream = notesTrash.snapshots();
    } else {
      searchStream = notes.snapshots();
    }

    return searchStream.map((querySnapshot) {
      final documents = querySnapshot.docs;
      return documents.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title'] as String? ?? '';
        final contents = data['contents'] as String? ?? '';
        return title.toLowerCase().contains(lowerCaseSearchTerm) ||
            contents.toLowerCase().contains(lowerCaseSearchTerm);
      }).toList();
    });
  }

  // Trash

  // Move note to trash
  Future<void> moveToTrash(String noteId) async {
    await notes.doc(noteId).update({
      "deletedTime": FieldValue.serverTimestamp(),
    });
    DocumentSnapshot noteData = await notes.doc(noteId).get();
    await notesTrash.doc(noteId).set(noteData.data());
    await notes.doc(noteId).delete();
  }

  // Restore note from trash
  Future<void> restoreFromTrash(String noteId) async {
    try {
      DocumentSnapshot noteData = await notesTrash.doc(noteId).get();
      await notes.doc(noteId).set(noteData.data());

      await notes.doc(noteId).update({"deletedTime": FieldValue.delete()});

      await notesTrash.doc(noteId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  // Permanently delete note

  List<String> extractMediaUrls(String content) {
    List<String> mediaUrls = [];
    final decodedContent = jsonDecode(content);

    if (decodedContent is Map<String, dynamic>) {
      for (var op in decodedContent['ops']) {
        if (op['insert'] is Map) {
          if (op['insert']['image'] != null) {
            mediaUrls.add(op['insert']['image']);
          } else if (op['insert']['video'] != null) {
            mediaUrls.add(op['insert']['video']);
          }
        }
      }
    } else if (decodedContent is List) {
      for (var op in decodedContent) {
        if (op['insert'] is Map) {
          if (op['insert']['image'] != null) {
            mediaUrls.add(op['insert']['image']);
          } else if (op['insert']['video'] != null) {
            mediaUrls.add(op['insert']['video']);
          }
        }
      }
    }

    return mediaUrls;
  }

  Future<void> permanentlyDelete(String noteId) async {
    // Permanently deleting image data
    DocumentSnapshot noteData = await notesTrash.doc(noteId).get();
    final data = noteData.data() as Map<String, dynamic>;
    String contents = data['contents'];
    List<String> attachments = List<String>.from(data['attachments']);

    if (attachments.isNotEmpty) {
      for (String url in attachments) {
        await FirebaseStorageService.deleteFile(url);
      }
    }

    List<String> multimediaURLs = extractMediaUrls(contents);

    for (String url in multimediaURLs) {
      await FirebaseStorageService.deleteFile(url);
    }

    await notesTrash.doc(noteId).delete();
  }

  // Get trashed notes
  Stream<QuerySnapshot> getTrashedNotes() {
    return notesTrash.snapshots();
  }

  // get list of attachmentUrls from the note:

  Future<List<String>> getListOfAttachmentUrls(String noteId) async {
    DocumentSnapshot noteData = await notes.doc(noteId).get();
    final data = noteData.data() as Map<String, dynamic>;

    List<String> attachments = List<String>.from(data['attachments']);

    return attachments;
  }
}
