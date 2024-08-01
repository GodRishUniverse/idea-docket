import 'dart:developer';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firestore_notes_crud_and_search.dart';
import 'package:idea_docket/gemini_tools/gemini_chat_help.dart';
import 'package:idea_docket/misc/snack_bar.dart';
import 'package:idea_docket/models/note_model.dart';

import 'package:idea_docket/pages/notes/add_and_update_notes.dart';
import 'package:idea_docket/pages/notes/cubits/notes_or_trash_cubit.dart';
import 'package:idea_docket/pages/notes/note_cards.dart';
import 'package:idea_docket/misc/hero_dialogue_route.dart';
import 'package:idea_docket/pages/notes/trashed_notes/trashed_note_card.dart';
import 'package:idea_docket/pages/notes/trashed_notes/view_trashed_notes.dart';
import 'package:idea_docket/pages/notes/viewing_notes.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// COLOR BLINDNESS CORRECTED

class NotesTabView extends StatefulWidget {
  final bool isDrawerOpen;

  const NotesTabView({
    super.key,
    required this.isDrawerOpen,
  });

  @override
  State<NotesTabView> createState() => _NotesTabViewState();
}

class _NotesTabViewState extends State<NotesTabView> {
  final FirestoreService firestoreService = FirestoreService();
  String searchText = "";
  bool isSearchBarVisible = false;
  int value = 0;

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ));
    initColourBlindnessIndex();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isDrawerOpen ? 40 : 0),
          color: colorBlindness(whiteUsed,
              returnColorBlindNessTypeFromIndex(colourBlindnessIndex)),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Notes",
                            style: TextStyle(
                              fontFamily: "GilroyBold",
                              fontSize: 34,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      BlocBuilder<NotesOrTrashCubit, int>(
                        builder: (context, state) {
                          return AnimatedToggleSwitch<int>.size(
                            textDirection: TextDirection.ltr,
                            current: state,
                            values: const [0, 1],
                            indicatorSize: const Size.fromWidth(175),
                            borderWidth: 4.0,
                            iconAnimationType: AnimationType.onHover,
                            styleAnimationType: AnimationType.onHover,
                            style: ToggleStyle(
                              borderColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color: colorBlindness(
                                          blackUsed,
                                          returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex))
                                      .withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(2.5, 3.5),
                                ),
                              ],
                            ),
                            spacing: 2.0,
                            customSeparatorBuilder: (context, local, global) {
                              final opacity =
                                  ((global.position - local.position).abs() -
                                          0.5)
                                      .clamp(0.0, 1.0);
                              return VerticalDivider(
                                indent: 10.0,
                                endIndent: 10.0,
                                color: colorBlindness(
                                        whiteUsed,
                                        returnColorBlindNessTypeFromIndex(
                                            colourBlindnessIndex))
                                    .withOpacity(opacity),
                              );
                            },
                            customIconBuilder: (context, local, global) {
                              final text =
                                  const ['Notes', 'Trash'][local.index];
                              final icon = [
                                'assets/icons/notes.png',
                                'assets/icons/trash_closed.png',
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
                                        color: Color.lerp(
                                          colorBlindness(
                                            blackUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
                                          colorBlindness(
                                            whiteUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
                                          local.animationValue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      text,
                                      style: TextStyle(
                                        color: Color.lerp(
                                          colorBlindness(
                                            blackUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
                                          colorBlindness(
                                            whiteUsed,
                                            returnColorBlindNessTypeFromIndex(
                                              colourBlindnessIndex,
                                            ),
                                          ),
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
                                  .read<NotesOrTrashCubit>()
                                  .changeNotesDisplayed(value);
                            },
                          );
                        },
                      ),
                      Visibility(
                        visible: isSearchBarVisible,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
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
                            padding: const EdgeInsets.all(5),
                            child: TextField(
                              autofocus: isSearchBarVisible,
                              decoration: const InputDecoration(
                                hintText: "Search in Title and Contents",
                                icon: Icon(Icons.search),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => {
                                setState(() {
                                  searchText = value;
                                })
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isSearchBarVisible == false,
                        child: const SizedBox(
                          height: 20,
                        ),
                      ),
                      BlocBuilder<NotesOrTrashCubit, int>(
                        builder: (context, state) {
                          return Center(
                            child: (state == 1)
                                ? ((searchText.isNotEmpty)
                                    ? searchTrashedNotes()
                                    : trashedNotes())
                                : ((searchText.isNotEmpty)
                                    ? searchNotes()
                                    : buildNotes()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 90.0,
                right: 20,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorBlindness(
                      blueForDrawer,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isSearchBarVisible = !isSearchBarVisible;
                            if (isSearchBarVisible == false) {
                              searchText = "";
                            }
                          });
                        },
                        child: Tooltip(
                          message: "Search",
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: colorBlindness(
                                    greyUsedOpacityLowered,
                                    returnColorBlindNessTypeFromIndex(
                                      colourBlindnessIndex,
                                    ),
                                  ),
                                  offset: const Offset(2, 5),
                                  blurRadius: 6,
                                )
                              ],
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: colorBlindness(
                                whiteUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                              child: isSearchBarVisible
                                  ? const Icon(Icons.swipe_up)
                                  : Lottie.asset("assets/search.json"),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GeminiChatForUnderstandingAndSearching()));
                        },
                        child: Tooltip(
                          message: "Gemini Chat Help",
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: colorBlindness(
                                      greyUsed,
                                      returnColorBlindNessTypeFromIndex(
                                        colourBlindnessIndex,
                                      ),
                                    ),
                                    offset: const Offset(0, 4),
                                    blurRadius: 4)
                              ],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: colorBlindness(
                                blackUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                              child: Lottie.asset("assets/ai_tab.json"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddAndUpdateNotePopUpCard()));
                  },
                  child: Tooltip(
                    message: "Add Note",
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: colorBlindness(
                        orangeUsed,
                        returnColorBlindNessTypeFromIndex(
                          colourBlindnessIndex,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: whiteUsed,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNotes() => StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarError(context, snapshot.error.toString());
            });
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            if (notesList.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Lottie.asset(
                      "assets/empty_notes.json",
                    ),
                    Text(
                      'No notes created',
                      style: TextStyle(
                        color: colorBlindness(
                          greyUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: List.generate(
                  notesList.length,
                  (index) {
                    DocumentSnapshot documentSnapshot = notesList[index];
                    String docId = documentSnapshot.id;
                    Map<String, dynamic> data =
                        documentSnapshot.data() as Map<String, dynamic>;
                    String title = data['title'];
                    String contents = data['contents'];
                    Timestamp time = data['time'];
                    int noteid = data['id'];
                    int color = data['colorOfTile'];
                    List attachments = data["attachments"];

                    List<String> vals =
                        attachments.map((item) => item.toString()).toList();

                    final note = Note(
                      docID: docId,
                      id: noteid,
                      title: title,
                      contents: contents,
                      createdTime: time,
                      colorOfTile: color,
                      attachments: vals,
                    );

                    return StaggeredGridTile.fit(
                      crossAxisCellCount: 1,
                      child: GestureDetector(
                        onLongPress: () {
                          log("long pressed");
                        },
                        onTap: () async {
                          Navigator.of(context)
                              .push(HeroDialogueRoute(builder: (context) {
                            return NotesViewingScreen(
                              note: note,
                            );
                          }));
                          //refreshNotes();
                        },
                        child: Hero(
                          tag: note.docID.toString(),
                          child: NoteCardWidget(
                            note: note,
                            index: index,
                            colourBlindnessIndex: colourBlindnessIndex,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return const Text('No notes found');
          }
        },
      );

  Widget searchNotes() => StreamBuilder<List<DocumentSnapshot>>(
        stream: firestoreService.searchNotes(false, searchText),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarError(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
            // return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List notesList = snapshot.data!;

            if (notesList.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: 300,
                      child: Image.asset("assets/not_found_2.png"),
                    ),
                    Text(
                      'No notes found',
                      style: TextStyle(
                        color: colorBlindness(
                          greyUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontSize: 19,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(10),
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: List.generate(
                  notesList.length,
                  (index) {
                    DocumentSnapshot documentSnapshot = notesList[index];
                    String docId = documentSnapshot.id;
                    Map<String, dynamic> data =
                        documentSnapshot.data() as Map<String, dynamic>;
                    String title = data['title'];
                    String contents = data['contents'];
                    Timestamp time = data['time'];
                    int noteid = data['id'];
                    int color = data['colorOfTile'];

                    final note = Note(
                      docID: docId,
                      id: noteid,
                      title: title,
                      contents: contents,
                      createdTime: time,
                      colorOfTile: color,
                    );

                    return StaggeredGridTile.fit(
                      crossAxisCellCount: 1,
                      child: GestureDetector(
                        onLongPress: () {
                          log("long pressed");
                        },
                        onTap: () async {
                          Navigator.of(context)
                              .push(HeroDialogueRoute(builder: (context) {
                            return NotesViewingScreen(
                              note: note,
                            );
                          }));
                          //refreshNotes();
                        },
                        child: Hero(
                          tag: note.id.toString(),
                          child: Material(
                            child: NoteCardWidget(
                              note: note,
                              index: index,
                              colourBlindnessIndex: colourBlindnessIndex,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return const Text('No notes found');
          }
        },
      );

  Widget trashedNotes() => StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getTrashedNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarError(context, snapshot.error.toString());
            });
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List notesTrashList = snapshot.data!.docs;

            if (notesTrashList.isEmpty) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 250,
                      child: Image.asset(
                        "assets/icons/empty_trash.png",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Empty Trash',
                      style: TextStyle(
                        color: colorBlindness(
                          greyUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height *
                  0.8, // Set a specific height
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemCount: notesTrashList.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                        height: 7), // Adjust the spacing between tiles
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot = notesTrashList[index];
                  String docId = documentSnapshot.id;
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;
                  String title = data['title'];
                  String contents = data['contents'];
                  Timestamp time = data['time'];
                  int noteid = data['id'];
                  int color = data['colorOfTile'];
                  Timestamp deletedTime = data['deletedTime'];

                  final note = Note(
                    docID: docId,
                    id: noteid,
                    title: title,
                    contents: contents,
                    createdTime: time,
                    colorOfTile: color,
                    deletedTime: deletedTime,
                  );

                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context)
                          .push(HeroDialogueRoute(builder: (context) {
                        return ViewTrashedNotes(
                          note: note,
                        );
                      }));
                    },
                    child: Hero(
                      tag: note.docID.toString(),
                      child: TrashedNoteCard(
                        note: note,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text('No notes found');
          }
        },
      );

  Widget searchTrashedNotes() => StreamBuilder<List<DocumentSnapshot>>(
        stream: firestoreService.searchNotes(true, searchText),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: colorBlindness(
                orangeUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showSnackBarError(context, snapshot.error.toString());
            });
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List notesTrashList = snapshot.data!;

            if (notesTrashList.isEmpty) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 250,
                      child: Image.asset(
                        "assets/not_found.png",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'No such note in Trash',
                      style: TextStyle(
                        color: colorBlindness(
                          greyUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ),
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height *
                  0.8, // Set a specific height
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemCount: notesTrashList.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                        height: 7), // Adjust the spacing between tiles
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot documentSnapshot = notesTrashList[index];
                  String docId = documentSnapshot.id;
                  Map<String, dynamic> data =
                      documentSnapshot.data() as Map<String, dynamic>;
                  String title = data['title'];
                  String contents = data['contents'];
                  Timestamp time = data['time'];
                  int noteid = data['id'];
                  int color = data['colorOfTile'];
                  Timestamp deletedTime = data['deletedTime'];

                  final note = Note(
                    docID: docId,
                    id: noteid,
                    title: title,
                    contents: contents,
                    createdTime: time,
                    colorOfTile: color,
                    deletedTime: deletedTime,
                  );

                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context)
                          .push(HeroDialogueRoute(builder: (context) {
                        return ViewTrashedNotes(
                          note: note,
                        );
                      }));
                    },
                    child: Hero(
                      tag: note.docID.toString(),
                      child: TrashedNoteCard(
                        note: note,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Text('No notes found');
          }
        },
      );
}
