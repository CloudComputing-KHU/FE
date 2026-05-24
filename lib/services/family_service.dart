import 'package:dio/dio.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/family.dart';

class FamilyService {
  FamilyService({Dio? dio}) : _dio = dio ?? ApiClient.create();

  final Dio _dio;

  Future<FamilyInvite> createInvite() async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.familyInvites,
    );
    return FamilyInvite.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<FamilyConnectResult> connect(String inviteCode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.familyConnect,
      data: {'invite_code': inviteCode},
    );
    return FamilyConnectResult.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  Future<FamilyMe> getMyFamily() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.familyMe,
    );
    return FamilyMe.fromJson(response.data ?? const <String, dynamic>{});
  }
}
