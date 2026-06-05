import 'package:flutter/material.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/shared/widgets/round_white_icon_button.dart';

const kParentPhotoPrimaryText = Color(0xFF2D1F0A);

const kParentPhotoShadowCard = BoxShadow(
  color: Color(0x2EEF9F27),
  blurRadius: 24,
  offset: Offset(0, 6),
);

const kParentPhotoShadowNavSoft = BoxShadow(
  color: Color(0x1AEF9F27),
  blurRadius: 14,
  offset: Offset(0, 3),
);

/// 사진 보기 / 지난 사진 공통 — 뒤로 · 날짜 · 도트
class ParentPhotoViewHeader extends StatelessWidget {
  const ParentPhotoViewHeader({
    super.key,
    required this.dateText,
    required this.dotCount,
    required this.activeDotIndex,
    required this.onBack,
  });

  final String dateText;
  final int dotCount;
  final int activeDotIndex;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: RoundWhiteIconButton(
                onPressed: onBack,
                icon: Icons.chevron_left_rounded,
                label: '뒤로가기',
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dateText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: kParentPhotoPrimaryText,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(dotCount, (i) {
                      final active = i == activeDotIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: active ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: active ? ItdaColors.orange : ItdaColors.border,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: RoundWhiteIconButton(
                    onPressed: () {},
                    icon: Icons.chevron_left_rounded,
                    label: '뒤로가기',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParentPhotoNavButton extends StatelessWidget {
  const ParentPhotoNavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconAfter,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool iconAfter;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final iconColor =
        (disabled ? kParentPhotoPrimaryText : ItdaColors.orangeDark).withValues(alpha: disabled ? 0.35 : 1);
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!iconAfter) ...[
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: iconColor,
          ),
        ),
        if (iconAfter) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 24, color: iconColor),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [kParentPhotoShadowNavSoft],
          ),
          child: SizedBox(
            height: 56,
            child: Center(child: row),
          ),
        ),
      ),
    );
  }
}

class ParentPhotoHtmlCard extends StatelessWidget {
  const ParentPhotoHtmlCard({super.key, required this.photo});

  final ParentPendingPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: photo.isNew ? Border.all(color: ItdaColors.orange, width: 3) : null,
          boxShadow: const [kParentPhotoShadowCard],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (photo.isNew) const _ParentPhotoNewBadge(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ItdaColors.orangeLight,
                      Color(0xFFFAC775),
                      ItdaColors.orangeMid,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: ClipRect(
                  child: Image.network(
                    photo.displayUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, prog) {
                      if (prog == null) return child;
                      return const Center(child: CircularProgressIndicator(color: ItdaColors.orange));
                    },
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 80,
                        color: ItdaColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ItdaColors.orangePale,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  photo.caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: kParentPhotoPrimaryText,
                    height: 1.3,
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

class _ParentPhotoNewBadge extends StatefulWidget {
  const _ParentPhotoNewBadge();

  @override
  State<_ParentPhotoNewBadge> createState() => _ParentPhotoNewBadgeState();
}

class _ParentPhotoNewBadgeState extends State<_ParentPhotoNewBadge> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: ItdaColors.orange,
      child: Row(
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.4).animate(
              CurvedAnimation(parent: _c, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '새로운 사진이에요!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
