import 'dart:developer';

import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class ListeningWidget extends StatefulWidget {
  const ListeningWidget({
    super.key,
    required this.heroTag,
    required this.isNote,
  });

  final String heroTag;
  final bool isNote;
  @override
  State<ListeningWidget> createState() => _ListeningWidgetState();
}

class _ListeningWidgetState extends State<ListeningWidget> {
  TextEditingController controllerForText = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late String _text;

  static const String noteSpeakingInitMessage = "Start speaking...";

  static const String eventSpeakingInitMessage =
      "Please mention the event date, start-time, end-time and its title and description.";

  int colourBlindnessIndex = 0;

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void initState() {
    super.initState();

    initColourBlindnessIndex();

    _text = widget.isNote ? noteSpeakingInitMessage : eventSpeakingInitMessage;

    _speech = stt.SpeechToText();
    _listen();
  }

  @override
  void dispose() {
    controllerForText.dispose();
    _speech.cancel();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == "notListening" || val == "done") {
            _stopListening();
          }
        },
        onError: (val) {
          _stopListening();
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;

            if (val.hasConfidenceRating && val.confidence > 0) {
              log("${val.confidence}");
              _stopListening();
            }
          }),
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
      String textSentBack = widget.isNote
          ? ((_text == noteSpeakingInitMessage) ? "" : _text)
          : ((_text == eventSpeakingInitMessage) ? "" : _text);
      Navigator.pop(context, textSentBack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Hero(
          tag: widget.heroTag,
          child: Material(
            color: blackUsed,
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
                                Navigator.pop(context);
                              },
                              icon: Icon(
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Speech-to-Text",
                      style: TextStyle(
                        fontFamily: "GilroyBold",
                        fontSize: 25,
                        color: colorBlindness(
                          whiteUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 5, 20),
                        child: Text(
                          _text,
                          style: TextStyle(
                            fontFamily: "GilroyBold",
                            fontSize: 17,
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
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: _stopListening,
                      child: AvatarGlow(
                        glowCount: 3,
                        animate: _isListening,
                        glowColor: colorBlindness(
                          orangeUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        duration: const Duration(milliseconds: 1000),
                        repeat: true,
                        glowRadiusFactor: 0.5,
                        child: CircleAvatar(
                          backgroundColor: colorBlindness(
                            orangeUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                          radius: 32,
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                            size: 40,
                          ),
                        ),
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
