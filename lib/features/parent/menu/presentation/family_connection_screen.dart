import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/auth/auth_service.dart';
import 'package:itda/core/models/family.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/shared/providers/family_provider.dart';

class FamilyConnectionScreen extends ConsumerStatefulWidget {
  const FamilyConnectionScreen({
    super.key,
    this.showBackButton = true,
    this.showLogoutButton = false,
    this.onConnected,
  });

  final bool showBackButton;
  final bool showLogoutButton;
  final VoidCallback? onConnected;

  @override
  ConsumerState<FamilyConnectionScreen> createState() =>
      _FamilyConnectionScreenState();
}

class _FamilyConnectionScreenState
    extends ConsumerState<FamilyConnectionScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  FamilyLink? _connectedLink;
  bool _connecting = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    final normalized = value.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (normalized.length > 1) {
      _fillCodeFrom(index, normalized);
      setState(() {});
      return;
    }

    _controllers[index].text = normalized;
    _controllers[index].selection = TextSelection.collapsed(
      offset: _controllers[index].text.length,
    );

    if (normalized.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _fillCodeFrom(int startIndex, String value) {
    final chars = value.characters.take(_controllers.length).toList();
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < chars.length ? chars[i] : '';
      _controllers[i].selection = TextSelection.collapsed(
        offset: _controllers[i].text.length,
      );
    }
    final focusIndex = chars.length >= _controllers.length
        ? _controllers.length - 1
        : (startIndex + chars.length).clamp(0, _controllers.length - 1);
    _focusNodes[focusIndex].requestFocus();
  }

  void _onBackspace(int index) {
    final current = _controllers[index];
    if (current.text.isNotEmpty) {
      current.clear();
      setState(() {});
      return;
    }
    if (index <= 0) return;
    final previous = _controllers[index - 1];
    previous.clear();
    _focusNodes[index - 1].requestFocus();
    setState(() {});
  }

  Future<void> _connect() async {
    if (_code.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초대 코드 4자리를 입력해주세요.')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _connecting = true);
    try {
      final result = await ref.read(familyServiceProvider).connect(_code);
      if (!mounted) return;
      ref.invalidate(familyMeProvider);
      final family = await ref.read(familyMeProvider.future);
      if (!mounted) return;
      setState(() => _connectedLink = family.activeLink ?? result.link);
      widget.onConnected?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? '가족 연결이 완료됐어요.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.messageFromError(
              error,
              fallback: '가족 연결에 실패했어요. 초대 코드를 확인해 주세요.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃할까요?'),
        content: const Text('현재 계정에서 로그아웃하고 로그인 화면으로 이동합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await ref.read(authServiceProvider).signOut();
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(familyMeProvider);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyMeProvider);

    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      appBar: AppBar(
        backgroundColor: ItdaColors.orangePale,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: ItdaColors.text,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: widget.showBackButton
            ? const Text(
                '가족 연결',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: ItdaColors.text,
                ),
              )
            : const SizedBox.shrink(),
        centerTitle: true,
        actions: [
          if (widget.showLogoutButton)
            IconButton(
              tooltip: '로그아웃',
              icon: const Icon(
                Icons.logout_rounded,
                color: ItdaColors.text,
                size: 22,
              ),
              onPressed: _logout,
            )
          else
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                color: ItdaColors.text,
                size: 22,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('자녀가 생성한 초대 코드를 입력해주세요.')),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: familyState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _FamilyLoadError(
            message: AuthService.messageFromError(
              error,
              fallback: '가족 연결 상태를 불러오지 못했어요.',
            ),
            onRetry: () => ref.invalidate(familyMeProvider),
          ),
          data: (family) {
            final connectedLink = _connectedLink ?? family.activeLink;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              children: [
                if (connectedLink != null && connectedLink.isActive)
                  _ConnectedView(
                    link: connectedLink,
                    onConfirm:
                        widget.onConnected ??
                        () => Navigator.of(context).maybePop(),
                  )
                else
                  _CodeInputView(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onChanged: _onCodeChanged,
                    onBackspace: _onBackspace,
                    onConnect: _connect,
                    enabled: _code.length == 4 && !_connecting,
                    connecting: _connecting,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CodeInputView extends StatelessWidget {
  const _CodeInputView({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onBackspace,
    required this.onConnect,
    required this.enabled,
    required this.connecting,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onBackspace;
  final VoidCallback onConnect;
  final bool enabled;
  final bool connecting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/images/family_invite_parent.png',
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        const Text(
          '자녀가 알려준 초대 코드를\n입력해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w900,
            color: ItdaColors.text,
          ),
        ),
        const SizedBox(height: 42),
        const Text(
          '초대 코드 입력',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: ItdaColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < controllers.length; i++) ...[
              Expanded(
                child: _CodeBox(
                  controller: controllers[i],
                  focusNode: focusNodes[i],
                  onChanged: (value) => onChanged(i, value),
                  onBackspace: () => onBackspace(i),
                ),
              ),
              if (i != controllers.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: enabled ? onConnect : null,
          style: FilledButton.styleFrom(
            backgroundColor: ItdaColors.orange,
            disabledBackgroundColor: const Color(0xFFF8E5C2),
            foregroundColor: Colors.white,
            disabledForegroundColor: ItdaColors.textSub,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            connecting ? '연결 중...' : '연결하기',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 22),
        const _NoticePanel(lines: ['코드는 일정 시간이 지나면 만료될 수 있어요.']),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          inputFormatters: const [_InviteCodeInputFormatter()],
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: ItdaColors.text,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: _codeBoxBorder(const Color(0xFFEBD8BA)),
            focusedBorder: _codeBoxBorder(ItdaColors.orange),
          ),
        ),
      ),
    );
  }
}

class _InviteCodeInputFormatter extends TextInputFormatter {
  const _InviteCodeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = newValue.text.toUpperCase().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.link, required this.onConfirm});

  final FamilyLink link;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        const CircleAvatar(
          radius: 42,
          backgroundColor: ItdaColors.orange,
          child: Icon(Icons.check_rounded, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 28),
        const Text(
          '연결이 완료되었습니다!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: ItdaColors.text,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '이제 자녀와 사진과 건강 정보를\n공유할 수 있어요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.65,
            fontWeight: FontWeight.w600,
            color: ItdaColors.textSub,
          ),
        ),
        const SizedBox(height: 44),
        _ConnectedChildCard(childName: link.childName),
        const SizedBox(height: 44),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: ItdaColors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            '확인',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ConnectedChildCard extends StatelessWidget {
  const _ConnectedChildCard({required this.childName});

  final String? childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6D4B8)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EBD4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text('👧', style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연결된 자녀',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ItdaColors.textSub,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayFamilyName(childName, fallback: '자녀'),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: ItdaColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _displayFamilyName(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return fallback;
  return trimmed.endsWith('님') ? trimmed : '$trimmed님';
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFD7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '안내',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: ItdaColors.text,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Text(
              line,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w600,
                color: ItdaColors.textSub,
              ),
            ),
        ],
      ),
    );
  }
}

class _FamilyLoadError extends StatelessWidget {
  const _FamilyLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ItdaColors.textSub,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

OutlineInputBorder _codeBoxBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: 1.4),
  );
}
