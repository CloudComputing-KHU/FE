/// 자녀 탭 「홈」 대시보드. 차트·일부 요약은 데모 데이터 기준이며,
/// "응답 완료" / "위험 알림" 카운트, 인사 메시지, 위험 알림 카드,
/// 오늘의 퀘스트 응답은 BE 데이터를 사용합니다.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/child/dashboard/providers/dashboard_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

class ChildHomeScreen extends ConsumerWidget {
  const ChildHomeScreen({
    super.key,
    this.onOpenHealthTab,
  });

  final VoidCallback? onOpenHealthTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayQuestsAsync = ref.watch(todayQuestsProvider);
    final answeredCount = ref.watch(answeredCountTodayProvider);
    final riskCount = ref.watch(riskAlertCountProvider);
    final recentRisksAsync = ref.watch(recentRiskAlertsProvider);

    // mock 타일 4개 중 BE 데이터로 대체할 2개를 동적 값으로 생성.
    final summaryTiles = _buildSummaryTiles(
      answeredCount: answeredCount,
      riskCount: riskCount,
    );

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: ChildShellHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingCard(
                  childName: MockItdaData.childDisplayName,
                  answeredCount: answeredCount,
                ),
                const SizedBox(height: 16),
                ChildSectionHeader(
                  title: '오늘의 건강 요약',
                  trailing: '자세히',
                  onTrailing: onOpenHealthTab,
                ),
                const SizedBox(height: 10),
                _SummaryGrid(tiles: summaryTiles),
                const SizedBox(height: 18),
                ChildSectionHeader(
                  title: '위험 알림',
                  trailing: '모두 보기',
                  onTrailing: onOpenHealthTab,
                ),
                const SizedBox(height: 10),
                _RiskAlertsSection(asyncRisks: recentRisksAsync),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '오늘의 퀘스트 응답'),
                const SizedBox(height: 10),
                _TodayQuestPanel(asyncQuests: todayQuestsAsync),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 4개 타일 중 1·3번을 BE 카운트로 채우고, 2·4번은 mock 유지.
  /// (건강 점수, 연속 기록은 BE에 매칭되는 데이터가 없어 mock 그대로 둠)
  List<DashboardSummaryTile> _buildSummaryTiles({
    required int answeredCount,
    required int riskCount,
  }) {
    return [
      DashboardSummaryTile(
        label: '응답 완료',
        value: '$answeredCount',
        unit: '/3',
        sub: '오늘 퀘스트',
        variant: SummaryVariant.orange,
      ),
      // 2번: 건강 점수 — mock 유지 (BE 매칭 없음)
      MockItdaData.dashboardSummaryTiles[1],
      DashboardSummaryTile(
        label: '위험 알림',
        value: '$riskCount',
        unit: '건',
        sub: riskCount == 0 ? '안정적이에요' : '확인 필요',
        variant: SummaryVariant.coral,
      ),
      // 4번: 연속 기록 — mock 유지 (BE 매칭 없음)
      MockItdaData.dashboardSummaryTiles[3],
    ];
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.childName,
    required this.answeredCount,
  });

  final String childName;
  final int answeredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ChildDashboardColors.orange,
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요 ☀',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$childName님',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _greetingFor(answeredCount),
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  static String _greetingFor(int answered) {
    if (answered >= 3) {
      return '어머니께서 오늘 건강 퀘스트를\n모두 완료하셨어요. 안부 사진을 보내보세요!';
    }
    if (answered > 0) {
      return '어머니께서 오늘 $answered개의 퀘스트에 응답하셨어요.\n남은 응답이 도착하면 알려드릴게요.';
    }
    return '오늘은 아직 응답이 없어요.\n부모님께 안부 사진을 보내볼까요?';
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.tiles});

  final List<DashboardSummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    final chunks = <List<DashboardSummaryTile>>[];
    for (var i = 0; i < tiles.length; i += 2) {
      chunks.add(tiles.sublist(i, i + 2 > tiles.length ? tiles.length : i + 2));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < chunks.length; r++) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SummaryTileCard(tile: chunks[r][0])),
              const SizedBox(width: 10),
              Expanded(
                child: chunks[r].length > 1
                    ? _SummaryTileCard(tile: chunks[r][1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryTileCard extends StatelessWidget {
  const _SummaryTileCard({required this.tile});

  final DashboardSummaryTile tile;

  @override
  Widget build(BuildContext context) {
    final t = tile;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ChildDashboardColors.textSub,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: t.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: ChildDashboardColors.orangeDark,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: t.unit,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ChildDashboardColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            t.sub,
            style: const TextStyle(
              fontSize: 10,
              color: ChildDashboardColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class ChildHealthTrendPanel extends StatelessWidget {
  const ChildHealthTrendPanel({
    super.key,
    required this.labels,
    required this.scores,
  });

  final List<String> labels;
  final List<double> scores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주간 건강 추이',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: ChildDashboardColors.text,
            ),
          ),
          Text(
            'AI 음성 분석 · 최근 7일',
            style: TextStyle(fontSize: 10, color: ChildDashboardColors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (scores.length - 1).toDouble(),
                minY: 70,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: ChildDashboardColors.orange.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 10,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(fontSize: 9, color: ChildDashboardColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (v, m) {
                        final i = v.round().clamp(0, labels.length - 1);
                        if ((v - v.round()).abs() > 0.05) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[i],
                            style: const TextStyle(
                              fontSize: 9,
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
                      for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i]),
                    ],
                    isCurved: true,
                    color: ChildDashboardColors.orange,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 4,
                        color: ChildDashboardColors.orange,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ChildDashboardColors.orange.withValues(alpha: 0.35),
                          ChildDashboardColors.orange.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 위험 알림 섹션 — `recentRiskAlertsProvider` (BE 데이터) 표시.
/// 분석 이력에 medium/high가 있으면 카드로 보여주고, 없으면 안정 메시지를 띄움.
class _RiskAlertsSection extends StatelessWidget {
  const _RiskAlertsSection({required this.asyncRisks});

  final AsyncValue<List<DementiaAnalysisItem>> asyncRisks;

  @override
  Widget build(BuildContext context) {
    return asyncRisks.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: CircularProgressIndicator(color: ChildDashboardColors.orange),
        ),
      ),
      error: (e, _) => const _SafeMessageCard(
        message: '위험 알림 데이터를 불러오지 못했어요.',
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _SafeMessageCard(
            message: '최근 위험 신호는 없어요. 안정적으로 지내고 계세요.',
          );
        }
        return Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RiskAlertCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _SafeMessageCard extends StatelessWidget {
  const _SafeMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: ChildDashboardColors.orange.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: ChildDashboardColors.orangeDark,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ChildDashboardColors.textSub,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskAlertCard extends StatelessWidget {
  const _RiskAlertCard({required this.item});

  final DementiaAnalysisItem item;

  @override
  Widget build(BuildContext context) {
    final risk = item.riskLevel ?? RiskLevel.unknown;
    final isHigh = risk == RiskLevel.high;
    final score = item.riskScore;
    final dateLabel = _formatDate(item.completedAt ?? item.createdAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHigh
            ? ChildDashboardColors.dangerLight
            : ChildDashboardColors.warnBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isHigh
                ? ChildDashboardColors.danger
                : ChildDashboardColors.orange,
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              isHigh ? '!' : '⚠',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isHigh
                    ? ChildDashboardColors.danger
                    : ChildDashboardColors.orangeDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '음성·발화 패턴 ${risk.koreanLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ChildDashboardColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _summaryFor(risk, score),
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: ChildDashboardColors.textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateLabel · AI 음성 분석',
                  style: const TextStyle(fontSize: 9, color: ChildDashboardColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _summaryFor(RiskLevel risk, double? score) {
    final scoreText =
        score != null ? ' (점수 ${(score * 100).toStringAsFixed(0)}/100)' : '';
    switch (risk) {
      case RiskLevel.high:
        return '즉각적인 확인이 권장돼요$scoreText.';
      case RiskLevel.medium:
        return '주의 깊게 관찰이 필요한 패턴이에요$scoreText.';
      case RiskLevel.low:
      case RiskLevel.unknown:
        return '관찰이 필요한 신호$scoreText.';
    }
  }

  static String _formatDate(DateTime dt) => '${dt.month}/${dt.day}';
}

/// 「오늘의 퀘스트 응답」 — `todayQuestsProvider`의 BE 데이터로 구성.
class _TodayQuestPanel extends StatelessWidget {
  const _TodayQuestPanel({required this.asyncQuests});

  final AsyncValue<List<TodayQuestStatus>> asyncQuests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: asyncQuests.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(color: ChildDashboardColors.orange),
          ),
        ),
        error: (e, _) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '응답 정보를 불러오지 못했어요.',
            style: TextStyle(
              fontSize: 12,
              color: ChildDashboardColors.textSub,
            ),
          ),
        ),
        data: (quests) {
          return Column(
            children: [
              for (var i = 0; i < quests.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _TodayQuestRow(quest: quests[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TodayQuestRow extends StatelessWidget {
  const _TodayQuestRow({required this.quest});

  final TodayQuestStatus quest;

  @override
  Widget build(BuildContext context) {
    final preview = quest.answerPreview;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ChildDashboardColors.orangePale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ChildDashboardColors.text,
                  ),
                ),
                if (preview != null && preview.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    style: const TextStyle(
                      fontSize: 10,
                      color: ChildDashboardColors.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: quest.responded
                  ? ChildDashboardColors.successLight
                  : ChildDashboardColors.dangerLight,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              quest.responded ? '응답' : '미응답',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: quest.responded
                    ? const Color(0xFF3A7D3A)
                    : const Color(0xFFA32828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}