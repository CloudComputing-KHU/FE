import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/api/interceptors.dart';

/// Dio 공용 클라이언트. 베이스 URL·타임아웃·인증 인터셉터를 한곳에서 구성합니다.
class ApiClient {
  ApiClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(
      LogInterceptor(requestHeader: true, responseBody: true),
    );
    return dio;
  }
}
