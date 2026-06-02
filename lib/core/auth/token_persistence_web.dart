// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

const _tokenStorageKey = 'itda_auth_tokens';

Future<Map<String, Object?>> readPersistedTokens() async {
  try {
    final raw = html.window.localStorage[_tokenStorageKey];
    if (raw == null || raw.isEmpty) return const <String, Object?>{};
    final json = jsonDecode(raw);
    if (json is Map<String, dynamic>) return json;
  } catch (_) {
    return const <String, Object?>{};
  }
  return const <String, Object?>{};
}

Future<void> writePersistedTokens(Map<String, Object?> tokens) async {
  html.window.localStorage[_tokenStorageKey] = jsonEncode(tokens);
}

Future<void> clearPersistedTokens() async {
  html.window.localStorage.remove(_tokenStorageKey);
}
