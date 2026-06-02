import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/auth/auth_service.dart';
import 'package:itda/core/models/family.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/widgets/child_primary_filled_button.dart';
import 'package:itda/features/shared/providers/family_provider.dart';

class ParentConnectionScreen extends ConsumerStatefulWidget {
  const ParentConnectionScreen({
    super.key,
    this.showBackButton = true,
    this.showLogoutButton = false,
  });

  final bool showBackButton;
  final bool showLogoutButton;

  @override
  ConsumerState<ParentConnectionScreen> createState() =>
      _ParentConnectionScreenState();
}

class _ParentConnectionScreenState
    extends ConsumerState<ParentConnectionScreen> {
  FamilyInvite? _createdInvite;
  bool _creating = false;
  bool _checkingConnection = false;
  Timer? _connectionPollTimer;

  String? get _currentInviteCode {
    final created = _createdInvite?.inviteCode;
    if (created != null && created.isNotEmpty) return created;
    final family = ref.read(familyMeProvider).valueOrNull;
    final pending = family?.pendingInvite?.inviteCode;
    if (pending != null && pending.isNotEmpty) return pending;
    return null;
  }

  Future<void> _generateCode() async {
    setState(() => _creating = true);
    try {
      final invite = await ref.read(familyServiceProvider).createInvite();
      if (!mounted) return;
      setState(() => _createdInvite = invite);
      ref.invalidate(familyMeProvider);
      _startConnectionPolling();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(invite.message ?? '초대 코드가 생성됐어요.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.messageFromError(error, fallback: '초대 코드 생성에 실패했어요.'),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _checkConnection({
    bool showWaitingMessage = true,
    bool showProgress = true,
  }) async {
    if (showProgress && _checkingConnection) return;
    if (showProgress) setState(() => _checkingConnection = true);
    try {
      final family = await ref.read(familyServiceProvider).getMyFamily();
      if (!mounted) return;
      if (family.isConnected) {
        _connectionPollTimer?.cancel();
        ref.invalidate(familyMeProvider);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('부모님 연결이 완료됐어요.')));
        return;
      }
      if (showWaitingMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('아직 부모님 연결을 기다리고 있어요.')));
      }
    } catch (error) {
      if (!mounted || !showWaitingMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.messageFromError(error, fallback: '연결 상태를 확인하지 못했어요.'),
          ),
        ),
      );
    } finally {
      if (mounted && showProgress) setState(() => _checkingConnection = false);
    }
  }

  void _startConnectionPolling() {
    _connectionPollTimer?.cancel();
    _connectionPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final family = ref.read(familyMeProvider).valueOrNull;
      if (family?.isConnected == true) {
        _connectionPollTimer?.cancel();
        return;
      }
      _checkConnection(showWaitingMessage: false, showProgress: false);
    });
  }

  Future<void> _copyCode() async {
    final code = _currentInviteCode;
    if (code == null) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('초대 코드를 복사했어요.')));
  }

  void _shareCode() {
    final code = _currentInviteCode;
    if (code == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('부모님 앱에서 초대 코드 $code 를 입력해주세요.')));
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
  void dispose() {
    _connectionPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyMeProvider);

    return Scaffold(
      backgroundColor: ChildDashboardColors.orangePale,
      appBar: AppBar(
        backgroundColor: ChildDashboardColors.orangePale,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: widget.showBackButton,
        title: widget.showBackButton
            ? const Text(
                '부모님 연결',
                style: TextStyle(
                  color: ChildDashboardColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              )
            : const SizedBox.shrink(),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ChildDashboardColors.text,
                  size: 19,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          if (widget.showLogoutButton)
            IconButton(
              tooltip: '로그아웃',
              icon: const Icon(
                Icons.logout_rounded,
                color: ChildDashboardColors.text,
                size: 20,
              ),
              onPressed: _logout,
            )
          else
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                color: ChildDashboardColors.text,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('초대 코드는 10분간 유효해요.')),
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
            final invite = _createdInvite ?? family.pendingInvite;
            if (invite != null && !family.isConnected) {
              _connectionPollTimer ??= Timer(
                Duration.zero,
                _startConnectionPolling,
              );
            }
            final content = family.isConnected
                ? _ConnectedView(link: family.activeLink!)
                : invite == null
                ? _CreateCodeView(
                    creating: _creating,
                    onGenerate: _generateCode,
                    showConnectionStatus: widget.showBackButton,
                  )
                : _GeneratedCodeView(
                    code: invite.inviteCode,
                    expiresAt:
                        invite.expiresAt ??
                        DateTime.now().add(const Duration(minutes: 10)),
                    onCopy: _copyCode,
                    onShare: _shareCode,
                    onRegenerate: _generateCode,
                    onCheckConnection: _checkConnection,
                    regenerating: _creating,
                    checkingConnection: _checkingConnection,
                  );

            if (!widget.showBackButton && !family.isConnected) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 28,
                      ),
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -50),
                          child: SizedBox(
                            width: double.infinity,
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [content],
            );
          },
        ),
      ),
    );
  }
}

class _CreateCodeView extends StatelessWidget {
  const _CreateCodeView({
    required this.creating,
    required this.onGenerate,
    required this.showConnectionStatus,
  });

