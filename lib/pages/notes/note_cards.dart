import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/models/note_model.dart';
import 'package:intl/intl.dart';

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({
    super.key,
    required this.note,
    required this.index,
    required this.colourBlindnessIndex,
  });

  final Note note;
  final int index;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index

    final time = note.createdTime;
    final minHeight = getMinHeight(index);

    return Card(
      color: colorBlindness(
        Color(note.colorOfTile),
        returnColorBlindNessTypeFromIndex(
          colourBlindnessIndex,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMd().format(time.toDate()),
                style: TextStyle(color: blackUsed.withOpacity(0.8)),
              ),
              const SizedBox(height: 4),
              Text(
                note.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }
}
