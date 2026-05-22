/// 자녀 탭 「건강 리포트」. 차트·요약은 데모 데이터 기준이며,
/// 「AI 음성 분석 · 위험 알림」은 `GET /dementia` 데이터를 사용합니다.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/child/dashboard/presentation/child_home_screen.dart'
    show ChildHealthTrendPanel;
import 'package:itda/features/child/health_monitoring/providers/health_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';

class HealthMonitoringScreen extends ConsumerWidget {
  const HealthMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = MockItdaData.weeklyMoodTrend;
    final dementiaAsync = ref.watch(parentDementiaHistoryProvider);

    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const ChildTabSliverHeader(title: '건강 리포트'),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const ChildSectionHeader(title: '일일 건강 요약'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 리포트',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: ChildDashboardColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '수면·활동·퀘스트 응답을 종합했을 때 전반적으로 안정적입니다. '
                        'EventBridge + Lambda로 매일 같은 시각에 자동 생성되는 요약 형태를 가정한 데모입니다.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: ChildDashboardColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ChildHealthTrendPanel(
                  labels: MockItdaData.dashboardChartLabels,
                  scores: MockItdaData.dashboardChartScores,
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '기분 · 활동 지수 (7일)'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (trend.length - 1).toDouble(),
                        minY: 2.5,
                        maxY: 4.5,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 0.5,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: ChildDashboardColors.orange.withValues(
                              alpha: 0.12,
                            ),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (v, m) => Text(
                                v.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ChildDashboardColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 1,
                              getTitlesWidget: (v, m) {
                                const days = [
                                  '월',
                                  '화',
                                  '수',
                                  '목',
                                  '금',
                                  '토',
                                  '일',
                                ];
                                final i = v.round().clamp(0, 6);
                                if ((v - v.round()).abs() > 0.05) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    days[i],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: ChildDashboardColors.textSub,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < trend.length; i++)
                                FlSpot(i.toDouble(), trend[i]),
                            ],
                            isCurved: true,
                            color: ChildDashboardColors.orange,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: ChildDashboardColors.orange.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '점수는 기분·활동 지표를 단순화한 데모 값입니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: ChildDashboardColors.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: 'AI 음성 분석 · 위험 알림'),
                const SizedBox(height: 10),
                _DementiaAlertPanel(
                  asyncHistory: dementiaAsync,
                  onRetry: () => ref
                      .read(parentDementiaHistoryProvider.notifier)
                      .refresh(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// "AI 음성 분석 · 위험 알림" 섹션 — `GET /dementia` 결과 중
/// 가장 최근 항목을 강조해 표시. 분석이 진행 중이거나 결과가 없으면
/// 안내 메시지를 보여줍니다.
class _DementiaAlertPanel extends StatelessWidget {
  const _DementiaAlertPanel({
    required this.asyncHistory,
    required this.onRetry,
  });

  final AsyncValue<List<DementiaAnalysisItem>> asyncHistory;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return asyncHistory.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: _decoration(highlight: false),
        child: const SizedBox(
          height: 60,
          child: Center(
            child: CircularProgressIndicator(
              color: ChildDashboardColors.orange,
            ),
          ),
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _decoration(highlight: false),
        child: _ErrorView(onRetry: onRetry),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _decoration(highlight: false),
            child: const _EmptyView(
              message:
                  '아직 분석된 음성 기록이 없어요.\n부모님의 음성 답변이 도착하면 AI 분석 결과가 여기에 표시됩니다.',
            ),
          );
        }
        // 최신 항목 1개를 메인으로 강조
        final latest = items.first;
        return _LatestAnalysisCard(item: latest, totalCount: items.length);
      },
    );
  }

  static BoxDecoration _decoration({required bool highlight}) {
    return BoxDecoration(
      color: highlight
          ? ChildDashboardColors.dangerLight.withValues(alpha: 0.65)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: highlight
          ? Border.all(
              color: ChildDashboardColors.danger.withValues(alpha: 0.25),
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: ChildDashboardColors.orange.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _LatestAnalysisCard extends StatelessWidget {
  const _LatestAnalysisCard({required this.item, required this.totalCount});

  final DementiaAnalysisItem item;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final risk = item.riskLevel ?? RiskLevel.unknown;
    final isDanger = risk == RiskLevel.high || risk == RiskLevel.medium;

    final dateLabel = _formatDate(item.completedAt ?? item.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDanger
            ? ChildDashboardColors.dangerLight.withValues(alpha: 0.65)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDanger
            ? Border.all(
                color: ChildDashboardColors.danger.withValues(alpha: 0.25),
              )
            : Border.all(
                color: ChildDashboardColors.orange.withValues(alpha: 0.15),
              ),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: isDanger
                    ? ChildDashboardColors.danger
                    : ChildDashboardColors.orange,
                size: 22,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDanger
                      ? ChildDashboardColors.danger.withValues(alpha: 0.12)
                      : ChildDashboardColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk.koreanLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: isDanger
                        ? ChildDashboardColors.danger
                        : ChildDashboardColors.orangeDark,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: ChildDashboardColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '음성·발화 패턴 분석 결과',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _summaryFor(item.status, risk, item.riskScore),
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: ChildDashboardColors.textSub,
            ),
          ),
          if (totalCount > 1) ...[
            const SizedBox(height: 10),
            Text(
              '총 $totalCount건의 분석 이력',
              style: const TextStyle(
                fontSize: 10,
                color: ChildDashboardColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusKorean(DementiaAnalysisStatus s) {
    switch (s) {
      case DementiaAnalysisStatus.pending:
        return '대기 중';
      case DementiaAnalysisStatus.transcribing:
        return '음성 변환 중';
      case DementiaAnalysisStatus.transcribed:
        return '변환 완료';
      case DementiaAnalysisStatus.analyzing:
        return '분석 중';
      case DementiaAnalysisStatus.completed:
        return '완료';
      case DementiaAnalysisStatus.failed:
        return '실패';
      case DementiaAnalysisStatus.unknown:
        return '미정';
    }
  }

  static String _summaryFor(
    DementiaAnalysisStatus status,
    RiskLevel risk,
    double? score,
  ) {
    if (status.isInProgress) {
      return '${_statusKorean(status)} — 분석이 끝나면 결과가 여기에 표시됩니다.';
    }
    if (status == DementiaAnalysisStatus.failed) {
      return '분석 처리 중 오류가 발생했어요. 음성 답변이 도착하면 다시 시도됩니다.';
    }
    if (status == DementiaAnalysisStatus.completed) {
      final scoreText = score != null
          ? ' (점수 ${(score * 100).toStringAsFixed(0)}/100)'
          : '';
      switch (risk) {
        case RiskLevel.low:
          return '발화 패턴이 안정적입니다$scoreText.';
        case RiskLevel.medium:
          return '주의 깊게 관찰이 필요한 패턴이 감지됐어요$scoreText. 정기적인 대화·검진을 권장합니다.';
        case RiskLevel.high:
          return '즉각적인 확인이 권장되는 패턴이에요$scoreText. 가능한 빨리 부모님과 대화해 보세요.';
        case RiskLevel.unknown:
          return '분석은 완료됐지만 위험 단계가 판정되지 않았어요.';
      }
    }
    return '분석 결과를 확인 중입니다.';
  }

  static String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}';
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          const Text(
            '데이터를 불러오지 못했어요.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: ChildDashboardColors.textSub,
          height: 1.5,
        ),
      ),
    );
  }
}