  final bool creating;
  final VoidCallback onGenerate;
  final bool showConnectionStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Image.asset(
          'assets/images/family_invite_child.png',
          height: 160,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 30),
        const Text(
          '부모님을 앱에 연결해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: ChildDashboardColors.text,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '초대 코드를 생성한 뒤\n부모님 앱에서 입력하면 연결됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.7,
            fontWeight: FontWeight.w600,
            color: ChildDashboardColors.textSub,
          ),
        ),
        const SizedBox(height: 45),
        ChildPrimaryFilledButton(
          label: creating ? '생성 중...' : '초대 코드 생성하기',
          onPressed: creating ? null : onGenerate,
          borderRadius: 10,
          labelFontWeight: FontWeight.w900,
        ),
        if (showConnectionStatus) ...[
          const SizedBox(height: 34),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '연결 상태',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: ChildDashboardColors.text,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _EmptyConnectionPanel(),
        ],
      ],
    );
  }
}

class _GeneratedCodeView extends StatelessWidget {
  const _GeneratedCodeView({
    required this.code,
    required this.expiresAt,
    required this.onCopy,
    required this.onShare,
    required this.onRegenerate,
    required this.onCheckConnection,
    required this.regenerating,
    required this.checkingConnection,
  });

  final String code;
  final DateTime expiresAt;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;
  final VoidCallback onCheckConnection;
  final bool regenerating;
  final bool checkingConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CircleAvatar(
          radius: 34,
          backgroundColor: ChildDashboardColors.orange,
          child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          '초대 코드가 생성되었습니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: ChildDashboardColors.text,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '아래 코드를 부모님 앱에서 입력해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w600,
            color: ChildDashboardColors.textSub,
          ),
        ),
        const SizedBox(height: 26),
        _InviteCodeBox(code: code, expiresAt: expiresAt),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                icon: Icons.content_copy_rounded,
                label: '코드 복사',
                onTap: onCopy,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineActionButton(
                icon: Icons.share_rounded,
                label: '공유하기',
                onTap: onShare,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ChildPrimaryFilledButton(
          label: checkingConnection ? '확인 중...' : '연결 확인하기',
          onPressed: checkingConnection ? null : onCheckConnection,
          borderRadius: 10,
          labelFontWeight: FontWeight.w900,
        ),
        const SizedBox(height: 12),
        _NoticePanel(
          lines: const ['코드는 10분간 유효합니다.', '유효 시간이 지나면 새로 생성해주세요.'],
          onRegenerate: regenerating ? null : onRegenerate,
        ),
      ],
    );
  }
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.link});

  final FamilyLink link;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '연결된 부모님',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: ChildDashboardColors.text,
          ),
        ),
        const SizedBox(height: 10),
        _ConnectedParentCard(parentName: link.parentName),
        const SizedBox(height: 22),
        const Text(
          '연결 관리',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: ChildDashboardColors.text,
          ),
        ),
        const SizedBox(height: 10),
        const _ManagementPanel(),
        const SizedBox(height: 18),
        const _NoticePanel(
          lines: ['연결을 해제하면 알림이 중단되고 공유 데이터도 더 이상 동기화되지 않아요.'],
        ),
      ],
    );
  }
}

class _EmptyConnectionPanel extends StatelessWidget {
  const _EmptyConnectionPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: ChildDashboardColors.orangeLight.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1E0C5)),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.group_outlined,
            color: ChildDashboardColors.orangeMid,
            size: 38,
          ),
          SizedBox(height: 12),
          Text(
            '아직 연결된 부모님이 없습니다.\n초대 코드를 생성해보세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
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

class _InviteCodeBox extends StatelessWidget {
  const _InviteCodeBox({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final minutes = remaining.inMinutes.clamp(0, 99).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60)
        .clamp(0, 59)
        .toString()
        .padLeft(2, '0');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0C982)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Text(
              '초대 코드',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: ChildDashboardColors.textSub,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              code,
              style: const TextStyle(
                fontSize: 38,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: ChildDashboardColors.orange,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0C982))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: ChildDashboardColors.orangeDark,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '유효 시간 $minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ChildDashboardColors.orangeDark,
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

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ChildDashboardColors.text,
        side: const BorderSide(color: Color(0xFFE6CDA5)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ConnectedParentCard extends StatelessWidget {
  const _ConnectedParentCard({required this.parentName});

  final String? parentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ChildDashboardColors.orangeLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('👵', style: TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayFamilyName(parentName, fallback: '부모님'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: ChildDashboardColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const _ConnectionStatusLine(),
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

class _ConnectionStatusLine extends StatelessWidget {
  const _ConnectionStatusLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.circle, color: Color(0xFF2FBA5A), size: 8),
        SizedBox(width: 6),
        Text(
          '연결됨 · 알림 수신 중',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ChildDashboardColors.textSub,
          ),
        ),
      ],
    );
  }
}

class _ManagementPanel extends StatelessWidget {
  const _ManagementPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      child: Column(
        children: const [
          _ManagementTile(icon: Icons.person_outline_rounded, title: '연결 정보'),
          Divider(height: 1),
          _ManagementTile(icon: Icons.notifications_outlined, title: '알림 설정'),
          Divider(height: 1),
          _ManagementTile(
            icon: Icons.cancel_outlined,
            title: '연결 해제',
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  const _ManagementTile({
    required this.icon,
    required this.title,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE4473E) : ChildDashboardColors.text;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: ChildDashboardColors.textMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      minLeadingWidth: 20,
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({required this.lines, this.onRegenerate});

  final List<String> lines;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ChildDashboardColors.orangeLight.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFD7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: ChildDashboardColors.orangeDark,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                '안내',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: ChildDashboardColors.orangeDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '· $line',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: ChildDashboardColors.textSub,
                ),
              ),
            ),
          if (onRegenerate != null) ...[
            const SizedBox(height: 6),
            TextButton(onPressed: onRegenerate, child: const Text('새 코드 생성')),
          ],
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
                color: ChildDashboardColors.textSub,
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

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFEED7B0)),
  );
}
