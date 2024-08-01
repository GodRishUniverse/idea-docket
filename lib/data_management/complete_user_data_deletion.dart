import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CompleteUserDataDeletion {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get the user's events collection

  Future<void> deleteAllStorageDataForUser() async {
    try {
      User? user = _auth.currentUser;
      Reference refDir = _storage.ref().child('users/${user!.uid}');

      try {
        await deleteAll(refDir);
        log("User storage data deleted successfully");
      } catch (e) {
        log("Error deleting user storage data: $e");
      }
    } catch (e) {
      log(e.toString());
      // Show some error
    }
  }

  // Recursive function to delete all files and directories
  Future<void> deleteAll(Reference ref) async {
    ListResult listResult = await ref.listAll();

    // Delete all files
    for (Reference fileRef in listResult.items) {
      await fileRef.delete();
    }

    // Recursively delete all subdirectories
    for (Reference dirRef in listResult.prefixes) {
      await deleteAll(dirRef);
    }
  }

  Future<void> deleteAllDatabaseDataForUser() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    WriteBatch batch = _firestore.batch();

    DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

    // Add the user's document to the batch delete
    batch.delete(userDocRef);

    // Get all sub-collections and their documents
    List<String> subCollections = ['notes', 'events'];
    for (String subCollection in subCollections) {
      QuerySnapshot subCollectionSnapshot =
          await userDocRef.collection(subCollection).get();
      for (QueryDocumentSnapshot doc in subCollectionSnapshot.docs) {
        batch.delete(doc.reference);
      }
    }

    // Commit the batch delete
    try {
      await batch.commit();
      log("User data and sub-collections deleted successfully");
    } catch (e) {
      log("Error deleting user data and sub-collections: $e");
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      await deleteAllDatabaseDataForUser();
      await deleteAllStorageDataForUser();

      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      log(e.toString());

      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      log(e.toString());
      // Handle general exception
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData = _auth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }

      await deleteAllDatabaseDataForUser();
      await deleteAllStorageDataForUser();

      await _auth.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }
}
