import 'dart:convert';
import 'dart:developer';

import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/misc/snack_bar.dart';

import 'package:idea_docket/models/note_model.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewTrashedNotes extends StatefulWidget {
  final Note note;

  const ViewTrashedNotes({
    super.key,
    required this.note,
  });

  @override
  State<ViewTrashedNotes> createState() => _ViewTrashedNotesState();
}

class _ViewTrashedNotesState extends State<ViewTrashedNotes> {
  final quill.QuillController controller = quill.QuillController.basic();
  TextEditingController controllerForTitle = TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  final GenerativeModel model = GenerativeModel(
      model: 'gemini-pro', apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!);
  late final String jsonString;
  bool isLoading = false;
  bool isTTSEnabledForUser = false;
  late final String formattedDate;

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      controller.readOnly = true;
      controllerForTitle.text = widget.note.title;
      final json = jsonDecode(widget.note.contents);
      jsonString = json.toString();

      controller.document = quill.Document.fromJson(json);
    } catch (e) {
      showSnackBarError(context, "Internal Error: ${e.toString()}");
    }
    formattedDate =
        DateFormat.yMMMMd().format(widget.note.createdTime.toDate());
    getSettings();
    isTTSEnabled();

    initColourBlindnessIndex();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void dispose() {
    controller.dispose();
    controllerForTitle.dispose();
    stop();
    super.dispose();
  }

  Future<String> callGeminiToGetTextForSpeech() async {
    setState(() => isLoading = true);
    try {
      log(jsonString);

      //TODO: add shared state for text to speech
      final prompt =
          " Analyse the string correctly and do not return any explaination or markdown - only the text that will be displayed to the user when they open the flutter quill editor using the below Flutter Quill JSON. Also if in the above text there is a codeblock or in-line code present then try to write 'Explaination: ' and explain the code after typing it. The explaination should not be long. Also if there is an image or video present then just type Image present or video present where they are present. If there is some error the return a string with the error that is in layman terms. The Flutter Quill Json is as follows: $jsonString.";

      final response = await model.generateContent([Content.text(prompt)]);

      log("${response.text}");
      setState(() => isLoading = false);

      return response.text!;
    } catch (e) {
      log(e.toString());
      setState(() => isLoading = false);
      return "Problem in converting note to text - limitation of Google Gemini 1.5 Pro.";
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final speechRate =
        prefs.getDouble('speechRate') ?? 0.5; // Default to 1.0 if not found
    final volume =
        prefs.getDouble('volume') ?? 1.0; // Default to 1.0 if not found
    final pitch =
        prefs.getDouble('pitch') ?? 1.0; // Default to 1.0 if not found
    final language = prefs.getString('languageUsed') ?? 'en-US';

    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(language);

    setState(() {});
  }

  void isTTSEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('textToSpeechEnabled') ?? false;
    setState(() {
      isTTSEnabledForUser = isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Hero(
          tag: widget.note.docID.toString(),
          child: Material(
            color: colorBlindness(
              Color(widget.note.colorOfTile),
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                    ),
                    child: Center(
                      child: Visibility(
                        visible: isTTSEnabledForUser,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final textToSpeak =
                                  await callGeminiToGetTextForSpeech();
                              await speak(
                                  "Title of this note is: ${widget.note.title}. This note was created on $formattedDate.  $textToSpeak");
                            },
                            icon: Tooltip(
                              message: "Convert the note to speech",
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 35,
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                            color: colorBlindness(
                                              orangeUsed,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            ),
                                          )
                                        : Image.asset(
                                            "assets/icons/text-to-speech-icon.png",
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Speak the note",
                                    style: TextStyle(
                                      color: blackUsed,
                                      fontFamily: "Gilroy",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      readOnly: true,
                      controller: controllerForTitle,
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        fontFamily: "GilroyBold",
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: quill.QuillEditor(
                        configurations: quill.QuillEditorConfigurations(
                          controller: controller,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          padding: const EdgeInsets.all(8),
                          scrollable: true,
                          autoFocus: false,
                          expands: false,
                          showCursor: false,
                        ),
                        focusNode: FocusNode(),
                        scrollController: ScrollController(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
