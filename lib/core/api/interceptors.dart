import 'package:dio/dio.dart';

import 'package:itda/core/auth/token_storage.dart';

/// Authorization 헤더 주입 (토큰 없으면 스킵)
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
