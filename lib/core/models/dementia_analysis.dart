/// 치매 위험 분석 관련 DTO들.
///
/// 백엔드 엔드포인트:
/// - `POST /dementia/analyze` 응답 → [DementiaAnalysisResponse]
/// - `GET /dementia/{analysis_id}` 응답 → [DementiaAnalysisResult]
/// - `GET /dementia?user_id=...` 응답 → List<[DementiaAnalysisItem]>

library;

/// 분석 진행 상태.
/// pending → transcribing → transcribed → analyzing → completed | failed
enum DementiaAnalysisStatus {
  pending,
  transcribing,
  transcribed,
  analyzing,
  completed,
  failed,
  unknown;

  static DementiaAnalysisStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return DementiaAnalysisStatus.pending;
      case 'transcribing':
        return DementiaAnalysisStatus.transcribing;
      case 'transcribed':
        return DementiaAnalysisStatus.transcribed;
      case 'analyzing':
        return DementiaAnalysisStatus.analyzing;
      case 'completed':
        return DementiaAnalysisStatus.completed;
      case 'failed':
        return DementiaAnalysisStatus.failed;
      default:
        return DementiaAnalysisStatus.unknown;
    }
  }

  bool get isInProgress =>
      this == pending ||
      this == transcribing ||
      this == transcribed ||
      this == analyzing;

  bool get isDone => this == completed;
  bool get isFailed => this == failed;
}

/// 위험 단계.
enum RiskLevel {
  low,
  medium,
  high,
  unknown;

  static RiskLevel fromString(String? value) {
    switch (value) {
      case 'low':
        return RiskLevel.low;
      case 'medium':
        return RiskLevel.medium;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.unknown;
    }
  }

  /// 자녀 화면에 보여줄 한국어 라벨.
  String get koreanLabel {
    switch (this) {
      case RiskLevel.low:
        return '안정';
      case RiskLevel.medium:
        return '관찰';
      case RiskLevel.high:
        return '주의';
      case RiskLevel.unknown:
        return '미판정';
    }
  }
}

/// `POST /dementia/analyze` 응답.
class DementiaAnalysisResponse {
  const DementiaAnalysisResponse({
    required this.message,
    required this.analysisId,
    required this.answerId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  final String message;
  final String analysisId;
  final String answerId;
  final String userId;
  final DementiaAnalysisStatus status;
  final DateTime createdAt;

  factory DementiaAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return DementiaAnalysisResponse(
      message: json['message'] as String,
      analysisId: json['analysis_id'] as String,
      answerId: json['answer_id'] as String,
      userId: json['user_id'] as String,
      status: DementiaAnalysisStatus.fromString(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// `GET /dementia/{analysis_id}` 응답 — 단건 상세.
class DementiaAnalysisResult {
  const DementiaAnalysisResult({
    required this.analysisId,
    required this.answerId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.transcript,
    this.riskLevel,
    this.riskScore,
    this.analysisSummary,
    this.indicators,
    this.completedAt,
  });

  final String analysisId;
  final String answerId;
  final String userId;
  final DementiaAnalysisStatus status;
  final DateTime createdAt;

  /// 음성 → 텍스트 변환 결과 (완료 시)
  final String? transcript;

  /// 위험 단계 (완료 시)
  final RiskLevel? riskLevel;

  /// 위험 점수 0.0~1.0 (완료 시)
  final double? riskScore;

  /// AI 요약 텍스트 (완료 시)
  final String? analysisSummary;

  /// 분석 지표 키워드 목록 (완료 시)
  final List<String>? indicators;

  /// 분석 완료 시각 (status == completed)
  final DateTime? completedAt;

  factory DementiaAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DementiaAnalysisResult(
      analysisId: json['analysis_id'] as String,
      answerId: json['answer_id'] as String,
      userId: json['user_id'] as String,
      status: DementiaAnalysisStatus.fromString(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      transcript: json['transcript'] as String?,
      riskLevel: json['risk_level'] != null
          ? RiskLevel.fromString(json['risk_level'] as String)
          : null,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      analysisSummary: json['analysis_summary'] as String?,
      indicators: (json['indicators'] as List<dynamic>?)?.cast<String>(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

/// `GET /dementia?user_id=...` 응답 — 이력 목록 한 항목.
/// [DementiaAnalysisResult]보다 가벼운 필드 (transcript/summary 없음).
class DementiaAnalysisItem {
  const DementiaAnalysisItem({
    required this.analysisId,
    required this.answerId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.riskLevel,
    this.riskScore,
    this.completedAt,
  });

  final String analysisId;
  final String answerId;
  final String userId;
  final DementiaAnalysisStatus status;
  final DateTime createdAt;
  final RiskLevel? riskLevel;
  final double? riskScore;
  final DateTime? completedAt;

  factory DementiaAnalysisItem.fromJson(Map<String, dynamic> json) {
    return DementiaAnalysisItem(
      analysisId: json['analysis_id'] as String,
      answerId: json['answer_id'] as String,
      userId: json['user_id'] as String,
      status: DementiaAnalysisStatus.fromString(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      riskLevel: json['risk_level'] != null
          ? RiskLevel.fromString(json['risk_level'] as String)
          : null,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}