import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:idea_docket/models/repetitions_model.dart';

class Event {
  final String? docID;
  final int id;
  final String title;
  final String description;
  final Timestamp date;
  final Timestamp dateWithStartTime;

  final Timestamp dateWithEndTime;
  final Color color;

  Repetitions? repetitions = Repetitions(choices: RepeatChoices.doesNotRepeat);

  Event({
    this.docID,
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.dateWithStartTime,
    required this.dateWithEndTime,
    required this.color,
    this.repetitions,
  });
}
