import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

//TODO: make share note

// Function to parse JSON content from Flutter Quill Editor
Map<String, dynamic> parseJsonContent(String jsonString) {
  return json.decode(jsonString);
}

// Function to convert parsed content to RTF
String convertToRTF(Map<String, dynamic> content) {
  // Write your logic here to convert parsed content to RTF format
  return "";
}

// Function to save the generated file
Future<String> saveFile(String content, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  final file = File(filePath);
  await file.writeAsString(content);
  return filePath;
}

// Function to share the generated file
Future shareFile(XFile file) async {
  Share.shareXFiles([file], text: 'Sharing file');
}
