import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_notes_crud_and_search.dart';
import 'package:idea_docket/models/note_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrashedNoteCard extends StatefulWidget {
  final Note note;
  const TrashedNoteCard({super.key, required this.note});

  @override
  State<TrashedNoteCard> createState() => _TrashedNoteCardState();
}

class _TrashedNoteCardState extends State<TrashedNoteCard> {
  FirestoreService firestoreService = FirestoreService();

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    super.initState();
    initColourBlindnessIndex();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final deletedTime = widget.note.deletedTime!;

    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorBlindness(
          Color(widget.note.colorOfTile),
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Deleted on ${DateFormat.yMMMd().format(deletedTime.toDate())}",
              style: TextStyle(
                color: blackUsed.withOpacity(0.9),
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.note.title,
              style: const TextStyle(
                color: blackUsed,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      firestoreService.restoreFromTrash(widget.note.docID!);
                    },
                    icon: Tooltip(
                      message: "Restore Note From Trash",
                      child: Icon(
                        Icons.restore_from_trash,
                        color: colorBlindness(
                          blueForDrawer,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        size: 25,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      firestoreService.permanentlyDelete(widget.note.docID!);
                    },
                    icon: Tooltip(
                      message: "Permanently Delete",
                      child: Icon(
                        Icons.delete,
                        color: colorBlindness(
                          blueForDrawer,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
