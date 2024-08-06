import 'dart:developer';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idea_docket/misc/code_element_builder.dart';

import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/pages/settings/cubits/colour_blindness_enabled_cubit.dart';
import 'package:idea_docket/pages/settings/cubits/colour_blindness_theme_manual_or_gemini_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColourBlindnessSettings extends StatefulWidget {
  const ColourBlindnessSettings({super.key});

  @override
  State<ColourBlindnessSettings> createState() =>
      _ColourBlindnessSettingsState();
}

class _ColourBlindnessSettingsState extends State<ColourBlindnessSettings> {
  ColorBlindnessType? colourBlindnessChosen = ColorBlindnessType.none;

  TextEditingController controller = TextEditingController();

  TextEditingController responseFromGeminiInColourBlindnessIdentification =
      TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ColourBlindnessEnabledCubit>()
          .change(prefs.getBool('colourBlindnessEnabled') ?? false);

      colourBlindnessChosen =
          ColorBlindnessType.values[prefs.getInt('colourBlindnessChosen') ?? 0];

      responseFromGeminiInColourBlindnessIdentification.text =
          "Colour blindenss type set right now: **${returnColorBlindNessTypeFromIndex(prefs.getInt('colourBlindnessChosen') ?? 0)}**";

      setState(() {});
    });
  }

  Future callGeminiForColourBlindnessIdentification(String text) async {
    try {
      setState(() {
        isLoading = true;
      });
      GenerativeModel model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!);

      String prompt =
          """Look at the user's color blindness description: $text and only print the index number of the colour blindness type that matches the most closely to this description:
      none [index = 0],
      protanomaly [index = 1],
      deuteranomaly [index = 2],
      tritanomaly [index = 3],
      protanopia [index = 4],
      deuteranopia [index = 5],
      tritanopia [index = 6],
      achromatopsia [index = 7],
      achromatomaly [index = 8]
      """;
      final response = await model.generateContent([Content.text(prompt)]);

      log("Response from gemini: ${response.text.toString()}");

      RegExp regExp = RegExp(r"\d+");

      Match? firstMatch = regExp.firstMatch(response.text.toString().trim());

      int? index =
          firstMatch != null ? int.tryParse(firstMatch.group(0)!) : null;

      //int? index = int.tryParse(response.text.toString().trim());
      if (index != null) {
        log("Index from gemini: $index");
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('colourBlindnessChosen', index);

        responseFromGeminiInColourBlindnessIdentification.text =
            "Gemini says: ${response.text.toString()}";

        setState(() {});
      } else {
        responseFromGeminiInColourBlindnessIdentification.text =
            "Gemini did not return an index. Please try again.}";

        log("Error in response from gemini: ${response.text.toString()}");
      }
    } catch (e) {
      responseFromGeminiInColourBlindnessIdentification.text =
          "API Error. Please try again.}";
      log(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Colour Blindness Settings",
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
              const EnabledDisabledWidget(),
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<ColourBlindnessEnabledCubit, bool>(
                builder: (context, state) {
                  return Visibility(
                    visible: state,
                    child: selectManualOrGemini(),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BlocBuilder<ColourBlindnessThemeManualOrGeminiCubit, String>
      selectManualOrGemini() {
    return BlocBuilder<ColourBlindnessThemeManualOrGeminiCubit, String>(
      builder: (context, state) {
        return Column(
          children: [
            AnimatedToggleSwitch<String>.size(
              textDirection: TextDirection.ltr,
              current: state,
              values: const ["Manual", "Gemini"],
              indicatorSize: const Size.fromWidth(175),
              borderWidth: 2.0,
              iconAnimationType: AnimationType.onHover,
              styleAnimationType: AnimationType.onHover,
              style: ToggleStyle(
                borderColor: Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: blackUsed.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 4.5),
                  ),
                ],
              ),
              spacing: 1.5,
              customSeparatorBuilder: (context, local, global) {
                final opacity = ((global.position - local.position).abs() - 0.5)
                    .clamp(0.0, 1.0);
                return VerticalDivider(
                  indent: 10.0,
                  endIndent: 10.0,
                  color: whiteUsed.withOpacity(opacity),
                );
              },
              customIconBuilder: (context, local, global) {
                final text = const ['Manual', 'Gemini'][local.index];
                final icon = [
                  'assets/icons/manual.png',
                  'assets/icons/google-gemini-icon.png',
                ][local.index];
                return Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        child: Image.asset(
                          icon,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        text,
                        style: TextStyle(
                          color: Color.lerp(
                            blackUsed,
                            whiteUsed,
                            local.animationValue,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onChanged: (value) {
                context
                    .read<ColourBlindnessThemeManualOrGeminiCubit>()
                    .changeType();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (state == "Manual")
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  color: darkBackground.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Scrollbar(
                  interactive: true,
                  thickness: 7,
                  radius: const Radius.circular(20),
                  child: ListView.builder(
                      itemCount: ColorBlindnessType.values.length,
                      itemBuilder: (context, index) {
                        return Theme(
                          data: ThemeData(
                            unselectedWidgetColor: whiteUsed,
                          ),
                          child: ListTile(
                            title: Text(
                              ColorBlindnessType.values[index].name,
                              style: const TextStyle(
                                color: whiteUsed,
                              ),
                            ),
                            leading: Radio<ColorBlindnessType>.adaptive(
                              activeColor: blueUsedInLinks,
                              value: ColorBlindnessType.values[index],
                              groupValue: colourBlindnessChosen,
                              onChanged: (ColorBlindnessType? value) async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                prefs.setInt('colourBlindnessChosen', index);

                                setState(() {
                                  colourBlindnessChosen = value;
                                });
                              },
                            ),
                          ),
                        );
                      }),
                ),
              )
            else
              Column(
                children: [
                  importantMessageForGemini(),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      top: 16,
                      left: 5,
                      right: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorBlindness(
                          whiteUsed,
                          colourBlindnessChosen ?? ColorBlindnessType.none,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: const [
                          BoxShadow(
                            color: greyUsedOpacityLowered,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              autofocus: true,
                              autocorrect: true,
                              decoration: const InputDecoration(
                                hintText:
                                    "Please describe your color blindness...",
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 20),
                              ),
                              onFieldSubmitted: (String value) {
                                callGeminiForColourBlindnessIdentification(
                                    value);
                              },
                              minLines: 2,
                              maxLines: 100,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: colorBlindness(
                                        orangeUsed,
                                        colourBlindnessChosen ??
                                            ColorBlindnessType.none,
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: GestureDetector(
                                    onTap: () async {
                                      callGeminiForColourBlindnessIdentification(
                                          controller.text);
                                      controller.clear();
                                    },
                                    child: const Icon(
                                      Icons.send,
                                      size: 25,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      top: 16,
                      left: 5,
                      right: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorBlindness(
                          whiteUsed,
                          colourBlindnessChosen ?? ColorBlindnessType.none,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: greyUsedOpacityLowered,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SelectionArea(
                        child: MarkdownBody(
                          data:
                              responseFromGeminiInColourBlindnessIdentification
                                  .text,
                          builders: {
                            'code': CodeElementBuilder(),
                          },
                          styleSheet: MarkdownStyleSheet(
                              h1: TextStyle(
                                fontSize: 24,
                                color: colorBlindness(
                                  orangeUsed,
                                  colourBlindnessChosen ??
                                      ColorBlindnessType.none,
                                ),
                              ),
                              code: TextStyle(
                                fontSize: 14,
                                color: colorBlindness(
                                  whiteUsed,
                                  colourBlindnessChosen ??
                                      ColorBlindnessType.none,
                                ),
                                backgroundColor: colorBlindness(
                                  darkBackground,
                                  colourBlindnessChosen ??
                                      ColorBlindnessType.none,
                                ),
                              ),
                              codeblockPadding: const EdgeInsets.all(8),
                              codeblockDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: colorBlindness(
                                  darkBackground,
                                  colourBlindnessChosen ??
                                      ColorBlindnessType.none,
                                ),
                              ) // new end
                              ),
                          shrinkWrap: true,
                        ),
                      ),

                      // TextField(
                      //   controller:
                      //       responseFromGeminiInColourBlindnessIdentification,
                      //   readOnly: true,
                      //   decoration: const InputDecoration(
                      //     border: InputBorder.none,
                      //     contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      //   ),
                      //   minLines: 2,
                      //   maxLines: 100,
                      // ),
                    ),
                  ),
                ],
              )
          ],
        );
      },
    );
  }
}

Container importantMessageForGemini() {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: blackUsed),
      color: greyUsedOpacityLowered,
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
                "Uses Gemini AI to generate the colour palette according to the choices entered when enabled.",
            hintStyle: TextStyle(
              color: blackUsed,
              fontSize: 16.5,
              fontFamily: "GilroyBold",
            ),
          ),
          readOnly: true,
          minLines: 3,
          maxLines: 10,
        ),
      ],
    ),
  );
}

class EnabledDisabledWidget extends StatelessWidget {
  const EnabledDisabledWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColourBlindnessEnabledCubit, bool>(
      builder: (context, state) {
        return AnimatedToggleSwitch<bool>.dual(
          current: state,
          first: false,
          second: true,
          onChanged: (value) async {
            context.read<ColourBlindnessEnabledCubit>().change(value);

            final prefs = await SharedPreferences.getInstance();

            await prefs.setBool('colourBlindnessEnabled', value);

            await prefs.setInt('colourBlindnessChosen', 0);
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
              indicatorColor: b ? switchColors[1] : switchColors[2]),
          iconBuilder: (value) => value
              ? SizedBox(
                  height: 35,
                  child: Image.asset(
                    'assets/icons/on_off.png',
                    color: switchColors[3],
                  ),
                )
              : SizedBox(
                  height: 35,
                  child: Image.asset(
                    'assets/icons/disabled.png',
                    color: switchColors[0],
                  ),
                ),
          textBuilder: (value) => value
              ? const Center(
                  child: Text(
                  'Enabled',
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ))
              : const Center(
                  child: Text(
                    'Disabled',
                    style: TextStyle(
                      color: redUsed,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
