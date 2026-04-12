/// 웹: [XFile] 바이트를 읽어 [Image.memory] 미리보기.
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget buildXFilePreview(XFile file, BoxFit fit) {
  return FutureBuilder<Uint8List>(
    future: file.readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data;
      if (data == null) {
        return const Center(child: Icon(Icons.broken_image_outlined));
      }
      return Image.memory(data, fit: fit);
    },
  );
}
