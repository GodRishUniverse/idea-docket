import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadMedia(XFile file) async {
    User? user = auth.currentUser;
    Reference refDirImages =
        storage.ref().child('users/${user!.uid}/multimedia');

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference ref = refDirImages.child(uniqueFileName);

    try {
      UploadTask uploadTask = ref.putFile(File(file.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      // on Success:
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      // Show some error
      return null;
    }
  }

  static Future<void> deleteFile(String fileURL) async {
    try {
      Reference ref = storage.refFromURL(fileURL);
      await ref.delete();
    } catch (e) {
      log('Error deleting file: $e');
    }
  }

  Future<String?> uploadAttachmentFile(File file) async {
    User? user = auth.currentUser;
    Reference refDir = storage.ref().child('users/${user!.uid}/files');

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference ref = refDir.child(uniqueFileName);

    try {
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      // on Success:
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      // Show some error
      return null;
    }
  }

  static Future<String> getFileType(String url) async {
    try {
      final ref = storage.refFromURL(url);
      final metadata = await ref.getMetadata();
      return metadata.contentType!;
    } catch (e) {
      return "file-type-error";
    }
  }

  static Future<String> getFileName(String url) async {
    try {
      Uri uri = Uri.parse(url);
      String fileName = uri.pathSegments.last;
      return fileName;
    } catch (e) {
      return "file-name-error";
    }
  }
}
