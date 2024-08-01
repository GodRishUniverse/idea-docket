import 'dart:ui';

import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:idea_docket/misc/code_element_builder.dart';
import 'package:idea_docket/models/chat_model.dart';

import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef FuncCallForSendChatInWidget = Future<void> Function(String, bool);

class GeminiChatForUnderstandingAndSearching extends StatefulWidget {
  const GeminiChatForUnderstandingAndSearching({super.key});

  @override
  State<GeminiChatForUnderstandingAndSearching> createState() =>
      _GeminiChatForUnderstandingAndSearchingState();
}

class _GeminiChatForUnderstandingAndSearchingState
    extends State<GeminiChatForUnderstandingAndSearching> {
  final TextEditingController controller = TextEditingController();

  bool isLoading = false;
  late final GenerativeModel model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();

  List<List<dynamic>> chatList = [];

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    model = GenerativeModel(
        model: 'gemini-1.5-pro', apiKey: dotenv.env['GOOGLE_GEMINI_API_KEY']!);
    _chat = model.startChat();
    initColourBlindnessIndex();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  Future<void> _sendChatMessage(String message, bool regenerate) async {
    setState(() => isLoading = true);

    try {
      if (!regenerate) {
        chatList.add(['user', message]);
      }
      final response = _chat.sendMessageStream(Content.text(message));
      int indexOfAppendedItem = chatList.length;

      setState(() {
        if (regenerate) {
          indexOfAppendedItem = indexOfAppendedItem - 1;
          chatList[indexOfAppendedItem][1] = "";
        } else {
          chatList.add(['gemini', ""]);
        }
      });

      await for (final chunk in response) {
        setState(() {
          chatList[indexOfAppendedItem][1] =
              chatList[indexOfAppendedItem][1] + chunk.text;
        });
      }

      if (chatList[indexOfAppendedItem][1] == "") {
        debugPrint('No response from API.');
        chatList.removeLast();
        return;
      }
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      controller.clear();
      // Scroll down the page automatically when a response is received
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorBlindness(
          orangeUsed,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
        backgroundColor: colorBlindness(
          darkBackground,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
        title: Text(
          "Gemini Chat Assistant - For Quick Search",
          style: TextStyle(
            fontSize: 14,
            color: colorBlindness(
              whiteUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                  sigmaX: _chat.history.isEmpty ? (isLoading ? 30 : 0) : 30,
                  sigmaY: _chat.history.isEmpty ? (isLoading ? 30 : 0) : 30),
              child: Lottie.asset("assets/gemini.json"),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  //  itemCount: _chat.history.length + (isLoading ? 2 : 0),
                  itemCount: chatList.length + (isLoading ? 4 : 0),
                  itemBuilder: (context, index) {
                    if (index < chatList.length) {
                      // if (index < _chat.history.length) {
                      // final content = _chat.history.toList()[index];
                      // final text = content.parts
                      //     .whereType<TextPart>()
                      //     .map<String>((e) => e.text)
                      //     .join('');

                      return ListTile(
                        title: MessageWidget(
                          sendchatmessage: _sendChatMessage,
                          message: Message(
                            userPrompt: (chatList[index][0] == 'user')
                                ? ""
                                : chatList[index - 1][1],
                            isUser: chatList[index][0] == 'user',
                            text: chatList[index][1],
                          ),
                          colourBlindnessIndex: colourBlindnessIndex,
                        ),
                      );
                    } else {
                      return isLoading
                          ? LoadingMessage(
                              colourBlindnessIndex: colourBlindnessIndex,
                            )
                          : Container();
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 82,
              ),
            ],
          ),
          // user input
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    colorBlindness(
                      lightGrey,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ).withOpacity(0.75)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colorBlindness(
                          greyUsedOpacityLowered,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
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
                            hintText: "Enter your prompt...",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onFieldSubmitted: (String value) {
                            _sendChatMessage(
                              value,
                              false,
                            );
                          },
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
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: GestureDetector(
                                onTap: () async {
                                  _sendChatMessage(controller.text, false);
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
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.colourBlindnessIndex,
    required this.sendchatmessage,
  });

  final FuncCallForSendChatInWidget sendchatmessage;
  final Message message;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? colorBlindness(
                          orangeUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ).withOpacity(0.72)
                      : colorBlindness(
                          lightColors[6],
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(25),
                    topRight: const Radius.circular(25),
                    bottomLeft: message.isUser
                        ? const Radius.circular(35)
                        : const Radius.circular(0),
                    bottomRight: message.isUser
                        ? const Radius.circular(0)
                        : const Radius.circular(35),
                  ),
                ),
                padding: EdgeInsets.only(
                    bottom: message.isUser ? 15 : 40,
                    left: 20,
                    right: 20,
                    top: 15),
                margin: const EdgeInsets.only(bottom: 8),
                child: SelectionArea(
                  child: MarkdownBody(
                    data: message.text,
                    builders: {
                      'code': CodeElementBuilder(),
                    },
                    styleSheet: MarkdownStyleSheet(
                        h1: TextStyle(
                          fontSize: 24,
                          color: colorBlindness(
                            orangeUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                        ),
                        code: TextStyle(
                          fontSize: 14,
                          color: colorBlindness(
                            whiteUsed,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                          backgroundColor: colorBlindness(
                            darkBackground,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                        ),
                        codeblockPadding: const EdgeInsets.all(8),
                        codeblockDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: colorBlindness(
                            darkBackground,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                        ) // new end
                        ),
                    shrinkWrap: true,
                  ),
                ),
              ),
              if (!message.isUser && message.text != "")
                Positioned(
                  bottom: 0,
                  left: 25,
                  child: Row(
                    children: [
                      if (!message.isUser && message.text != "")
                        CopyWidget(
                          message: message,
                          colourBlindnessIndex: colourBlindnessIndex,
                        ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (!message.isUser)
                        RegenerateWidget(
                          sendchatmessage: sendchatmessage,
                          message: message,
                          colourBlindnessIndex: colourBlindnessIndex,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegenerateWidget extends StatelessWidget {
  const RegenerateWidget({
    super.key,
    required this.sendchatmessage,
    required this.message,
    required this.colourBlindnessIndex,
  });

  final FuncCallForSendChatInWidget sendchatmessage;
  final Message message;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await sendchatmessage(message.userPrompt, true);
      },
      child: SizedBox(
        width: 125,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: colorBlindness(
              greyUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 20,
                child: Image.asset(
                  "assets/icons/regenerate.png",
                  color: colorBlindness(
                    lightGrey,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Text(
                  "Regenerate",
                  style: TextStyle(
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CopyWidget extends StatelessWidget {
  const CopyWidget({
    super.key,
    required this.message,
    required this.colourBlindnessIndex,
  });

  final Message message;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: message.text));
      },
      child: SizedBox(
        width: 95,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: colorBlindness(
              greyUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                child: Icon(
                  Icons.copy,
                  size: 20,
                  color: colorBlindness(
                    lightGrey,
                    returnColorBlindNessTypeFromIndex(
                      colourBlindnessIndex,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "Copy",
                  style: TextStyle(
                    color: colorBlindness(
                      whiteUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingMessage extends StatelessWidget {
  const LoadingMessage({
    super.key,
    required this.colourBlindnessIndex,
  });

  final int colourBlindnessIndex;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorBlindness(
                whiteUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ).withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingSkeleton(),
                SizedBox(
                  height: 8,
                ),
                LoadingSkeleton(
                  width: 200,
                ),
                SizedBox(
                  height: 8,
                ),
                LoadingSkeleton(),
                SizedBox(
                  height: 8,
                ),
                LoadingSkeleton(),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: LoadingSkeleton(),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: LoadingSkeleton(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height,
  });

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: blackUsed.withOpacity(0.04),
          borderRadius: const BorderRadius.all(Radius.circular(16))),
    );
  }
}
