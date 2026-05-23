/// 자녀 탭 「홈」: 상단 히어로 인사 카드·요약 카드·오늘의 퀘스트 응답은
/// 모크/프로바이더 데이터를 사용하고, [ChildHealthTrendPanel]은 건강 탭에서 재사용합니다.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/features/child/dashboard/providers/dashboard_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';

class ChildHomeScreen extends ConsumerWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayQuestsAsync = ref.watch(todayQuestsProvider);
    final answeredCount = ref.watch(answeredCountTodayProvider);
    final riskCount = ref.watch(riskAlertCountProvider);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final streakTile = MockItdaData.dashboardSummaryTiles[3];
    final streakText = '${streakTile.value}${streakTile.unit}';
    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);

    return ColoredBox(
      color: const Color(0xFFFFF9F0),
      child: CustomScrollView(
        slivers: [
          ChildHomeSliverHeader(
            onNotificationTap: () => context.push(AppRoutes.childNotifications),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GreetingCard(
                  childName:
                      profile?.displayName ?? MockItdaData.childDisplayName,
                  answeredCount: answeredCount,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ChildHomeStatCard(
                        icon: Icons.check_outlined,
                        valueText: '$answeredCount/3',
                        label: '퀘스트',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChildHomeStatCard(
                        icon: Icons.warning_amber_outlined,
                        valueText: '$riskCount건',
                        label: '위험 알림',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChildHomeStatCard(
                        icon: Icons.local_fire_department_outlined,
                        valueText: streakText,
                        label: '연속 기록',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
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
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.childName, required this.answeredCount});

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
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
      return '어머니께서 오늘 건강 퀘스트를\n모두 완료하셨어요. 안부 사진을내보세요!';
    }
    if (answered > 0) {
      return '어머니께서 오늘 $answered개의 퀘스트에 응답하셨어요.\n남은 응답이 도착하면 알려드릴게요.';
    }
    return '오늘은 아직 응답이 없어요.\n부모님께 안부 사진을보내볼까요?';
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
            style: TextStyle(
              fontSize: 10,
              color: ChildDashboardColors.textMuted,
            ),
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
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 10,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
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
                      for (var i = 0; i < scores.length; i++)
                        FlSpot(i.toDouble(), scores[i]),
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

/// 「오늘의 퀘스트 응답」 — `todayQuestsProvider`의 BE 데이터로 구성.
class _TodayQuestPanel extends StatelessWidget {
  const _TodayQuestPanel({required this.asyncQuests});

  final AsyncValue<List<TodayQuestStatus>> asyncQuests;

  static const _dividerColor = Color(0xFFECE8E4);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: asyncQuests.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                color: ChildDashboardColors.orange,
              ),
            ),
          ),
        ),
        error: (e, _) => const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Text(
            '응답 정보를 불러오지 못했어요.',
            style: TextStyle(fontSize: 12, color: ChildDashboardColors.textSub),
          ),
        ),
        data: (quests) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < quests.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, thickness: 1, color: _dividerColor),
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

  static const _sienna = Color(0xFFA0522D);
  static const _pendingBg = Color(0xFFFFF0E6);
  static const _respondedBg = Color(0xFFE8F3EA);
  static const _respondedText = Color(0xFF2E6B3A);

  final TodayQuestStatus quest;

  @override
  Widget build(BuildContext context) {
    final preview = quest.answerPreview;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quest.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ChildDashboardColors.text,
                    height: 1.25,
                  ),
                ),
                if (preview != null &&
                    preview.isNotEmpty &&
                    quest.responded) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ChildDashboardColors.textSub,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: quest.responded ? _respondedBg : _pendingBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                quest.responded ? '응답' : '미응답',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: quest.responded ? _respondedText : _sienna,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
