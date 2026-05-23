import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/auth/token_storage.dart';

/// Authorization 헤더 주입 (토큰 없으면 스킵)
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token =
        await TokenStorage.readIdToken() ??
        await TokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final alreadyRetried = request.extra['authRetry'] == true;
    final canRefresh =
        err.response?.statusCode == 401 &&
        !alreadyRetried &&
        request.path != ApiEndpoints.authLogin &&
        request.path != ApiEndpoints.authRefresh;

    if (!canRefresh) {
      handler.next(err);
      return;
    }

    final refreshToken = await TokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await TokenStorage.clear();
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: request.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data ?? const <String, dynamic>{};
      final accessToken = _readString(data, const [
        'accessToken',
        'access_token',
        'access',
      ]);
      if (accessToken == null || accessToken.isEmpty) {
        await TokenStorage.clear();
        handler.next(err);
        return;
      }

      await TokenStorage.writeTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: _readString(data, const ['idToken', 'id_token', 'id']),
        expiresIn: _readInt(data, const ['expiresIn', 'expires_in']),
      );

      final authToken = await TokenStorage.readIdToken() ?? accessToken;
      request.extra['authRetry'] = true;
      request.headers['Authorization'] = 'Bearer $authToken';
      final retryResponse = await refreshDio.fetch<dynamic>(request);
      handler.resolve(retryResponse);
    } catch (_) {
      await TokenStorage.clear();
      handler.next(err);
    }
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
}
