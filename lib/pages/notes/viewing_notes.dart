import 'dart:convert';
import 'dart:developer';

import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_notes_crud_and_search.dart';
import 'package:idea_docket/misc/snack_bar.dart';

import 'package:idea_docket/models/note_model.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:idea_docket/pages/notes/add_and_update_notes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesViewingScreen extends StatefulWidget {
  final Note note;

  const NotesViewingScreen({
    super.key,
    required this.note,
  });

  @override
  State<NotesViewingScreen> createState() => _NotesViewingScreenState();
}

class _NotesViewingScreenState extends State<NotesViewingScreen> {
  final quill.QuillController controller = quill.QuillController.basic();
  TextEditingController controllerForTitle = TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  final GenerativeModel model = GenerativeModel(
      model: 'gemini-2.5-pro', apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!);
  late final String jsonString;

  bool isLoading = false;
  bool isSummarizing = false;
  bool summarizedTextGenerated = false;
  bool isTTSEnabledForUser = false;

  String summary = "";
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
      var mediaFile = [];
      List<String> mediaUrls = extractMediaUrls(widget.note.contents);

      for (String url in mediaUrls) {
        Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
            .buffer
            .asUint8List();
        mediaFile.add(DataPart('image/jpeg', bytes));
      }

      final prompt = TextPart(
          "Analyse the string correctly and only return the text that will be displayed to the user when they open the flutter quill editor using the below Flutter Quill JSON. If there are code blocks or in-line code present then type 'Code present' and type the whole code out. After that try to write 'Explaination: ' and explain the whole code section. The explaination should be a maxmimum of 10 sentences. Also if there is an image or video present then describe the contents of the corresponding media. If there is some error the return a string with the error that is in layman terms. The Flutter Quill Json is as follows: $jsonString.");

      final response = await model.generateContent([
        Content.multi([prompt, ...mediaFile])
      ]);

      log("${response.text}");
      setState(() => isLoading = false);

