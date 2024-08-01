import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_notes_crud_and_search.dart';
import 'package:idea_docket/models/note_model.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageToNote extends StatefulWidget {
  const ImageToNote({super.key});

  @override
  State<ImageToNote> createState() => _ImageToNoteState();
}

class _ImageToNoteState extends State<ImageToNote> {
  File? imageFile;
  final picker = ImagePicker();
  late final GenerativeModel model;
  final FirestoreService firestoreService = FirestoreService();

  bool isLoading = false;

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

  Future callGeminiToGetText() async {
    try {
      model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!);
      if (imageFile != null) {
        final imageBytes = await imageFile!.readAsBytes();
        String format = getImageFormat(imageBytes);
        log(format);
        final prompt_1 =
            TextPart("Give this image a title in plain text in 5 words");
        final prompt_2 = TextPart(
            "Generate a JSON formatted for a Quill document on for the contents of the image with no errors, in rich text (take care about colour, bold, italic, underline, markdown, font name, indentation, numbering, bullets and font size). No missing characters or no extra unexpected characters. Do not begin with the 'ops' mark just start with the list. At the end of the json add a last insert with a \\n");
        final imagePart = DataPart("image/$format", imageBytes);
        final response_1 = await model.generateContent([
          Content.multi([prompt_1, imagePart])
        ]);
        log("${response_1.text}");
        final response_2 = await model.generateContent([
          Content.multi([prompt_2, imagePart])
        ]);

        log("${response_2.text}");

        String json = response_2.text!;
        json = json.substring(0, json.length);
        log("new json: $json");

        addNote(
          response_1.text!,
          json,
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Hero(
          tag: "image-to-note",
          child: Material(
            color: colorBlindness(
              blueForDrawer,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Container(
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Use image to make note from:",
                      style: TextStyle(
                        fontFamily: "Gilroy",
                        fontSize: 16,
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 40.0,
                                    color: colorBlindness(
                                      orangeUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    "Gallery",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: colorBlindness(
                                        whiteUsed,
                                        returnColorBlindNessTypeFromIndex(
                                          colourBlindnessIndex,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              onTap: () {
                                _imgFromGallery();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 40.0,
                                      color: colorBlindness(
                                        orangeUsed,
                                        returnColorBlindNessTypeFromIndex(
                                          colourBlindnessIndex,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      "Camera",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorBlindness(
                                          whiteUsed,
                                          returnColorBlindNessTypeFromIndex(
                                            colourBlindnessIndex,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () {
                                _imgFromCamera();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: colorBlindness(
                              const Color.fromARGB(255, 251, 193, 2),
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Warning! Gemini has limitations! Use with care!",
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontSize: 12,
                                color: colorBlindness(
                                  Colors.amber,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _imgFromGallery() async {
    try {
      await picker
          .pickImage(source: ImageSource.gallery, imageQuality: 100)
          .then((value) {
        if (value != null) {
          imageFile = File(value.path);

          callGeminiToGetText();
        }
      });
    } catch (e) {
      log("failed $e");
    }
  }

  _imgFromCamera() async {
    try {
      await picker
          .pickImage(source: ImageSource.camera, imageQuality: 100)
          .then((value) {
        if (value != null) {
          imageFile = File(value.path);

          callGeminiToGetText();
        }
      });
    } catch (e) {
      log("failed $e");
    }
  }

  Future addNote(String title, String jsonString) async {
    int lastId = await firestoreService.getLastStoredValue();
    final note = Note(
      id: lastId + 1,
      title: title,
      contents: jsonString,
      createdTime: Timestamp.now(),
      colorOfTile: getRandomLightColour().value,
    );

    try {
      firestoreService.addNote(note);
    } catch (e) {
      log("error in adding: ${e.toString()}");
    }
  }

  // Function to get image format from bytes
  String getImageFormat(Uint8List bytes) {
    // Check for PNG
    if (bytes.length > 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    // Check for JPG
    if (bytes.length > 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'jpeg';
    }
    return 'unknown';
  }
}
