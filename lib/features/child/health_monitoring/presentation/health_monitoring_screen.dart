/// 자녀 탭 「건강」. AI 음성 분석 결과를 요약하고 최근 이력을 표시합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/child/health_monitoring/providers/health_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';

class HealthMonitoringScreen extends ConsumerWidget {
  const HealthMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysesAsync = ref.watch(parentDementiaHistoryProvider);
    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const ChildTabSliverHeader(title: '건강'),
          CupertinoSliverRefreshControlCompat(
            onRefresh: () =>
                ref.read(parentDementiaHistoryProvider.notifier).refresh(),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionTitle(title: '최신 AI 음성 분석'),
                const SizedBox(height: 10),
                analysesAsync.when(
                  loading: () => const _LoadingCard(),
                  error: (error, _) => _ErrorCard(
                    onRetry: () => ref
                        .read(parentDementiaHistoryProvider.notifier)
                        .refresh(),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return const _EmptyAnalysisSection();
                    }
                    final latest = items.first;
                    return _LatestAnalysisSection(
                      item: latest,
                      detailAsync: ref.watch(
                        dementiaAnalysisDetailProvider(latest.analysisId),
                      ),
                      history: items,
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class CupertinoSliverRefreshControlCompat extends StatelessWidget {
  const CupertinoSliverRefreshControlCompat({
    super.key,
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    // Material only project: keep pull-to-refresh spacing stable without
    // bringing an additional Cupertino import into the tab.
    return SliverToBoxAdapter(
      child: RefreshIndicator(
        color: ChildDashboardColors.orange,
        onRefresh: onRefresh,
        child: const SizedBox(width: double.infinity, height: 1),
      ),
    );
  }
}

class _LatestAnalysisSection extends StatelessWidget {
  const _LatestAnalysisSection({
    required this.item,
    required this.detailAsync,
    required this.history,
  });

  final DementiaAnalysisItem item;
  final AsyncValue<DementiaAnalysisResult> detailAsync;
  final List<DementiaAnalysisItem> history;

  @override
  Widget build(BuildContext context) {
    final detail = detailAsync.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroAnalysisCard(item: item),
        const SizedBox(height: 14),
        _AnalysisDetailCard(item: item, detail: detail),
        const SizedBox(height: 22),
        _RecentHistorySection(items: history.take(5).toList()),
      ],
    );
  }
}

class _HeroAnalysisCard extends StatelessWidget {
  const _HeroAnalysisCard({required this.item});

  final DementiaAnalysisItem item;

  @override
  Widget build(BuildContext context) {
    final risk = _RiskPresentation.from(item.riskLevel);
    final score = _scoreOutOf100(item.riskScore);
    final doneAt = item.completedAt ?? item.createdAt;

    return _Card(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _RiskFace(risk: risk, size: 80),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '위험도 ${risk.label}',
                            style: TextStyle(
                              fontSize: 19,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              color: risk.color,
                            ),
                          ),
                        ),
                        _StatusChip(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '위험 점수',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ChildDashboardColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: score?.toString() ?? '-',
                            style: TextStyle(
                              fontSize: 32,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: risk.color,
                            ),
                          ),
                          const TextSpan(
                            text: ' / 100',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ChildDashboardColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '분석 완료 시간',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ChildDashboardColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFullDate(doneAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ChildDashboardColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chevron_right_rounded, size: 18),
              label: const Text('상세 보기'),
              iconAlignment: IconAlignment.end,
              style: OutlinedButton.styleFrom(
                foregroundColor: risk.color,
                side: BorderSide(color: risk.color),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAnalysisSection extends StatelessWidget {
  const _EmptyAnalysisSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EmptyAnalysisCard(),
        SizedBox(height: 14),
        _EmptyDetailCard(),
        SizedBox(height: 22),
        _RecentHistorySection(items: []),
      ],
    );
  }
}

class _EmptyDetailCard extends StatelessWidget {
  const _EmptyDetailCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석 요약',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: ChildDashboardColors.text,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '분석 완료된 음성 답변이 생기면 요약과 관찰 지표가 표시됩니다.',
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: ChildDashboardColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHistorySection extends StatelessWidget {
  const _RecentHistorySection({required this.items});

  final List<DementiaAnalysisItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const _SectionTitle(title: '최근 분석 기록'),
            const Spacer(),
            TextButton(
              onPressed: items.isEmpty ? null : () {},
              style: TextButton.styleFrom(
                foregroundColor: ChildDashboardColors.textMuted,
                disabledForegroundColor: ChildDashboardColors.textMuted
                    .withValues(alpha: 0.45),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '전체 보기',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const _EmptyHistoryList()
        else
          _HistoryList(items: items),
      ],
    );
  }
}

class _EmptyHistoryList extends StatelessWidget {
  const _EmptyHistoryList();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      padding: EdgeInsets.all(16),
      child: Text(
        '최근 분석 기록이 아직 없어요.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: ChildDashboardColors.textSub,
        ),
      ),
    );
  }
}

