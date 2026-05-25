/// Flutter 엔트리포인트. [ProviderScope]로 Riverpod을 켠 뒤 [ItdaApp]을 실행합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/app.dart';
import 'package:itda/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  runApp(const ProviderScope(child: ItdaApp()));
}
