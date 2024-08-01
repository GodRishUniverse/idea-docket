import 'dart:io';

import 'package:flutter/material.dart';

class Attachment {
  final String fileName;
  final Widget fileIcon;
  final String? fileUrl;
  final String fileType;
  final File? temporaryFile;

  Attachment({
    required this.fileName,
    required this.fileIcon,
    required this.fileType,
    this.fileUrl,
    this.temporaryFile,
  });
}
