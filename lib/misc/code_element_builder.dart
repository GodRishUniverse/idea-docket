import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:idea_docket/theme/colours.dart';
import 'package:markdown/markdown.dart' as md;

class CodeElementBuilder extends MarkdownElementBuilder {
  // To determine whether the code is an inline code block or a code block
  bool isCodeBlock(md.Element element) {
    // Check if element has a class attribute
    if (element.attributes['class'] != null) {
      return true;
    }
    // Check for newlines in the text content, which indicate a code block
    if (element.textContent.contains("\n")) {
      return true;
    }
    // Check for inline code (single backticks without newlines)
    if (element.textContent.startsWith("`") &&
        element.textContent.endsWith("`") &&
        !element.textContent.contains("\n")) {
      return false;
    }
    return false;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (!isCodeBlock(element)) {
      return Container(
        color: darkBackground,
        child: Text(
          element.textContent,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Monospace",
            fontSize: 14,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            element.textContent,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Monospace",
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }
}
