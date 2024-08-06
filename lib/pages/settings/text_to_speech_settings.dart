import 'dart:developer';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/pages/settings/cubits/text_to_speech_enabled_cubit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextToSpeechSettings extends StatefulWidget {
  const TextToSpeechSettings({super.key});

  @override
  State<TextToSpeechSettings> createState() => _TextToSpeechSettingsState();
}

class _TextToSpeechSettingsState extends State<TextToSpeechSettings> {
  FlutterTts flutterTts = FlutterTts();

  double volume = 1.0;
  double pitch = 1.0;
  double speechRate = 0.5;
  List<String>? languages;
  String language = "en-US";

  bool isPlaying = false;

  int colourBlindnessIndex = 0;

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    initColourBlindnessIndex();
    init();
    getSettings();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    stop();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    languages = List<String>.from(await flutterTts.getLanguages);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TextToSpeechEnabledCubit>().changeStateAccordingToValue(
          prefs.getBool('textToSpeechEnabled') ?? false);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Text-To-Speech Settings",
                style: TextStyle(
                  color: blackUsed,
                  fontSize: 25,
                  fontFamily: "GilroyBold",
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: BlocBuilder<TextToSpeechEnabledCubit, bool>(
                builder: (context, state) {
                  return AnimatedToggleSwitch<bool>.dual(
                    current: state,
                    first: false,
                    second: true,
                    onChanged: (value) async {
                      context.read<TextToSpeechEnabledCubit>().changeState();

                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool('textToSpeechEnabled', value);
                    },
                    spacing: 50.0,
                    style: const ToggleStyle(
                      backgroundColor: blackUsed,
                      borderColor: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                    borderWidth: 5.0,
                    height: 55,
                    styleBuilder: (b) => ToggleStyle(
                      indicatorColor: b
                          ? colorBlindness(
                              switchColors[1],
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            )
                          : colorBlindness(
                              switchColors[2],
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                    ),
                    iconBuilder: (value) => value
                        ? SizedBox(
                            height: 35,
                            child: Image.asset(
                              'assets/icons/on_off.png',
                              color: colorBlindness(
                                switchColors[3],
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 35,
                            child: Image.asset(
                              'assets/icons/disabled.png',
                              color: colorBlindness(
                                switchColors[0],
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                            ),
                          ),
                    textBuilder: (value) => value
                        ? Center(
                            child: Text(
                            'Enabled',
                            style: TextStyle(
                              color: colorBlindness(
                                Colors.green,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                            ),
                          ))
                        : Center(
                            child: Text(
                              'Disabled',
                              style: TextStyle(
                                color: colorBlindness(
                                  redUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            BlocBuilder<TextToSpeechEnabledCubit, bool>(
              builder: (context, state) {
                if (state) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (isPlaying)
                                  ? greyUsed
                                  : colorBlindness(
                                      redUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.speaker,
                                  color: (isPlaying)
                                      ? colorBlindness(
                                          lightGrey,
                                          returnColorBlindNessTypeFromIndex(
                                            colourBlindnessIndex,
                                          ),
                                        )
                                      : colorBlindness(
                                          whiteUsed,
                                          returnColorBlindNessTypeFromIndex(
                                            colourBlindnessIndex,
                                          ),
                                        ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text("Test",
                                    style: TextStyle(
                                      color: (isPlaying)
                                          ? colorBlindness(
                                              lightGrey,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            )
                                          : colorBlindness(
                                              whiteUsed,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            ),
                                      fontSize: 20,
                                    )),
                              ],
                            ),
                          ),
                          onTap: () async {
                            if (!isPlaying) {
                              setState(() {
                                isPlaying = true;
                              });
                              log(isPlaying.toString());
                              await speak(
                                  "Hi! I'm your text-to-speech assistant. Please adjust my volume, pitch, and speech rate to your liking. Once you're happy with the settings, go to your notes or events, and speak them out! See you there!");
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: (isPlaying)
                                    ? colorBlindness(
                                        blueUsedInLinks,
                                        returnColorBlindNessTypeFromIndex(
                                          colourBlindnessIndex,
                                        ),
                                      )
                                    : greyUsed,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stop,
                                    color: (isPlaying)
                                        ? colorBlindness(
                                            whiteUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          )
                                        : colorBlindness(
                                            lightGrey,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Stop",
                                    style: TextStyle(
                                      color: (isPlaying)
                                          ? colorBlindness(
                                              whiteUsed,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            )
                                          : colorBlindness(
                                              lightGrey,
                                              returnColorBlindNessTypeFromIndex(
                                                colourBlindnessIndex,
                                              ),
                                            ),
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (isPlaying) {
                                await stop();

                                setState(() {
                                  isPlaying = false;
                                });
                              }
                            }),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Volume",
                            style: TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Slider(
                              min: 0,
                              max: 1,
                              divisions: 10,
                              value: volume,
                              onChanged: (value) => setState(
                                () {
                                  volume = value;
                                  initSetting();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            NumberFormat("###.00").format(volume * 100),
                            style: const TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Pitch",
                            style: TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Slider(
                              min: 0.4,
                              max: 2,
                              divisions: 16,
                              value: pitch,
                              onChanged: (value) => setState(
                                () {
                                  pitch = value;
                                  initSetting();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            NumberFormat("###.00").format(pitch),
                            style: const TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Speech Rate",
                            style: TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Slider(
                              min: 0.2,
                              max: 1.4,
                              divisions: 12,
                              value: speechRate,
                              onChanged: (value) => setState(
                                () {
                                  speechRate = value;
                                  initSetting();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            NumberFormat("###.00").format(speechRate),
                            style: const TextStyle(
                              color: blackUsed,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (languages != null)
                        Row(
                          children: [
                            const Text(
                              "Languages: ",
                              style: TextStyle(
                                color: blackUsed,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            DropdownButton<String>(
                              focusColor: colorBlindness(
                                whiteUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                              value: language,
                              style: const TextStyle(
                                color: blackUsed,
                                fontSize: 16,
                              ),
                              iconEnabledColor: blackUsed,
                              items: languages!.map<DropdownMenuItem<String>>(
                                (String? value) {
                                  return DropdownMenuItem<String>(
                                    value: value!,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                language = value!;
                              },
                            ),
                          ],
                        ),
                    ],
                  );
                } else {
                  // stop();
                  return Container();
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: blackUsed),
                color: greyUsed,
              ),
              padding: const EdgeInsets.all(10),
              child: const Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "IMPORTANT:",
                      hintStyle: TextStyle(
                        color: blackUsed,
                        fontSize: 20,
                        fontFamily: "GilroyBold",
                      ),
                    ),
                    readOnly: true,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          "Notes recitation uses Google Gemini AI so responses are error-prone.",
                      hintStyle: TextStyle(
                        color: blackUsed,
                        fontSize: 16.5,
                        fontFamily: "GilroyBold",
                      ),
                    ),
                    readOnly: true,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initSetting() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setLanguage(language);

    setState(() {
      saveSettings();
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('volume', volume);
    await prefs.setDouble('pitch', pitch);
    await prefs.setDouble('speechRate', speechRate);
    await prefs.setString('languageUsed', language);
  }

  Future getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    speechRate =
        prefs.getDouble('speechRate') ?? 0.5; // Default to 1.0 if not found
    volume = prefs.getDouble('volume') ?? 1.0; // Default to 1.0 if not found
    pitch = prefs.getDouble('pitch') ?? 1.0; // Default to 1.0 if not found
    language = prefs.getString('languageUsed') ?? 'en-US';
  }

  Future<void> speak(String text) async {
    initSetting();
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}
