/// 자녀 탭 「홈」 대시보드. 요약 타일·차트·알림·퀘스트 목록을 보여줍니다.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({
    super.key,
    this.onOpenHealthTab,
    this.onRoleSwitch,
  });

  final VoidCallback? onOpenHealthTab;
  final VoidCallback? onRoleSwitch;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: ChildShellHeader(onRoleSwitch: onRoleSwitch)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingCard(childName: MockItdaData.childDisplayName),
                const SizedBox(height: 16),
                ChildSectionHeader(
                  title: '오늘의 건강 요약',
                  trailing: '자세히 →',
                  onTrailing: onOpenHealthTab,
                ),
                const SizedBox(height: 10),
                _SummaryGrid(tiles: MockItdaData.dashboardSummaryTiles),
                const SizedBox(height: 18),
                ChildSectionHeader(
                  title: '위험 알림',
                  trailing: '모두 보기 →',
                  onTrailing: onOpenHealthTab,
                ),
                const SizedBox(height: 10),
                ...MockItdaData.dashboardRiskAlerts.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RiskAlertCard(alert: a),
                  ),
                ),
                const SizedBox(height: 18),
                ChildSectionHeader(title: '오늘의 퀘스트 응답'),
                const SizedBox(height: 10),
                _TodayQuestPanel(quests: MockItdaData.dashboardTodayQuests),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.childName});

  final String childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ChildDashboardColors.orange, ChildDashboardColors.orangeMid],
        ),
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
            MockItdaData.dashboardGreetingLine,
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
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.tiles});

  final List<DashboardSummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    // SliverList 안의 shrinkWrap GridView는 세로 여백이 비정상적으로 커질 수 있어
    // 2열 고정 레이아웃은 Row/Column이 안전합니다.
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

class _RiskAlertCard extends StatelessWidget {
  const _RiskAlertCard({required this.alert});

  final DashboardRiskAlert alert;

  @override
  Widget build(BuildContext context) {
    final danger = alert.danger;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: danger ? ChildDashboardColors.dangerLight : ChildDashboardColors.warnBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: danger ? ChildDashboardColors.danger : ChildDashboardColors.orange,
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
              danger ? '!' : '⚠',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: danger ? ChildDashboardColors.danger : ChildDashboardColors.orangeDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ChildDashboardColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.desc,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: ChildDashboardColors.textSub,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.time,
                  style: const TextStyle(fontSize: 9, color: ChildDashboardColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayQuestPanel extends StatelessWidget {
  const _TodayQuestPanel({required this.quests});

  final List<DashboardTodayQuest> quests;

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
        children: [
          for (var i = 0; i < quests.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ChildDashboardColors.orangePale,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      quests[i].q,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ChildDashboardColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: quests[i].positive ? ChildDashboardColors.successLight : ChildDashboardColors.dangerLight,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      quests[i].positive ? '예' : '아니오',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: quests[i].positive
                            ? const Color(0xFF3A7D3A)
                            : const Color(0xFFA32828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
