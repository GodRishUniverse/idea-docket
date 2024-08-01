import 'package:flutter/material.dart';

class Message {
  final String text;
  final String userPrompt;
  final Image? image;
  final bool isUser;

  Message({
    required this.text,
    required this.isUser,
    required this.userPrompt,
    this.image,
  });
}
