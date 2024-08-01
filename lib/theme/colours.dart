import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'dart:math';

ColorBlindnessType returnColorBlindNessTypeFromIndex(int index) {
  switch (index) {
    case 1:
      return ColorBlindnessType.protanomaly;
    case 2:
      return ColorBlindnessType.deuteranomaly;
    case 3:
      return ColorBlindnessType.tritanomaly;
    case 4:
      return ColorBlindnessType.protanopia;
    case 5:
      return ColorBlindnessType.deuteranopia;
    case 6:
      return ColorBlindnessType.tritanopia;
    case 7:
      return ColorBlindnessType.achromatopsia;
    case 8:
      return ColorBlindnessType.achromatomaly;
    default:
      return ColorBlindnessType.none;
  }
}

const Color whiteUsed = Color.fromARGB(255, 239, 241, 242);
const Color orangeUsed = Color.fromARGB(255, 223, 85, 41);
const Color blueUsedInLinks = Color.fromARGB(255, 34, 151, 240);
const Color greyUsed = Color.fromARGB(255, 46, 46, 53);
const Color redUsed = Color.fromARGB(255, 201, 18, 15);
const Color blackUsed = Color.fromARGB(255, 11, 11, 11);
const Color blueForDrawer = Color.fromARGB(255, 24, 33, 58);
const Color greyUsedOpacityLowered = Color.fromARGB(55, 46, 46, 53);
const Color redUsedForLogOut = Color.fromARGB(255, 117, 6, 4);
const Color darkBackground = Color.fromARGB(255, 26, 27, 34);
const Color noteBackground = Color.fromARGB(255, 237, 207, 170);
const Color lightGrey = Color.fromARGB(255, 147, 152, 155);

final switchColors = [
  redUsed,
  Colors.green,
  Colors.redAccent,
  Colors.greenAccent
];

final lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100,
  Colors.blueGrey.shade200,
  Colors.cyanAccent.shade100,
  Colors.lime.shade200,
  const Color.fromARGB(255, 204, 117, 220),
  Colors.yellow.shade200,
  Colors.red.shade200,
  Colors.purple.shade200,
  Colors.indigo.shade200,
  Colors.deepPurple.shade100,
  Colors.greenAccent.shade100,
  Colors.lightGreenAccent.shade100,
  Colors.orangeAccent.shade100,
  Colors.brown.shade200,
  Colors.deepOrange.shade100,
  Colors.grey.shade300,
  const Color.fromARGB(255, 173, 216, 230), // Light Blue (RGB)
  const Color.fromARGB(255, 255, 182, 193), // Light Pink (RGB)
  const Color.fromARGB(255, 144, 238, 144), // Light Green (RGB)
  const Color.fromARGB(255, 255, 160, 122), // Light Salmon (RGB)
  const Color.fromARGB(255, 250, 128, 114), // Salmon (RGB)
  const Color.fromARGB(255, 255, 228, 181), // Moccasin (RGB)
  const Color.fromARGB(255, 255, 222, 173), // Navajo White (RGB)
];

Color getRandomLightColour() {
  final random = Random();

  return lightColors[random.nextInt(lightColors.length)];
}
