import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/models/photo.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/child/photo_upload/providers/upload_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';
import 'package:itda/features/shared/providers/family_provider.dart';
import 'package:itda/features/shared/providers/photo_reaction_provider.dart';

/// 소통 탭. 자녀가 보낸 사진은 BE의 `GET /photos/history`로 가져오고,
/// 부모의 반응은 `GET /photos/{photo_id}/reactions`로 사진별 조회합니다.
class ChildChatScreen extends ConsumerWidget {
  const ChildChatScreen({super.key});

  static const BorderRadius _radiusMeBubble = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(4),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );

  static const BorderRadius _radiusMomBubble = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyMeProvider).valueOrNull;
    final parentName = _nonEmptyName(family?.activeLink?.parentName) ?? '부모님';
    final sentAsync = ref.watch(sentPhotosProvider);
    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const ChildTabSliverHeader(title: '소통'),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: sentAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ChildDashboardColors.orange,
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '소통 기록을 불러오지 못했어요.',
                          style: TextStyle(
                            fontSize: 13,
                            color: ChildDashboardColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () =>
                              ref.read(sentPhotosProvider.notifier).refresh(),
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (photos) {
                if (photos.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          '아직 보낸 사진이 없어요.\n부모님께 첫 사진을 보내볼까요?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: ChildDashboardColors.textSub,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final reactionsByPhotoId = {
                  for (final photo in photos)
                    photo.id:
                        ref
                            .watch(photoReactionsProvider(photo.id))
                            .valueOrNull ??
                        const <PhotoReaction>[],
                };
                final entries = _buildEntriesFromPhotos(
                  photos,
                  reactionsByPhotoId,
                );
                return SliverList(
                  delegate: SliverChildListDelegate(
                    _buildTimelineList(
                      parentName: parentName,
                      entries: entries,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String? _nonEmptyName(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

List<ChildCommEntry> _buildEntriesFromPhotos(
  List<Photo> photos,
  Map<String, List<PhotoReaction>> reactionsByPhotoId,
) {
  final out = <ChildCommEntry>[];
  String? currentDateKey;
  final sortedPhotos = List<Photo>.of(photos)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  for (final p in sortedPhotos) {
    final dateKey =
        '${p.createdAt.year}-${p.createdAt.month}-${p.createdAt.day}';
    if (dateKey != currentDateKey) {
      out.add(ChildCommDateDivider(_dateLabel(p.createdAt)));
      currentDateKey = dateKey;
    }
    out.add(
      ChildCommSentPhoto(
        imageUrls: [p.displayUrl],
        caption: p.caption ?? '',
        time: _timeLabel(p.createdAt),
      ),
    );
    for (final reaction
        in reactionsByPhotoId[p.id] ?? const <PhotoReaction>[]) {
      if (reaction.isVoice) {
        out.add(
          ChildCommParentVoiceNote(
            time: _timeLabel(reaction.createdAt),
            durationLabel: reaction.durationLabel,
            voiceUrl: reaction.displayVoiceUrl,
          ),
        );
      } else {
        out.add(
          ChildCommParentQuickReaction(
            label: reaction.displayLabel,
            time: _timeLabel(reaction.createdAt),
          ),
        );
      }
    }
  }
  return out;
}

String _dateLabel(DateTime dt) {
  return '${dt.year}년 ${dt.month}월 ${dt.day}일';
}

String _timeLabel(DateTime dt) {
  final h = dt.hour;
  final m = dt.minute.toString().padLeft(2, '0');
  if (h == 0) return '오전 12:$m';
  if (h < 12) return '오전 $h:$m';
  if (h == 12) return '오후 12:$m';
  return '오후 ${h - 12}:$m';
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
    } else if (e is ChildCommParentQuickReaction ||
        e is ChildCommParentVoiceNote) {
      final group = <ChildCommEntry>[];
      while (i < entries.length &&
          (entries[i] is ChildCommParentQuickReaction ||
              entries[i] is ChildCommParentVoiceNote)) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
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
    final s = (innerWidth - gap) / 2;
    final more = n - 4;
    return SizedBox(
      width: innerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _CommPhotoTile(
                url: urls[0],
                width: s,
                height: s,
                radius: 8,
                lightBackground: false,
              ),
              SizedBox(width: gap),
              _CommPhotoTile(
                url: urls[1],
                width: s,
                height: s,
                radius: 8,
                lightBackground: false,
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              _CommPhotoTile(
                url: urls[2],
                width: s,
                height: s,
                radius: 8,
                lightBackground: false,
              ),
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
                  : _CommPhotoTile(
                      url: urls[3],
                      width: s,
                      height: s,
                      radius: 8,
                      lightBackground: false,
                    ),
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
  const _MomPendingRow({required this.parentName, required this.time});

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
  const _MomReactionCardRow({required this.parentName, required this.entries});

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
        w.add(
          _VoiceMessageStrip(
            durationLabel: e.durationLabel,
            voiceUrl: e.voiceUrl,
          ),
        );
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

class _VoiceMessageStrip extends StatefulWidget {
  const _VoiceMessageStrip({required this.durationLabel, this.voiceUrl});

  final String durationLabel;
  final String? voiceUrl;

  static const List<double> _bars = [8, 14, 10, 18, 12, 20, 9, 16, 11, 14];

  @override
  State<_VoiceMessageStrip> createState() => _VoiceMessageStripState();
}

class _VoiceMessageStripState extends State<_VoiceMessageStrip> {
  late final AudioPlayer _player;
  bool _playing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_busy) return;
    final url = widget.voiceUrl?.trim();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('음성 파일을 불러올 수 없어요.')));
      return;
    }

    setState(() => _busy = true);
    if (_playing) {
      try {
        await _player.stop();
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      return;
    }

    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('음성 재생에 실패했어요: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
          Material(
            color: ItdaColors.orange,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _toggle,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 28,
                height: 28,
                child: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _playing
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < _VoiceMessageStrip._bars.length; i++) ...[
                  Container(
                    width: 3,
                    height: _VoiceMessageStrip._bars[i],
                    decoration: BoxDecoration(
                      color: ItdaColors.orange.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (i < _VoiceMessageStrip._bars.length - 1)
                    const SizedBox(width: 2),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.durationLabel,
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
