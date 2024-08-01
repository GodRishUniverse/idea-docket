import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/translations.dart';
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:idea_docket/attachments_service/attachment_ui.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:idea_docket/data_management/firebase_storage_for_notes.dart';
import 'package:idea_docket/data_management/firestore_notes_crud_and_search.dart';
import 'package:idea_docket/gemini_tools/image_to_note_using_gemini.dart';
import 'package:idea_docket/misc/hero_dialogue_route.dart';
import 'package:idea_docket/models/note_model.dart';
import 'package:idea_docket/pages/notes/cubits/attachment_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/deleted_file_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/image_permission_cubit.dart';
import 'package:idea_docket/misc/speech_to_text_widget.dart';
import 'package:idea_docket/pages/notes/cubits/temporary_attachment_cubit.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAndUpdateNotePopUpCard extends StatefulWidget {
  final Note? note;
  const AddAndUpdateNotePopUpCard({
    super.key,
    this.note,
  });

  @override
  State<AddAndUpdateNotePopUpCard> createState() => _AddNotePopUpCardState();
}

class _AddNotePopUpCardState extends State<AddAndUpdateNotePopUpCard> {
  final FirestoreService firestoreService = FirestoreService();

  final FirebaseStorageService firebaseStorageService =
      FirebaseStorageService();

  final quill.QuillController controller = quill.QuillController.basic();

  TextEditingController controllerForTitle = TextEditingController();

  ScrollController scrollController = ScrollController();

  bool isTitleEmpty = true;
  bool isEditorEmpty = true;
  bool updatingNote = false;

  // List<String> attachmentUrls = [];

  late TemporaryAttachmentForNotesCubit _temporaryAttachmentsCubit;
  late AttachmentUrlsCubit _attachmentUrlsCubit;
  late DeletedFileUrlsCubit _deletedFileUrlsCubit;

