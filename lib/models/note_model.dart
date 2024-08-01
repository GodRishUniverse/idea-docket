import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? docID;

  final int id;

  final String title;

  final String contents;

  final Timestamp createdTime;

  final int colorOfTile;

  final Timestamp? deletedTime;

  final List<String>? attachments;

  const Note({
    this.docID,
    required this.id,
    required this.title,
    required this.contents,
    required this.createdTime,
    required this.colorOfTile,
    this.deletedTime,
    this.attachments,
  });

  bool get isEmpty => (title.isEmpty &&
      contents.isEmpty &&
      createdTime.toString().isEmpty &&
      colorOfTile.toString().isEmpty &&
      id.toString().isEmpty);

  bool get isNotEmpty => !isEmpty;
}