class _AnalysisDetailCard extends StatelessWidget {
  const _AnalysisDetailCard({required this.item, required this.detail});

  final DementiaAnalysisItem item;
  final DementiaAnalysisResult? detail;

  @override
  Widget build(BuildContext context) {
    final summary = detail?.analysisSummary ?? _fallbackSummary(item);
    final indicators = detail?.indicators ?? _fallbackIndicators(item);
    final transcript = detail?.transcript;

    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분석 요약',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: ChildDashboardColors.border),
          const SizedBox(height: 16),
          const Text(
            '관찰된 지표',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 10),
          for (final indicator in indicators) ...[
            _IndicatorRow(label: indicator),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          const Divider(height: 1, color: ChildDashboardColors.border),
          const SizedBox(height: 14),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: true,
              title: const Text(
                '분석 기준 음성 (transcript)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: ChildDashboardColors.text,
                ),
              ),
              children: [
                _TranscriptBox(
                  text: transcript ?? '분석 기준 음성 내용이 아직 준비되지 않았어요.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<DementiaAnalysisItem> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF0E2C8)),
            _HistoryRow(item: items[i], leading: i == 0),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.leading});

  final DementiaAnalysisItem item;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final risk = _RiskPresentation.from(item.riskLevel);
    final score = _scoreOutOf100(item.riskScore);

    return Container(
      decoration: BoxDecoration(
        border: leading
            ? Border(left: BorderSide(color: risk.color, width: 3))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              _formatFullDate(item.completedAt ?? item.createdAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ChildDashboardColors.text,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusChip(status: item.status, compact: true),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.status == DementiaAnalysisStatus.completed
                  ? risk.label
                  : '-',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: item.status == DementiaAnalysisStatus.completed
                    ? risk.color
                    : ChildDashboardColors.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              score == null ? '-' : '$score점',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: ChildDashboardColors.text,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: ChildDashboardColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _RiskFace extends StatelessWidget {
  const _RiskFace({required this.risk, required this.size});

  final _RiskPresentation risk;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: risk.color,
        boxShadow: [
          BoxShadow(
            color: risk.color.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(risk.icon, color: Colors.white, size: size * 0.58),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: _RiskPresentation.green,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: ChildDashboardColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _TranscriptBox extends StatelessWidget {
  const _TranscriptBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _RiskPresentation.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _RiskPresentation.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volume_up_rounded,
              color: _RiskPresentation.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"$text"',
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: ChildDashboardColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.compact = false});

  final DementiaAnalysisStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _StatusPresentation.from(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        style.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w900,
          color: style.color,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ChildDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: ChildDashboardColors.text,
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      padding: EdgeInsets.all(24),
      child: SizedBox(
        height: 88,
        child: Center(
          child: CircularProgressIndicator(color: ChildDashboardColors.orange),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Text(
            '분석 결과를 불러오지 못했어요.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: ChildDashboardColors.text,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: ChildDashboardColors.orange,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _EmptyAnalysisCard extends StatelessWidget {
  const _EmptyAnalysisCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      padding: EdgeInsets.all(18),
      child: Text(
        '아직 분석된 음성 답변이 없어요.\n부모님의 음성 답변이 도착하면 위험도와 분석 요약을 보여드릴게요.',
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w700,
          color: ChildDashboardColors.textSub,
        ),
      ),
    );
  }
}

class _RiskPresentation {
  const _RiskPresentation({
    required this.label,
    required this.color,
    required this.icon,
  });

  static const green = Color(0xFF34A853);
  static const orange = Color(0xFFFF8A1F);
  static const red = Color(0xFFEA4335);

  final String label;
  final Color color;
  final IconData icon;

  static _RiskPresentation from(RiskLevel? level) {
    switch (level) {
      case RiskLevel.medium:
        return const _RiskPresentation(
          label: '보통',
          color: orange,
          icon: Icons.sentiment_neutral_rounded,
        );
      case RiskLevel.high:
        return const _RiskPresentation(
          label: '높음',
          color: red,
          icon: Icons.sentiment_dissatisfied_rounded,
        );
      case RiskLevel.low:
      case RiskLevel.unknown:
      case null:
        return const _RiskPresentation(
          label: '낮음',
          color: green,
          icon: Icons.sentiment_satisfied_rounded,
        );
    }
  }
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.description,
    required this.color,
  });

  final String label;
  final String description;
  final Color color;

  static _StatusPresentation from(DementiaAnalysisStatus status) {
    switch (status) {
      case DementiaAnalysisStatus.completed:
        return const _StatusPresentation(
          label: '완료',
          description: '분석 완료',
          color: _RiskPresentation.green,
        );
      case DementiaAnalysisStatus.pending:
      case DementiaAnalysisStatus.transcribing:
      case DementiaAnalysisStatus.transcribed:
      case DementiaAnalysisStatus.analyzing:
        return const _StatusPresentation(
          label: '분석 중',
          description: '분석이 진행 중입니다',
          color: Color(0xFF4A90E2),
        );
      case DementiaAnalysisStatus.failed:
      case DementiaAnalysisStatus.unknown:
        return const _StatusPresentation(
          label: '실패',
          description: '분석 실패',
          color: Color(0xFF9E9E9E),
        );
    }
  }
}

int? _scoreOutOf100(double? raw) {
  if (raw == null) return null;
  final normalized = raw <= 1 ? raw * 100 : raw;
  return normalized.round().clamp(0, 100);
}

String _formatFullDate(DateTime date) {
  final local = date.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}.${two(local.month)}.${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _fallbackSummary(DementiaAnalysisItem item) {
  if (item.status.isInProgress) {
    return '현재 음성 답변을 분석하고 있어요.\n분석이 완료되면 위험도와 요약을 표시합니다.';
  }
  if (item.status.isFailed) {
    return '음성 답변 분석에 실패했어요.\n다음 음성 답변이 도착하면 다시 분석을 요청합니다.';
  }
  final risk = _RiskPresentation.from(item.riskLevel);
  return '최근 음성 답변에서는 위험도 ${risk.label} 수준으로 확인됐습니다.\n응답 흐름과 발화 내용은 전반적으로 안정적인 편입니다.';
}

List<String> _fallbackIndicators(DementiaAnalysisItem item) {
  if (item.status.isInProgress) {
    return const ['분석 진행 중', '음성 답변 처리 중', '결과 대기'];
  }
  if (item.status.isFailed) {
    return const ['분석 실패', '재시도 필요', '결과 없음'];
  }
  switch (item.riskLevel) {
    case RiskLevel.medium:
      return const ['일부 응답 지연', '발화 흐름 관찰 필요', '반복 표현 보통'];
    case RiskLevel.high:
      return const ['응답 지연 감지', '발화 흐름 불안정', '반복 표현 증가'];
    case RiskLevel.low:
    case RiskLevel.unknown:
    case null:
      return const ['응답 지연 없음', '발화 흐름 안정', '반복 표현 적음'];
  }
}
