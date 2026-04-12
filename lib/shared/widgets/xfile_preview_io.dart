/// 모바일·데스크톱: [XFile] 경로로 [Image.file] 미리보기.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget buildXFilePreview(XFile file, BoxFit fit) {
  return Image.file(File(file.path), fit: fit);
}
