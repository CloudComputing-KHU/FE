import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:itda/shared/widgets/xfile_preview_io.dart'
    if (dart.library.html) 'package:itda/shared/widgets/xfile_preview_web.dart' as impl;

/// 플랫폼별 사진 미리보기 (모바일: 파일, 웹: 메모리)
Widget xFilePreview(XFile file, {BoxFit fit = BoxFit.cover}) =>
    impl.buildXFilePreview(file, fit);
