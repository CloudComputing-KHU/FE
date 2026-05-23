import 'package:dio/dio.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/auth/token_storage.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresIn,
    this.tokenType,
  });

  final String accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiresIn;
  final String? tokenType;
}

/// 인증 API 연동 서비스.
class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.create();

  final Dio _dio;

  Future<String?> signUp({
    required String role,
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authSignup,
      data: {
        'role': role,
        'name': name,
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
      },
    );
    final message = _readString(
      response.data ?? const <String, dynamic>{},
      const ['message'],
    );
    await TokenStorage.writeUserProfile(name: name, email: email, role: role);
    return message;
  }

  Future<String?> confirm({
    required String email,
    required String confirmationCode,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authConfirm,
      data: {'email': email, 'confirmation_code': confirmationCode},
    );
    return _readString(response.data ?? const <String, dynamic>{}, const [
      'message',
    ]);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );

    final data = response.data ?? const <String, dynamic>{};
    final accessToken = _readString(data, const [
      'accessToken',
      'access_token',
      'access',
    ]);
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('로그인 응답에 access token이 없습니다.');
    }

    final session = AuthSession(
      accessToken: accessToken,
      refreshToken: _readString(data, const [
        'refreshToken',
        'refresh_token',
        'refresh',
      ]),
      idToken: _readString(data, const ['idToken', 'id_token', 'id']),
      expiresIn: _readInt(data, const ['expiresIn', 'expires_in']),
      tokenType: _readString(data, const ['tokenType', 'token_type']),
    );
    await TokenStorage.writeTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      idToken: session.idToken,
      expiresIn: session.expiresIn,
    );
    await TokenStorage.writeUserProfile(email: email);
    return session;
  }

  Future<AuthSession> refresh({String? refreshToken}) async {
    final token = refreshToken ?? await TokenStorage.readRefreshToken();
    if (token == null || token.isEmpty) {
      throw const AuthException('refresh token이 없습니다.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.authRefresh,
      data: {'refresh_token': token},
    );
    final data = response.data ?? const <String, dynamic>{};
    final accessToken = _readString(data, const [
      'accessToken',
      'access_token',
      'access',
    ]);
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('토큰 갱신 응답에 access token이 없습니다.');
    }

    final session = AuthSession(
      accessToken: accessToken,
      refreshToken: token,
      idToken: _readString(data, const ['idToken', 'id_token', 'id']),
      expiresIn: _readInt(data, const ['expiresIn', 'expires_in']),
      tokenType: _readString(data, const ['tokenType', 'token_type']),
    );
    await TokenStorage.writeTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      idToken: session.idToken,
      expiresIn: session.expiresIn,
    );
    return session;
  }

  Future<void> signOut() async {
    await TokenStorage.clear();
  }

  static String messageFromError(Object error, {required String fallback}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final detail = data['detail'] ?? data['message'] ?? data['error'];
        final message = _readDetailMessage(detail);
        if (message != null && message.isNotEmpty) return message;
      }
    }
    if (error is AuthException) return error.message;
    return fallback;
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String) return value;
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return null;
  }

  static String? _readDetailMessage(Object? detail) {
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map<String, dynamic>) {
        final msg = first['msg'];
        if (msg is String) return msg;
      }
    }
    return null;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