  int colourBlindnessIndex = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));

    controllerForTitle.addListener(_onTitleChanged);

    if (widget.note != null && widget.note!.isNotEmpty) {
      final json = jsonDecode(widget.note!.contents);

      controller.document = quill.Document.fromJson(json);

      controllerForTitle.text = widget.note!.title;
      updatingNote = true;

      _attachmentUrlsCubit = context.read<AttachmentUrlsCubit>();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _attachmentUrlsCubit.updateCubit(await firestoreService
            .getListOfAttachmentUrls(widget.note!.docID!));
      });

      // attachmentUrls = firestoreService
      //     .getListOfAttachmentUrls(widget.note!.docID!) as List<String>;
      setState(() {});
    }

    _deletedFileUrlsCubit = context.read<DeletedFileUrlsCubit>();

    _temporaryAttachmentsCubit =
        context.read<TemporaryAttachmentForNotesCubit>();

    initColourBlindnessIndex();
  }

  Future initColourBlindnessIndex() async {
    final prefs = await SharedPreferences.getInstance();

    colourBlindnessIndex = prefs.getInt('colourBlindnessChosen') ?? 0;
  }

  void _onTitleChanged() {
    final content = controllerForTitle.text.trim();
    setState(() {
      if (content.isNotEmpty) {
        isTitleEmpty = false;
      } else {
        isTitleEmpty = true;
      }
    });
  }

  @override
  void dispose() {
    _temporaryAttachmentsCubit.emptyTempList();
    controller.dispose();
    controllerForTitle.removeListener(_onTitleChanged);
    controllerForTitle.dispose();

    super.dispose();
  }

  Future<MultimediaPermission> requestPermissionForMedia() async {
    PermissionStatus result;
    if (Platform.isAndroid) {
      result = await Permission.camera.request();
    } else {
      result = await Permission.camera.request();
    }

    if (result.isGranted) {
      return MultimediaPermission.permissionGranted;
    } else if (Platform.isIOS || result.isPermanentlyDenied) {
      return MultimediaPermission.noStoragePermissionPermanently;
    }
    return MultimediaPermission.noStoragePermission;
  }

  // Method to pick an image/Video from the device's gallery
  Future<void> pickImageOrVideo(bool isImage) async {
    // Request permission
    final permission = await requestPermissionForMedia();

    // Check if permission is granted
    if (permission == MultimediaPermission.permissionGranted) {
      // Initialize an instance of ImagePicker
      final ImagePicker picker = ImagePicker();
      // Use ImagePicker to select an image/video from the gallery
      final XFile? picked;

      if (isImage) {
        picked = await picker.pickImage(source: ImageSource.gallery);
      } else {
        picked = await picker.pickVideo(source: ImageSource.gallery);
      }

      // Check if an image/video was successfully picked
      if (picked != null) {
        String? link = await firebaseStorageService.uploadMedia(picked);

        if (link != null) {
          // Create a Delta representing the image to insert into the editor
          final Delta delta;

          if (isImage) {
            delta = Delta()
              // Insert a new line before the image
              ..insert("\n")
              // Insert the image data as a map
              ..insert({
                // 'image' key represents the image data, in this case, the file path
                'image': link,
              })
              // Insert a new line after the image
              ..insert("\n");
          } else {
            delta = Delta()
              // Insert a new line before the image
              ..insert("\n")
              // Insert the image data as a map
              ..insert({
                // 'image' key represents the video data, in this case, the file path
                'video': link,
              })
              // Insert a new line after the image
              ..insert("\n");
          }

          // Compose the Delta into the Quill controller
          controller.compose(
            delta, // Delta representing the image
            // Set the text selection to the end of the inserted image
            TextSelection.collapsed(offset: delta.length),
            // Specify that the change was made locally
            quill.ChangeSource.local,
          );

          setState(() {}); // Ensure the editor updates
        }
      }
    }
  }

  Future<void> attachmentPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      // tempListOfFiles.add(file);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TemporaryAttachmentForNotesCubit>().addToCubit(file);
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final multimediaPermissionCubit =
        BlocProvider.of<MultimediaPermissionCubit>(context);

    return BlocListener<MultimediaPermissionCubit, MultimediaPermission>(
      listener: (context, state) {
        switch (state) {
          case MultimediaPermission.permissionGranted:
            break;
          case MultimediaPermission.noStoragePermission:
          case MultimediaPermission.noStoragePermissionPermanently:
            permissionDeniedErrorDialog(context);
            break;
        }
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: colorBlindness(
            darkBackground,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
          foregroundColor: colorBlindness(
            orangeUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
          elevation: 5.0,
          title: Text(
            updatingNote ? "Update Note" : "Add a note",
            style: const TextStyle(
              color: orangeUsed,
              fontFamily: "GilroyBold",
              fontSize: 19,
            ),
          ),
          actions: [
            Visibility(
              visible: !updatingNote,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (isTitleEmpty)
                        ? null
                        : colorBlindness(
                            greyUsedOpacityLowered,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                  ),
                  child: IconButton(
                    tooltip: "Image to note",
                    disabledColor: colorBlindness(
                      greyUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    onPressed: (isTitleEmpty)
                        ? () async {
                            final permission =
                                await requestPermissionForMedia();
                            multimediaPermissionCubit
                                .updateMultimediaPermission(permission);

                            if (permission ==
                                MultimediaPermission.permissionGranted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.of(context)
                                    .push(HeroDialogueRoute(builder: (context) {
                                  return const ImageToNote();
                                }));
                              });
                            }
                          }
                        : null,
                    icon: Hero(
                      tag: "image-to-note",
                      child: Icon(
                        Icons.camera,
                        color: (isTitleEmpty)
                            ? colorBlindness(
                                whiteUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              )
                            : colorBlindness(
                                greyUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !updatingNote,
              child: const SizedBox(
                width: 5,
              ),
            ),
            SpeechToTextWidget(
              controller: controller,
              colourBlindnessIndex: colourBlindnessIndex,
            ),
            const SizedBox(
              width: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Tooltip(
                message:
                    (!isTitleEmpty) ? "Add note" : "Enter title to add note",
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: (!isTitleEmpty)
                        ? null
                        : colorBlindness(
                            greyUsedOpacityLowered,
                            returnColorBlindNessTypeFromIndex(
                              colourBlindnessIndex,
                            ),
                          ),
                  ),
                  child: IconButton(
                    disabledColor: colorBlindness(
                      greyUsed,
                      returnColorBlindNessTypeFromIndex(
                        colourBlindnessIndex,
                      ),
                    ),
                    onPressed: (!isTitleEmpty)
                        ? (updatingNote ? updateNote : addNote)
                        : null,
                    icon: Icon(
                      updatingNote ? Icons.update : Icons.note_add,
                      color: (!isTitleEmpty)
                          ? colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            )
                          : colorBlindness(
                              greyUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                      size: 30,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        backgroundColor: colorBlindness(
          noteBackground,
          returnColorBlindNessTypeFromIndex(
            colourBlindnessIndex,
          ),
        ),
        body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TitleWidget(controllerForTitle: controllerForTitle),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: colorBlindness(
                          darkBackground,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ).withOpacity(0.8),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: TextTheme(
                            labelMedium: TextStyle(
                              color: colorBlindness(
                                whiteUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                              fontSize: 16,
                            ),
                          ),
                          iconTheme: IconThemeData(
                            color: colorBlindness(
                              whiteUsed,
                              returnColorBlindNessTypeFromIndex(
                                colourBlindnessIndex,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: FlutterQuillLocalizationsWidget(
                                child: quill.QuillToolbarCustomButton(
                                  controller: controller,
                                  options:
                                      quill.QuillToolbarCustomButtonOptions(
                                          icon: const Icon(Icons.undo),
                                          onPressed: controller.undo),
                                ),
                              ),
                            ),
                            Expanded(
                              child: FlutterQuillLocalizationsWidget(
                                child: quill.QuillToolbarCustomButton(
                                  controller: controller,
                                  options:
                                      quill.QuillToolbarCustomButtonOptions(
                                          icon: const Icon(Icons.redo),
                                          onPressed: controller.redo),
                                ),
                              ),
                            ),
                            FlutterQuillLocalizationsWidget(
                              child: quill.QuillToolbarFontFamilyButton(
                                controller: controller,
                              ),
                            ),
                            FlutterQuillLocalizationsWidget(
                              child: quill.QuillToolbarFontSizeButton(
                                controller: controller,
                              ),
                            ),
                            Expanded(
                              child: FlutterQuillLocalizationsWidget(
                                child: quill.QuillToolbarCustomButton(
                                  controller: controller,
                                  options:
                                      quill.QuillToolbarCustomButtonOptions(
                                    icon: const Tooltip(
                                      message: "Add attachment",
                                      child: Icon(Icons.attachment),
                                    ),
                                    onPressed: attachmentPicker,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      NoteEditorWidget(
                          controller: controller, updatingNote: updatingNote),
                      AttachmentsWidget(
                        updatingNote: updatingNote,
                        widget: widget,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: isKeyboardVisible ? 60 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 5,
                    top: 10,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: colorBlindness(
                          blackUsed,
                          returnColorBlindNessTypeFromIndex(
                            colourBlindnessIndex,
                          ),
                        ).withOpacity(0.9),
                      ),
                      child: Row(
                        children: [
                          BasicToolbarForNoteEditorWidget(
                            controller: controller,
                            colourBlindnessIndex: colourBlindnessIndex,
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                              iconTheme: IconThemeData(
                                color: colorBlindness(
                                  whiteUsed,
                                  returnColorBlindNessTypeFromIndex(
                                    colourBlindnessIndex,
                                  ),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                FlutterQuillLocalizationsWidget(
                                    child: quill.QuillToolbarColorButton(
                                  controller: controller,
                                  isBackground: false,
                                )),
                                quill.QuillToolbarCustomButton(
                                  controller: controller,
                                  options:
                                      quill.QuillToolbarCustomButtonOptions(
                                    icon: const Icon(Icons.image),
                                    onPressed: () async {
                                      await pickImageOrVideo(true);
                                    },
                                  ),
                                ),
                                quill.QuillToolbarCustomButton(
                                  controller: controller,
                                  options:
                                      quill.QuillToolbarCustomButtonOptions(
                                    icon: const Icon(Icons.video_camera_back),
                                    onPressed: () async {
                                      await pickImageOrVideo(false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<dynamic> permissionDeniedErrorDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_outlined,
            size: 35,
          ),
          title: const Text('Permission Denied!!!'),
          content: const Text(
              'You need to grant storage permission in the Settings to proceed.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future addNote() async {
    int lastId = await firestoreService.getLastStoredValue();

    List<String> vals = [];

    for (File file in _temporaryAttachmentsCubit.state) {
      String? link = await firebaseStorageService.uploadAttachmentFile(file);
      if (link != null) {
        vals.add(link);
      }
    }

    final note = Note(
      id: lastId + 1,
      title: controllerForTitle.text.trim(),
      contents: jsonEncode(controller.document.toDelta().toJson()),
      createdTime: Timestamp.now(),
      colorOfTile: getRandomLightColour().value,
      attachments: vals,
    );

    firestoreService.addNote(note);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
    });
  }

  Future updateNote() async {
    //Loading animation
    showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            icon: Center(
              child: CircularProgressIndicator(
                color: colorBlindness(
                  orangeUsed,
                  returnColorBlindNessTypeFromIndex(
                    colourBlindnessIndex,
                  ),
                ),
              ),
            ),
            backgroundColor: colorBlindness(
              darkBackground,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
          );
        });

    List<String> vals = [];

    for (File file in _temporaryAttachmentsCubit.state) {
      String? link = await firebaseStorageService.uploadAttachmentFile(file);
      if (link != null) {
        vals.add(link);
      }
    }

    // Deletes the files from firebase when updated note
    for (String url in _deletedFileUrlsCubit.state) {
      await FirebaseStorageService.deleteFile(url);
    }

    _deletedFileUrlsCubit.emptyTempList();

    List<String> valueToBeUpdated = [...vals, ..._attachmentUrlsCubit.state];
    final note = Note(
      id: widget.note!.id,
      title: controllerForTitle.text.trim(),
      contents: jsonEncode(controller.document.toDelta().toJson()),
      createdTime: Timestamp.now(),
      colorOfTile: widget.note!.colorOfTile,
      attachments: valueToBeUpdated,
    );

    await firestoreService.updateNote(widget.note!.docID!, note);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }
}

class SpeechToTextWidget extends StatelessWidget {
  const SpeechToTextWidget({
    super.key,
    required this.controller,
    required this.colourBlindnessIndex,
  });

  final quill.QuillController controller;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Tooltip(
          message: "Use speech to add note contents.",
          child: IconButton(
            disabledColor: colorBlindness(
              greyUsed,
              returnColorBlindNessTypeFromIndex(
                colourBlindnessIndex,
              ),
            ),
            onPressed: () async {
              final result = await Navigator.of(context)
                  .push(HeroDialogueRoute(builder: (context) {
                return const ListeningWidget(
                  heroTag: "speech-to-text",
                  isNote: true,
                );
              }));

              if (result != null && result is String) {
                // Get the current document length
                final int length = controller.document.length - 1;

                final delta = Delta()
                  ..retain(length)
                  ..insert("\n$result");

                controller.compose(
                  delta,
                  TextSelection.fromPosition(TextPosition(offset: length)),
                  quill.ChangeSource.local,
                );
              }
            },
            icon: Hero(
              tag: "speech-to-text",
              child: Icon(
                Icons.mic_none,
                color: colorBlindness(
                  whiteUsed,
                  returnColorBlindNessTypeFromIndex(
                    colourBlindnessIndex,
                  ),
                ),
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BasicToolbarForNoteEditorWidget extends StatelessWidget {
  const BasicToolbarForNoteEditorWidget({
    super.key,
    required this.controller,
    required this.colourBlindnessIndex,
  });

  final quill.QuillController controller;
  final int colourBlindnessIndex;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: colorBlindness(
            whiteUsed,
            returnColorBlindNessTypeFromIndex(
              colourBlindnessIndex,
            ),
          ),
        ),
        textTheme: TextTheme(
          labelMedium: TextStyle(
              color: colorBlindness(
                whiteUsed,
                returnColorBlindNessTypeFromIndex(
                  colourBlindnessIndex,
                ),
              ),
              fontSize: 16),
        ),
      ),
      child: quill.QuillToolbar.simple(
        configurations: quill.QuillSimpleToolbarConfigurations(
          controller: controller,
          showClipboardCopy: false,
          showClipboardPaste: false,
          showClipboardCut: false,
          showBackgroundColorButton: false,
          showLink: false,
          showSearchButton: false,
          showClearFormat: false,
          showStrikeThrough: false,
          showHeaderStyle: false,
          showDividers: false,
          showInlineCode: false,
          showColorButton: false,
          showUndo: false,
          showRedo: false,
          showFontFamily: false,
          showFontSize: false,
          showIndent: false,
        ),
      ),
    );
  }
}

class AttachmentsWidget extends StatelessWidget {
  const AttachmentsWidget({
    super.key,
    required this.updatingNote,
    required this.widget,
  });

  final bool updatingNote;
  final AddAndUpdateNotePopUpCard widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<AttachmentUrlsCubit, List<String>>(
        builder: (context, attachmentUrls) {
          return BlocBuilder<TemporaryAttachmentForNotesCubit, List<File>>(
            builder: (context, temporaryAttachments) {
              if (temporaryAttachments.isNotEmpty ||
                  (updatingNote &&
                      widget.note != null &&
                      attachmentUrls.isNotEmpty)) {
                return const AttachmentUI();
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}

class NoteEditorWidget extends StatelessWidget {
  const NoteEditorWidget({
    super.key,
    required this.controller,
    required this.updatingNote,
  });

  final quill.QuillController controller;
  final bool updatingNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: blackUsed,
          fontFamily: "GilroyBold",
          fontSize: 16,
        ),
        child: Scrollbar(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: quill.QuillEditor(
              configurations: quill.QuillEditorConfigurations(
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                controller: controller,
                padding: const EdgeInsets.all(8),
                scrollable: false,
                autoFocus: false,
                expands: false,
                placeholder: updatingNote ? "" : 'Write your Note here...',
                enableScribble: true,
                enableSelectionToolbar: true,
              ),
              scrollController: ScrollController(),
              focusNode: FocusNode(),
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
    return TextField(
      controller: controllerForTitle,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: blackUsed,
          fontFamily: "GilroyBold",
          fontSize: 30,
        ),
      ),
      cursorColor: greyUsed,
      style: const TextStyle(
        color: blackUsed,
        fontFamily: "GilroyBold",
        fontSize: 29,
      ),
    );
  }
}

// class ToolbarWithUndoAndRedo extends StatelessWidget {
//   const ToolbarWithUndoAndRedo({
//     super.key,
//     required this.controller,
//   });

//   final quill.QuillController controller;

//   @override
//   Widget build(BuildContext context) {
//     return ;
//   }
// }
