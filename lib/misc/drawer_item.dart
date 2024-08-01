import 'package:flutter/material.dart';
import 'package:idea_docket/theme/colours.dart';

class DrawerItem {
  final String title;
  final Icon icon;

  const DrawerItem({
    required this.title,
    required this.icon,
  });

  static const notes = DrawerItem(
    title: "Notes",
    icon: Icon(
      Icons.notes_rounded,
      color: orangeUsed,
      size: 24,
    ),
  );

  static const events = DrawerItem(
    title: "Events",
    icon: Icon(
      Icons.event,
      color: orangeUsed,
      size: 24,
    ),
  );

  static const settings = DrawerItem(
    title: "Settings",
    icon: Icon(
      Icons.settings,
      color: orangeUsed,
      size: 24,
    ),
  );

  static final List<DrawerItem> all = [
    notes,
    events,
    settings,
  ];
}
