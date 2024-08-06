import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:color_blindness/color_blindness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idea_docket/attachments_service/attachment.dart';
import 'package:idea_docket/attachments_service/combined_attachment.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:idea_docket/data_management/firebase_storage_for_notes.dart';
import 'package:idea_docket/misc/snack_bar.dart';
import 'package:idea_docket/pages/notes/cubits/attachment_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/deleted_file_urls_cubit.dart';
import 'package:idea_docket/pages/notes/cubits/temporary_attachment_cubit.dart';
import 'package:mime/mime.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttachmentUI extends StatefulWidget {
  const AttachmentUI({
    super.key,
  });

  @override
  State<AttachmentUI> createState() => _AttachmentUIState();
}

class _AttachmentUIState extends State<AttachmentUI>
    with SingleTickerProviderStateMixin {
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

  @override
  void didChangeDependencies() {
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        decoration: BoxDecoration(
          color: greyUsedOpacityLowered.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: blackUsed.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BlocBuilder<AttachmentUrlsCubit, List<String>>(
          builder: (context, attachmentUrls) {
            return BlocBuilder<TemporaryAttachmentForNotesCubit, List<File>>(
              builder: (context, temporaryAttachments) {
                List<CombinedAttachment> combinedAttachments = [
                  ...attachmentUrls.map((url) => CombinedAttachment(url: url)),
                  ...temporaryAttachments
                      .map((file) => CombinedAttachment(file: file)),
                ];

                if (combinedAttachments.isEmpty) {
                  return Center(
                      child: Text(
                    'No attachments',
                    style: TextStyle(
                      color: colorBlindness(
                        whiteUsed,
                        returnColorBlindNessTypeFromIndex(
                          colourBlindnessIndex,
                        ),
                      ),
                      fontSize: 22,
                    ),
                  ));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: combinedAttachments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Center(
                          child: Text(
                        "Attachments",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "GilroyBold",
                        ),
                      ));
                    }
                    CombinedAttachment combinedAttachment =
                        combinedAttachments[index - 1];
                    return FutureBuilder(
                        future: combinedAttachment.url != null
                            ? getAttachmentFromUrl(combinedAttachment.url!)
                            : Future.value(getAttachmentFromFile(
                                combinedAttachment.file!)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: colorBlindness(
                                orangeUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                            ));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            Attachment attachment = snapshot.data!;
                            return AttachmentTile(
                              attachment: attachment,
                              colourBlindnessIndex: colourBlindnessIndex,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        });
                  },
                );
              },
            );
          },
        ),
        //   ],
        // ),
      ),
    );
  }

  Future<Attachment> getAttachmentFromUrl(String url) async {
    String fileType = await FirebaseStorageService.getFileType(url);
    return Attachment(
      fileName: await FirebaseStorageService.getFileName(url),
      fileIcon: fileIconAssigner(fileType),
      fileType: fileType,
      fileUrl: url,
    );
  }

  Attachment getAttachmentFromFile(File file) {
    String fileType = lookupMimeType(file.path) ?? "general";
    String fileName = path.basename(file.path);
    return Attachment(
      fileName: fileName,
      fileIcon: fileIconAssigner(fileType),
      fileType: fileType,
      temporaryFile: file,
    );
  }

  Widget fileIconAssigner(String mimeType) {
    String icon = "assets/attachments";
    switch (mimeType) {
      case "application/pdf":
        icon = "$icon/pdf.png";
        break;
      case "application/msword":
      case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
        icon = "$icon/doc.png";
        break;

      case "application/vnd.ms-excel":
      case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
        icon = "$icon/xls.png";
        break;

      case "application/vnd.ms-powerpoint":
      case "application/vnd.openxmlformats-officedocument.presentationml.presentation":
        icon = "$icon/ppt.png";
        break;
      case "image/jpeg":
      case "image/png":
      case "image/gif":
      case "image/bmp":
      case "image/webp":
        icon = "$icon/img.png";
        break;
      case "video/mp4":
      case "video/avi":
      case "video/mpeg":
      case "video/webm":
        icon = "$icon/video.png";
        break;

      case "audio/mpeg":
      case "audio/wav":
      case "audio/ogg":
      case "audio/webm":
        icon = "$icon/audio.png";
        break;
      case "text/plain":
      case "text/csv":
        icon = "$icon/txt-file.png";
        break;

      case "text/html":
      case "text/css":
      case "text/x-python":
      case "text/x-java-source":
      case "text/x-csrc":
      case "text/x-c++src":
      case "application/xml":
      case "application/javascript":
      case "application/json":
        icon = "$icon/source-code.png";
        break;
      default:
        icon = "$icon/general-file.png";
    }

    return SizedBox(
      height: 60,
      width: 60,
      child: Image.asset(
        icon,
      ),
    );
  }
}

