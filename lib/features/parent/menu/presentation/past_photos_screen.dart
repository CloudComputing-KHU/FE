import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/features/parent/home/presentation/parent_photo_view_widgets.dart';
import 'package:itda/features/parent/home/providers/parent_home_provider.dart';
import 'package:itda/shared/widgets/round_white_icon_button.dart';

/// 새 사진 보기와 동일 레이아웃 — 날짜·같은 날 도트 · 스와이프 · 이전/다음 (반응 플로우 없음)
class PastPhotosScreen extends ConsumerWidget {
  const PastPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(pastPhotosProvider);

    return photosAsync.when(
      loading: () => Scaffold(
        backgroundColor: ItdaColors.orangePale,
        body: const Center(
          child: CircularProgressIndicator(color: ItdaColors.orange),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: ItdaColors.orangePale,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: RoundWhiteIconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.chevron_left_rounded,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('사진을 불러오지 못했어요.',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(pastPhotosProvider.notifier).refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (photos) {
        if (photos.isEmpty) {
          return Scaffold(
            backgroundColor: ItdaColors.orangePale,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: RoundWhiteIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.chevron_left_rounded,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '저장된 사진이 없어요',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        // 데이터가 있으면 실제 스크롤 화면으로 넘깁니다.
        return _PastPhotosView(photos: photos);
      },
    );
  }
}

class _PastPhotosView extends StatefulWidget {
  const _PastPhotosView({required this.photos});

  final List<ParentReceivedPhoto> photos;

  @override
  State<_PastPhotosView> createState() => _PastPhotosViewState();
}

class _PastPhotosViewState extends State<_PastPhotosView> {
  late final PageController _pageController;
  late int _pageIndex;
  late Map<String, List<int>> _indicesByDate;
  late List<ParentPendingPhoto> _photos;

  @override
  void initState() {
    super.initState();
    _photos = widget.photos
        .map(
          (p) => ParentPendingPhoto(
            id: p.photoId,
            imageUrl: p.displayUrl,
            caption: p.caption ?? '',
            arrivedAt: _arrivedAt(p.createdAt),
            dateLabel: _dateLabel(p.createdAt),
            isNew: false,
          ),
        )
        .toList();
    _pageIndex = 0;
    _pageController = PageController();
    _rebuildDateIndex();
  }

  void _rebuildDateIndex() {
    final map = <String, List<int>>{};
    for (var i = 0; i < _photos.length; i++) {
      final d = _photos[i].dateLabel;
      map.putIfAbsent(d, () => []).add(i);
    }
    _indicesByDate = map;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goPage(int i) {
    final last = _photos.length - 1;
    final next = i.clamp(0, last);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  List<int> get _sameDayIndices {
    final label = _photos[_pageIndex].dateLabel;
    return _indicesByDate[label] ?? [_pageIndex];
  }

  int get _photoIdxInDay => _sameDayIndices.indexOf(_pageIndex);

  @override
  Widget build(BuildContext context) {
    final atFirst = _pageIndex <= 0;
    final atLast = _pageIndex >= _photos.length - 1;
    final dots = _sameDayIndices.length;
    final activeDot = _photoIdxInDay.clamp(0, dots > 0 ? dots - 1 : 0);

    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: Column(
          children: [
            ParentPhotoViewHeader(
              dateText: _photos[_pageIndex].dateLabel,
              dotCount: dots,
              activeDotIndex: activeDot,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _pageIndex = i),
                        itemCount: _photos.length,
                        itemBuilder: (context, i) {
                          return ParentPhotoHtmlCard(photo: _photos[i]);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: ParentPhotoNavButton(
                            label: '이전',
                            icon: Icons.chevron_left_rounded,
                            iconAfter: false,
                            onPressed: atFirst ? null : () => _goPage(_pageIndex - 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ParentPhotoNavButton(
                            label: '다음',
                            icon: Icons.chevron_right_rounded,
                            iconAfter: true,
                            onPressed: atLast ? null : () => _goPage(_pageIndex + 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 날짜 헬퍼 ────────────────────────────────────────────────────────────────

String _arrivedAt(DateTime dt) {
  return '${dt.month}월 ${dt.day}일';
}

String _dateLabel(DateTime dt) {
  return '${dt.month}월 ${dt.day}일';
}
