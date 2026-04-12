import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

/// 소통 탭. 상단 [ChildShellHeader], 타임라인은 날짜·사진·부모 반응 타일.
class ChildChatScreen extends StatelessWidget {
  const ChildChatScreen({super.key});

  static const BorderRadius _radiusMeBubble = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(4),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );

  /// 상대(어머니) 말풍선 — 내 말풍선과 대칭(왼쪽 위만 작게)
  static const BorderRadius _radiusMomBubble = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );

  @override
  Widget build(BuildContext context) {
    final parentName = MockItdaData.parentDisplayName;
    final entries = MockItdaData.childCommTimeline;

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ChildShellHeader(
              centerTitle: '소통',
              showChildActions: false,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildTimelineList(
                  parentName: parentName,
                  entries: entries,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<Widget> _buildTimelineList({
  required String parentName,
  required List<ChildCommEntry> entries,
}) {
  final out = <Widget>[];
  var i = 0;
  while (i < entries.length) {
    final e = entries[i];
    if (e is ChildCommDateDivider) {
      out.add(_DateDividerHtml(label: e.label));
      out.add(const SizedBox(height: 18));
      i++;
    } else if (e is ChildCommSentPhoto) {
      out.add(
        _MePhotoCaptionBlock(
          imageUrls: e.imageUrls,
          caption: e.caption,
          time: e.time,
        ),
      );
      out.add(const SizedBox(height: 18));
      i++;
    } else if (e is ChildCommParentPending) {
      out.add(_MomPendingRow(parentName: parentName, time: e.time));
      out.add(const SizedBox(height: 18));
      i++;
    } else if (e is ChildCommParentQuickReaction || e is ChildCommParentVoiceNote) {
      final group = <ChildCommEntry>[];
      while (i < entries.length &&
          (entries[i] is ChildCommParentQuickReaction || entries[i] is ChildCommParentVoiceNote)) {
        group.add(entries[i]);
        i++;
      }
      out.add(_MomReactionCardRow(parentName: parentName, entries: group));
      out.add(const SizedBox(height: 18));
    } else {
      i++;
    }
  }
  return out;
}

class _DateDividerHtml extends StatelessWidget {
  const _DateDividerHtml({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ItdaColors.textMuted,
        ),
      ),
    );
  }
}

/// 자녀가 보낸 사진 행: 사진 줄·캡션 줄, 각각 시간과 말풍선.
class _MePhotoCaptionBlock extends StatelessWidget {
  const _MePhotoCaptionBlock({
    required this.imageUrls,
    required this.caption,
    required this.time,
  });

  final List<String> imageUrls;
  final String caption;
  final String time;

  static const double _photoMaxW = 210;
  static const double _photoPad = 7;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final innerW = _photoMaxW - _photoPad * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: ItdaColors.textMuted,
                height: 1.2,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              constraints: const BoxConstraints(maxWidth: _photoMaxW),
              padding: const EdgeInsets.all(_photoPad),
              decoration: const BoxDecoration(
                color: ItdaColors.orange,
                borderRadius: ChildChatScreen._radiusMeBubble,
              ),
              child: _PhotoGridHtml(
                urls: imageUrls,
                innerWidth: innerW,
                gap: _gap,
              ),
            ),
          ],
        ),
        if (caption.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 10,
                  color: ItdaColors.textMuted,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: _photoMaxW),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: const BoxDecoration(
                    color: ItdaColors.orange,
                    borderRadius: ChildChatScreen._radiusMeBubble,
                  ),
                  child: Text(
                    caption,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PhotoGridHtml extends StatelessWidget {
  const _PhotoGridHtml({
    required this.urls,
    required this.innerWidth,
    required this.gap,
  });

  final List<String> urls;
  final double innerWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final n = urls.length;
    if (n == 1) {
      final h = (innerWidth * 9 / 16).clamp(72.0, 120.0);
      return _CommPhotoTile(
        url: urls[0],
        width: innerWidth,
        height: h,
        radius: 8,
        lightBackground: false,
      );
    }
    if (n == 2) {
      return SizedBox(
        width: innerWidth,
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final s = c.maxWidth;
                  return _CommPhotoTile(
                    url: urls[0],
                    width: s,
                    height: s,
                    radius: 8,
                    lightBackground: false,
                  );
                },
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final s = c.maxWidth;
                  return _CommPhotoTile(
                    url: urls[1],
                    width: s,
                    height: s,
                    radius: 8,
                    lightBackground: false,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    if (n == 3) {
      return SizedBox(
        width: innerWidth,
        child: Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final s = c.maxWidth;
                  return _CommPhotoTile(
                    url: urls[0],
                    width: s,
                    height: s,
                    radius: 8,
                    lightBackground: false,
                  );
                },
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final s = c.maxWidth;
                  return _CommPhotoTile(
                    url: urls[1],
                    width: s,
                    height: s,
                    radius: 8,
                    lightBackground: false,
                  );
                },
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final s = c.maxWidth;
                  return _CommPhotoTile(
                    url: urls[2],
                    width: s,
                    height: s,
                    radius: 8,
                    lightBackground: false,
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
    // 이전 .clamp(48, 72)는 타일을 작게만 두어 버블 오른쪽이 비어 보였음 → 가용 너비의 절반을 씀.
    final s = (innerWidth - gap) / 2;
    final more = n - 4;
    return SizedBox(
      width: innerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _CommPhotoTile(url: urls[0], width: s, height: s, radius: 8, lightBackground: false),
              SizedBox(width: gap),
              _CommPhotoTile(url: urls[1], width: s, height: s, radius: 8, lightBackground: false),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              _CommPhotoTile(url: urls[2], width: s, height: s, radius: 8, lightBackground: false),
              SizedBox(width: gap),
              more > 0
                  ? _CommPhotoTile(
                      url: urls[3],
                      width: s,
                      height: s,
                      radius: 8,
                      overlayText: '+$more',
                      lightBackground: false,
                    )
                  : _CommPhotoTile(url: urls[3], width: s, height: s, radius: 8, lightBackground: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommPhotoTile extends StatelessWidget {
  const _CommPhotoTile({
    required this.url,
    required this.width,
    required this.height,
    required this.radius,
    this.overlayText,
    this.lightBackground = false,
  });

  final String url;
  final double width;
  final double height;
  final double radius;
  final String? overlayText;
  final bool lightBackground;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return ColoredBox(
                  color: lightBackground
                      ? ItdaColors.orange.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.35),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ItdaColors.orange.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => ColoredBox(
                color: ItdaColors.orangePale,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: ItdaColors.textMuted,
                  size: width > 60 ? 28 : 22,
                ),
              ),
            ),
            if (overlayText != null)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: Text(
                    overlayText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MomPendingRow extends StatelessWidget {
  const _MomPendingRow({
    required this.parentName,
    required this.time,
  });

  final String parentName;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MomNameLabel(name: parentName),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '아직 반응을 남기지 않았어요',
                      style: TextStyle(
                        fontSize: 12,
                        color: ItdaColors.textMuted,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                color: ItdaColors.textMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MomReactionCardRow extends StatelessWidget {
  const _MomReactionCardRow({
    required this.parentName,
    required this.entries,
  });

  final String parentName;
  final List<ChildCommEntry> entries;

  String get _lastTime {
    final last = entries.last;
    return switch (last) {
      ChildCommParentQuickReaction(:final time) => time,
      ChildCommParentVoiceNote(:final time) => time,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MomNameLabel(name: parentName),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _cardChildren(),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              _lastTime,
              style: const TextStyle(
                fontSize: 10,
                color: ItdaColors.textMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _cardChildren() {
    final w = <Widget>[];
    for (var j = 0; j < entries.length; j++) {
      if (j > 0) w.add(const SizedBox(height: 8));
      final e = entries[j];
      if (e is ChildCommParentQuickReaction) {
        w.add(_ReactBadge(label: e.label));
      } else if (e is ChildCommParentVoiceNote) {
        w.add(_VoiceMessageStrip(durationLabel: e.durationLabel));
      }
    }
    return w;
  }
}

class _MomNameLabel extends StatelessWidget {
  const _MomNameLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ItdaColors.textSub,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ReactBadge extends StatelessWidget {
  const _ReactBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final preset = MockItdaData.reactionPresetForLabel(label);
    final emoji = preset?.emoji ?? '💬';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ChildChatScreen._radiusMomBubble,
        boxShadow: [
          BoxShadow(
            color: ItdaColors.orange.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20, height: 1)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: ItdaColors.text,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceMessageStrip extends StatelessWidget {
  const _VoiceMessageStrip({required this.durationLabel});

  final String durationLabel;

  static const List<double> _bars = [8, 14, 10, 18, 12, 20, 9, 16, 11, 14];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ChildChatScreen._radiusMomBubble,
        boxShadow: [
          BoxShadow(
            color: ItdaColors.orange.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: ItdaColors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < _bars.length; i++) ...[
                  Container(
                    width: 3,
                    height: _bars[i],
                    decoration: BoxDecoration(
                      color: ItdaColors.orange.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (i < _bars.length - 1) const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            durationLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ItdaColors.textSub,
            ),
          ),
        ],
      ),
    );
  }
}
