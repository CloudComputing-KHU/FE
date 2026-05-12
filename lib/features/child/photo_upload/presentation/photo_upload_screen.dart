/// 자녀 사진 촬영·예약 전송·업로드 플로우.
library;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:itda/features/child/photo_upload/providers/upload_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';
import 'package:itda/shared/widgets/xfile_preview.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();

  XFile? _image;
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> _ensureGalleryPermission() async {
    if (kIsWeb) return true;
    if (!_isAndroid) return true;

    var status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;

    status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;

    // Android 12 이하 등
    final legacy = await Permission.storage.request();
    return legacy.isGranted;
  }

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.gallery && !kIsWeb && _isAndroid) {
      final ok = await _ensureGalleryPermission();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사진을 고르려면 설정에서 사진·저장소 권한을 허용해 주세요.'),
            ),
          );
        }
        return;
      }
    }

    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 4096,
        maxHeight: 4096,
      );
      if (!mounted) return;
      if (x != null) {
        setState(() => _image = x);
      }
    } catch (e, _) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '사진 선택을 열 수 없어요. 앱을 다시 실행하거나 권한을 확인해 주세요.'
              '${kDebugMode ? '\n($e)' : ''}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickSchedule() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: ChildDashboardColors.orangePale,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SimpleScheduleSheet(
        now: DateTime.now(),
        initial: _scheduledAt,
        onPick: (picked) {
          Navigator.pop(ctx);
          setState(() => _scheduledAt = picked);
        },
      ),
    );
  }

  Future<void> _uploadPhoto() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 먼저 선택해 주세요.')),
      );
      return;
    }

    final caption = _captionCtrl.text.trim().isEmpty
        ? null
        : _captionCtrl.text.trim();

    final result = await uploadChildPhoto(
      ref: ref,
      filePath: _image!.path,
      caption: caption,
      scheduledAt: _scheduledAt,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor:
            result.ok ? null : ChildDashboardColors.dangerLight,
      ),
    );

    if (result.ok) {
      // 성공 시 입력 초기화 — 같은 사진 중복 전송 방지
      setState(() {
        _image = null;
        _scheduledAt = null;
        _captionCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sending = ref.watch(uploadBusyProvider);
    final scheduleText = _scheduledAt == null
        ? '즉시 전송 (예약 없음)'
        : DateFormat('M월 d일 HH:mm 예약').format(_scheduledAt!);
    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const ChildTabSliverHeader(title: '사진 보내기'),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const ChildSectionHeader(title: '사진 선택 · 미리보기'),
                const SizedBox(height: 10),
                AspectRatio(
                  aspectRatio: 2.1,
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: _image == null
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _pick(ImageSource.gallery),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: ChildDashboardColors.orangeLight,
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: 44,
                                      color: ChildDashboardColors.orangeDark,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      '탭해서 사진 선택',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ChildDashboardColors.textSub,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => _pick(ImageSource.gallery),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                xFilePreview(_image!, fit: BoxFit.cover),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.55),
                                          ],
                                        ),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.fromLTRB(12, 28, 12, 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.photo_library_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              '탭하여 사진 바꾸기',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 4,
                                                    color: Colors.black45,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '캡션'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: TextField(
                    controller: _captionCtrl,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ChildDashboardColors.text,
                      height: 1.25,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '부모님께 전할 메시지를 적어 주세요',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ChildDashboardColors.textMuted.withValues(alpha: 0.95),
                      ),
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '예약 전송'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              scheduleText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ChildDashboardColors.text,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _pickSchedule,
                            style: TextButton.styleFrom(
                              foregroundColor: ChildDashboardColors.orange,
                            ),
                            child: const Text(
                              '바꾸기',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      if (_scheduledAt != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _scheduledAt = null),
                            style: TextButton.styleFrom(
                              foregroundColor: ChildDashboardColors.textSub,
                            ),
                            child: const Text('예약 취소 (즉시 전송)'),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ChildPrimaryFilledButton(
                  label: '사진 전송하기',
                  loadingLabel: '전송 중…',
                  isLoading: sending,
                  onPressed: _uploadPhoto,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  labelFontWeight: FontWeight.w800,
                  boxShadow: [
                    BoxShadow(
                      color: ChildDashboardColors.orange.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleScheduleSheet extends StatefulWidget {
  const _SimpleScheduleSheet({
    required this.now,
    this.initial,
    required this.onPick,
  });

  final DateTime now;
  final DateTime? initial;
  final void Function(DateTime? scheduled) onPick;

  @override
  State<_SimpleScheduleSheet> createState() => _SimpleScheduleSheetState();
}

enum _ScheduleQuickPick { immediate, evening, morning, custom }

class _SimpleScheduleSheetState extends State<_SimpleScheduleSheet> {
  static const _minuteSteps = [0, 15, 30, 45];

  late int _dayOffset;
  late int _hour;
  late int _minute;
  late _ScheduleQuickPick _quick;

  DateTime get _today => DateTime(widget.now.year, widget.now.month, widget.now.day);

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final seed = initial ?? widget.now.add(const Duration(hours: 1));
    _seedDropdownsFrom(seed);

    if (initial == null) {
      _quick = _ScheduleQuickPick.immediate;
    } else if (_matchesEveningPreset(initial)) {
      _quick = _ScheduleQuickPick.evening;
    } else if (_matchesMorningPreset(initial)) {
      _quick = _ScheduleQuickPick.morning;
    } else {
      _quick = _ScheduleQuickPick.custom;
    }
  }

  void _seedDropdownsFrom(DateTime seed) {
    final seedDay = DateTime(seed.year, seed.month, seed.day);
    _dayOffset = seedDay.difference(_today).inDays.clamp(0, 14);
    _hour = seed.hour;
    _minute = _minuteSteps.reduce(
      (a, b) => (seed.minute - a).abs() <= (seed.minute - b).abs() ? a : b,
    );
  }

  bool _matchesEveningPreset(DateTime d) {
    final target = _nextWallClock(18, 0);
    return d.year == target.year &&
        d.month == target.month &&
        d.day == target.day &&
        d.hour == 18 &&
        d.minute == 0;
  }

  bool _matchesMorningPreset(DateTime d) {
    final t = _today.add(const Duration(days: 1));
    final m = DateTime(t.year, t.month, t.day, 9, 0);
    return d.year == m.year &&
        d.month == m.month &&
        d.day == m.day &&
        d.hour == 9 &&
        d.minute == 0;
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: ChildDashboardColors.orangePale,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2DCB0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF2DCB0)),
      ),
    );
  }

  String _dayLabel(int i) {
    if (i == 0) return '오늘';
    if (i == 1) return '내일';
    final d = _today.add(Duration(days: i));
    return DateFormat('M/d').format(d);
  }

  DateTime _combine() {
    final day = _today.add(Duration(days: _dayOffset));
    return DateTime(day.year, day.month, day.day, _hour, _minute);
  }

  /// 오늘 h:m — 이미 지났으면 내일 같은 시각
  DateTime _nextWallClock(int h, int m) {
    var t = DateTime(widget.now.year, widget.now.month, widget.now.day, h, m);
    if (!t.isAfter(widget.now)) {
      t = t.add(const Duration(days: 1));
    }
    return t;
  }

  void _setQuick(_ScheduleQuickPick q) {
    setState(() {
      _quick = q;
      if (q == _ScheduleQuickPick.evening) {
        final t = _nextWallClock(18, 0);
        _seedDropdownsFrom(t);
      } else if (q == _ScheduleQuickPick.morning) {
        final t = _today.add(const Duration(days: 1));
        _seedDropdownsFrom(DateTime(t.year, t.month, t.day, 9, 0));
      } else if (q == _ScheduleQuickPick.immediate) {
        _seedDropdownsFrom(widget.now);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '언제 보낼까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ChildDashboardColors.text,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChildScheduleQuickPickCard(
                  icon: Icons.send_rounded,
                  title: '즉시 전송',
                  subtitle: '지금 바로',
                  selected: _quick == _ScheduleQuickPick.immediate,
                  onTap: () => _setQuick(_ScheduleQuickPick.immediate),
                ),
                const SizedBox(width: 10),
                ChildScheduleQuickPickCard(
                  icon: Icons.wb_twilight_rounded,
                  title: '오늘 저녁',
                  subtitle: '6시',
                  selected: _quick == _ScheduleQuickPick.evening,
                  onTap: () => _setQuick(_ScheduleQuickPick.evening),
                ),
                const SizedBox(width: 10),
                ChildScheduleQuickPickCard(
                  icon: Icons.wb_sunny_outlined,
                  title: '내일 아침',
                  subtitle: '9시',
                  selected: _quick == _ScheduleQuickPick.morning,
                  onTap: () => _setQuick(_ScheduleQuickPick.morning),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1, color: Color(0xFFE8E0D4)),
            ),
            const Text(
              '날짜·시간 직접 설정',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ChildDashboardColors.textSub,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: InputDecorator(
                    decoration: _dropdownDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _dayOffset,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        items: List.generate(
                          15,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                              _dayLabel(i),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        onChanged: (v) => setState(() {
                          _quick = _ScheduleQuickPick.custom;
                          _dayOffset = v ?? 0;
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputDecorator(
                    decoration: _dropdownDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _hour,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        items: List.generate(
                          24,
                          (h) => DropdownMenuItem(value: h, child: Text('$h시')),
                        ),
                        onChanged: (v) => setState(() {
                          _quick = _ScheduleQuickPick.custom;
                          _hour = v ?? 0;
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputDecorator(
                    decoration: _dropdownDecoration(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _minute,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        items: _minuteSteps
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text('$m분'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _quick = _ScheduleQuickPick.custom;
                          _minute = v ?? _minuteSteps.first;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ChildPrimaryFilledButton(
              label: '이 시간으로 예약',
              onPressed: () {
                switch (_quick) {
                  case _ScheduleQuickPick.immediate:
                    widget.onPick(null);
                    return;
                  case _ScheduleQuickPick.evening:
                    widget.onPick(_nextWallClock(18, 0));
                    return;
                  case _ScheduleQuickPick.morning:
                    final t = _today.add(const Duration(days: 1));
                    widget.onPick(DateTime(t.year, t.month, t.day, 9, 0));
                    return;
                  case _ScheduleQuickPick.custom:
                    final dt = _combine();
                    if (!dt.isAfter(widget.now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('지난 시간이에요. 다시 골라 주세요.')),
                      );
                      return;
                    }
                    widget.onPick(dt);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
