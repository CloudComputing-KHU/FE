/// 자녀 탭 「건강 리포트」. 차트·알림 등은 데모 데이터 기준입니다.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/features/child/dashboard/presentation/child_home_screen.dart' show ChildHealthTrendPanel;
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

class HealthMonitoringScreen extends StatelessWidget {
  const HealthMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trend = MockItdaData.weeklyMoodTrend;
    final alert = MockItdaData.voiceRiskAlert;

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ChildShellHeader(
              centerTitle: '건강 리포트',
              showChildActions: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
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
                            color: ChildDashboardColors.orange.withValues(alpha: 0.12),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (v, m) => Text(
                                v.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 10, color: ChildDashboardColors.textMuted),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              interval: 1,
                              getTitlesWidget: (v, m) {
                                const days = ['월', '화', '수', '목', '금', '토', '일'];
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
                              for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i]),
                            ],
                            isCurved: true,
                            color: ChildDashboardColors.orange,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: ChildDashboardColors.orange.withValues(alpha: 0.1),
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
                  style: TextStyle(fontSize: 11, color: ChildDashboardColors.textMuted),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '건강 퀘스트 응답'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: Column(
                    children: [
                      for (var i = 0; i < MockItdaData.questResults.length; i++) ...[
                        if (i > 0) const Divider(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    MockItdaData.questResults[i]['q']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: ChildDashboardColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '응답: ${MockItdaData.questResults[i]['a']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ChildDashboardColors.textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              MockItdaData.questResults[i]['date']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: ChildDashboardColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: 'AI 음성 분석 · 위험 알림'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ChildDashboardColors.dangerLight.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ChildDashboardColors.danger.withValues(alpha: 0.25),
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
                          Icon(Icons.health_and_safety_rounded, color: ChildDashboardColors.danger, size: 22),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ChildDashboardColors.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              alert['level']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: ChildDashboardColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        alert['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: ChildDashboardColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert['body']!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: ChildDashboardColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '데모: 음성 분석 → 요약 → 보호자 알림(파이프라인 예시)',
                        style: TextStyle(
                          fontSize: 10,
                          color: ChildDashboardColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
