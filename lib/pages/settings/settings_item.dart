import 'package:flutter/material.dart';

class SettingsItem {
  final String title;
  final Widget icon;

  const SettingsItem({
    required this.title,
    required this.icon,
  });

  static final textToSpeech = SettingsItem(
    title: "Text-To-Speech",
    icon: SizedBox(
      height: 40,
      child: Image.asset(
        'assets/icons/text-to-speech.png',
      ),
    ),
  );

  static final colorBlindness = SettingsItem(
    title: "Colour Blindness",
    icon: SizedBox(
      height: 40,
      child: Image.asset(
        'assets/icons/color-blindness.png',
      ),
    ),
  );

  static const accountDeletion = SettingsItem(
    title: "Delete Account Permanently.",
    icon: Icon(
      Icons.delete_forever,
      size: 40,
    ),
  );

  static final List<SettingsItem> all = [
    textToSpeech,
    colorBlindness,
    accountDeletion,
  ];
}
