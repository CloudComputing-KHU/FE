import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/dementia_analysis.dart';

/// 치매 위험 분석 API 클라이언트.
///
/// 백엔드 엔드포인트:
/// - `POST /dementia/analyze` — 음성 답변에 대한 분석 요청 (비동기, 즉시 analysis_id 반환)
/// - `GET /dementia/{analysis_id}` — 분석 결과 단건 상세 조회
/// - `GET /dementia` — 로그인 사용자의 분석 이력 조회
class DementiaService {
  DementiaService(this._dio);

  final Dio _dio;

  /// 이미 업로드된 음성 답변에 대한 치매 분석을 요청합니다.
  /// 응답 즉시 [DementiaAnalysisResponse]를 받지만 status는 `pending`이며,
  /// 실제 분석은 백엔드 백그라운드에서 진행됩니다.
  Future<DementiaAnalysisResponse> requestAnalysis({
    required String answerId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.dementiaAnalyze,
      data: {'answer_id': answerId},
    );
    return DementiaAnalysisResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// 분석 결과 단건 상세 조회. status에 따라 채워진 필드가 다릅니다.
  Future<DementiaAnalysisResult> getAnalysis(String analysisId) async {
    final response = await _dio.get(
      ApiEndpoints.dementiaAnalysisById(analysisId),
    );
    return DementiaAnalysisResult.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// 로그인 사용자의 분석 이력을 최신순으로 조회합니다.
  Future<List<DementiaAnalysisItem>> getUserAnalyses() async {
    final response = await _dio.get(ApiEndpoints.dementia);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => DementiaAnalysisItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