      return response.text!;
    } catch (e) {
      log(e.toString());
      setState(() => isLoading = false);
      return "Problem in converting note to text - limitation of Google Gemini 1.5 Pro.";
    }
  }

  List<String> extractMediaUrls(String content) {
    List<String> mediaUrls = [];
    final decodedContent = jsonDecode(content);

    if (decodedContent is Map<String, dynamic>) {
      for (var op in decodedContent['ops']) {
        if (op['insert'] is Map) {
          if (op['insert']['image'] != null) {
            mediaUrls.add(op['insert']['image']);
          } else if (op['insert']['video'] != null) {
            mediaUrls.add(op['insert']['video']);
          }
        }
      }
    } else if (decodedContent is List) {
      for (var op in decodedContent) {
        if (op['insert'] is Map) {
          if (op['insert']['image'] != null) {
            mediaUrls.add(op['insert']['image']);
          } else if (op['insert']['video'] != null) {
            mediaUrls.add(op['insert']['video']);
          }
        }
      }
    }

    return mediaUrls;
  }

  Future<void> summarizeNote() async {
    setState(() => isSummarizing = true);
    try {
      log("Summarizing...");

      var mediaFile = [];
      List<String> mediaUrls = extractMediaUrls(widget.note.contents);

      for (String url in mediaUrls) {
        Uint8List bytes = (await NetworkAssetBundle(Uri.parse(url)).load(url))
            .buffer
            .asUint8List();
        mediaFile.add(DataPart('image/jpeg', bytes));
      }

      final prompt = TextPart(
          "Analyse the string correctly and summarize the contents of the note stored in the flutter quill editor using the below Flutter Quill JSON. The summary must be contained in 5 bullet points at maximum. Also if there is an image or video present then the specified images are in order of the places - Summarize the contents of the images too. When an error occurs then just say that you were not able to summarize the text and then mention the error in layman terms. If there is an error with the Flutter Quill JSON then mention an internal error because of wrong contents in the note rather than Flutter Quill JSON or Flutter Quill. There should be no mention of Flutter Quill or Flutter Quill JSON in the generated summary if an error occurs in analysis. The Flutter Quill Json is as follows: $jsonString.");

      final response = model.generateContentStream([
        Content.multi([prompt, ...mediaFile])
      ]);

      await for (final chunk in response) {
        setState(() {
          summarizedTextGenerated = true;

          summary = summary + chunk.text!;
        });
      }

      setState(() {
        isSummarizing = false;
      });

      //log("${response.text}");

      //return response.text!;
    } catch (e) {
      log(e.toString());
      setState(() => isSummarizing = false);
      // return "Problem in summarizing note - limitation of Google Gemini 1.5 Pro.";
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
    FirestoreService firestoreService = FirestoreService();

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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Visibility(
                            visible: isTTSEnabledForUser,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final textToSpeak =
                                        await callGeminiToGetTextForSpeech();
                                    await speak(
                                        "Title of this note is: ${widget.note.title}. This note was created on $formattedDate.  $textToSpeak");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: colorBlindness(
                                        whiteUsed,
                                        returnColorBlindNessTypeFromIndex(
                                          colourBlindnessIndex,
                                        ),
                                      ),
                                    ),
                                    child: Tooltip(
                                      message: "Convert the note to speech",
                                      child: SizedBox(
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
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: !summarizedTextGenerated,
                            child: GestureDetector(
                              onTap: summarizeNote,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorBlindness(
                                    whiteUsed,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Row(
                                  children: [
                                    isSummarizing
                                        ? CircularProgressIndicator(
                                            color: colorBlindness(
                                              orangeUsed,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.summarize,
                                            color: blackUsed,
                                            size: 20,
                                          ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Summarize",
                                      style: TextStyle(
                                        color: blackUsed,
                                        fontFamily: "Gilroy",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          EditNoteButton(
                            widget: widget,
                            colourBlindnessIndex: colourBlindnessIndex,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          MoveToTrashButton(
                            firestoreService: firestoreService,
                            widget: widget,
                            colourBlindnessIndex: colourBlindnessIndex,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TitleWidget(controllerForTitle: controllerForTitle),
                  Visibility(
                    visible: summarizedTextGenerated,
                    child: NoteSummaryWidget(
                      summary: summary,
                      colourBlindnessIndex: colourBlindnessIndex,
                    ),
                  ),
                  NotePreviewWidget(controller: controller),
                  AttachmentPresentOrNotWidget(
                    widget: widget,
                    colourBlindnessIndex: colourBlindnessIndex,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentPresentOrNotWidget extends StatelessWidget {
  const AttachmentPresentOrNotWidget({
    super.key,
    required this.widget,
    required this.colourBlindnessIndex,
  });

  final NotesViewingScreen widget;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.1,
        ),
        decoration: BoxDecoration(
          color: colorBlindness(
            darkBackground,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            (widget.note.attachments != null)
                ? (((widget.note.attachments!.isNotEmpty))
                    ? "Attachments: Edit to View"
                    : "No Attachments")
                : "No Attachments",
            style: TextStyle(
              fontSize: 17,
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
              fontFamily: "GilroyBold",
            ),
          ),
        ),
      ),
    );
  }
}

class NotePreviewWidget extends StatelessWidget {
  const NotePreviewWidget({
    super.key,
    required this.controller,
  });

  final quill.QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
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
    );
  }
}

class NoteSummaryWidget extends StatelessWidget {
  const NoteSummaryWidget({
    super.key,
    required this.summary,
    required this.colourBlindnessIndex,
  });

  final String summary;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        decoration: BoxDecoration(
            color: colorBlindness(
              darkBackground,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Markdown(
          data: "# Generated Summary: \n $summary",
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(
              fontSize: 24,
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
              fontFamily: "GilroyBold",
            ),
            p: TextStyle(
              fontSize: 14,
              color: colorBlindness(
                whiteUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            ),
            listBullet: TextStyle(
              color: colorBlindness(
                whiteUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.controllerForTitle,
  });

  final TextEditingController controllerForTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class MoveToTrashButton extends StatelessWidget {
  const MoveToTrashButton({
    super.key,
    required this.firestoreService,
    required this.widget,
    required this.colourBlindnessIndex,
  });

  final FirestoreService firestoreService;
  final NotesViewingScreen widget;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        firestoreService.moveToTrash(widget.note.docID!);

        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
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
    );
  }
}

class EditNoteButton extends StatelessWidget {
  const EditNoteButton({
    super.key,
    required this.widget,
    required this.colourBlindnessIndex,
  });

  final NotesViewingScreen widget;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddAndUpdateNotePopUpCard(note: widget.note),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.view_carousel,
              color: blackUsed,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Edit",
              style: TextStyle(
                color: blackUsed,
                fontFamily: "Gilroy",
              ),
            )
          ],
        ),
      ),
    );
  }
}
