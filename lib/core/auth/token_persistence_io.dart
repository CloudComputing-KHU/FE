import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _tokenFileName = 'itda_auth_tokens.json';

Future<File> _tokenFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/$_tokenFileName');
}

Future<Map<String, Object?>> readPersistedTokens() async {
  try {
    final file = await _tokenFile();
    if (!await file.exists()) return const <String, Object?>{};
    final json = jsonDecode(await file.readAsString());
    if (json is Map<String, dynamic>) return json;
  } catch (_) {
    return const <String, Object?>{};
  }
  return const <String, Object?>{};
}

Future<void> writePersistedTokens(Map<String, Object?> tokens) async {
  final file = await _tokenFile();
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(tokens));
}

Future<void> clearPersistedTokens() async {
  try {
    final file = await _tokenFile();
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