class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.attachment,
    required this.colourBlindnessIndex,
  });

  final Attachment attachment;

  final int colourBlindnessIndex;

  Future<String> getFileExtension() async {
    final ref = FirebaseStorageService.storage.refFromURL(attachment.fileUrl!);

    final metadata = await ref.getMetadata();
    final mimetype = metadata.contentType;
    return extensionFromMime(mimetype!);
  }

  @override
  Widget build(BuildContext context) {
    final TemporaryAttachmentForNotesCubit attachmentForNotesCubit =
        BlocProvider.of<TemporaryAttachmentForNotesCubit>(context);

    final AttachmentUrlsCubit attachmentUrlsCubit =
        BlocProvider.of<AttachmentUrlsCubit>(context);

    final DeletedFileUrlsCubit deletedFileUrlsCubit =
        BlocProvider.of<DeletedFileUrlsCubit>(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 2,
        top: 2,
      ),
      child: GestureDetector(
        onTap: () async {
          if (attachment.fileUrl == null) {
            OpenFile.open(attachment.temporaryFile!.path);
          } else {
            File? file;
            try {
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
                      title: Text(
                        "Downloading...",
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
                      backgroundColor: colorBlindness(
                        darkBackground,
                        returnColorBlindNessTypeFromIndex(
                          colourBlindnessIndex,
                        ),
                      ),
                    );
                  });

              final directory = await getApplicationDocumentsDirectory();

              final ref = FirebaseStorageService.storage
                  .refFromURL(attachment.fileUrl!);

              final metadata = await ref.getMetadata();
              final mimetype = metadata.contentType;
              final ext = extensionFromMime(mimetype!);

              final downloadFilePath =
                  '${directory.path}/${attachment.fileName.substring(41)}.$ext';
              log(downloadFilePath);

              file = File(downloadFilePath);

              final bytes = await ref.getData();
              await file.writeAsBytes(bytes!);

              await file.create();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });

              final result = await OpenFile.open(file.path);
              if (result.type != ResultType.done) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showSnackBarError(
                      context, "Could not open file: ${result.type}!");
                });
              }
            } catch (e) {
              // log('Error downloading file: $e');
              if (e is FirebaseException) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showSnackBarError(context, "Could not open file: ${e.code}!");
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showSnackBarError(context, "Some error occured!");
                });
              }
              // throw Exception('Error downloading and opening the file: $e');
            }
          }
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: greyUsed,
          ),
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: attachment.fileIcon,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        (attachment.fileUrl != null)
                            ? attachment.fileName.substring(41)
                            : attachment.fileName,
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
                      const SizedBox(
                        height: 4,
                      ),
                      FutureBuilder(
                        future: (attachment.fileUrl != null)
                            ? getFileExtension()
                            : Future.value(
                                extensionFromMime(attachment.fileType)),
                        builder: (context, snapshot) {
                          return Text(
                            'File Type: ${snapshot.data ?? "Loading..."}',
                            style: TextStyle(
                              color: colorBlindness(
                                whiteUsed,
                                returnColorBlindNessTypeFromIndex(
                                  colourBlindnessIndex,
                                ),
                              ),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (attachment.fileUrl == null) {
                        attachmentForNotesCubit
                            .removeFromCubit(attachment.temporaryFile!);
                      } else {
                        attachmentUrlsCubit
                            .removeFromCubit(attachment.fileUrl!);

                        deletedFileUrlsCubit.addToCubit(attachment.fileUrl!);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: Colors.transparent,
                      ),
                      child: Tooltip(
                        message: "Remove",
                        child: Icon(
                          Icons.cancel,
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
    );
  }
}
