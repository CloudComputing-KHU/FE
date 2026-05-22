import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/auth/auth_service.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/shared/widgets/itda_primary_button.dart';

/// 회원가입.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

enum _SignUpRole { child, parent }

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  _SignUpRole _role = _SignUpRole.child;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSendingCode = false;
  bool _isConfirming = false;
  bool _verificationSent = false;

  static const _radius = 14.0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 15, color: AppColors.textMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
      ),
    );
  }

  bool _validateSignUpFields() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력한 뒤 인증해 주세요.')));
      return false;
    }
    if (pw != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않아요.')));
      return false;
    }
    return true;
  }

  Future<void> _sendVerificationCode() async {
    if (!_validateSignUpFields()) return;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() => _isSendingCode = true);
    try {
      final message = await ref
          .read(authServiceProvider)
          .signUp(
            role: _role.name,
            name: name,
            email: email,
            password: pw,
            passwordConfirm: confirm,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? '인증 코드가 이메일로 전송됐어요.')));
      setState(() => _verificationSent = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.messageFromError(
              error,
              fallback: '회원가입에 실패했어요. 입력값을 확인해 주세요.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _confirmCode() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 인증번호를 입력해 주세요.')));
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final message = await ref
          .read(authServiceProvider)
          .confirm(email: email, confirmationCode: code);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message ?? '이메일 인증이 완료됐어요.')));
      context.go(AppRoutes.login);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AuthService.messageFromError(
              error,
              fallback: '인증에 실패했어요. 인증번호를 다시 확인해 주세요.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.orangePale,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '역할을 선택해주세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _RoleChoiceCard(
                      title: '자녀',
                      icon: Icons.person_outline_rounded,
                      selected: _role == _SignUpRole.child,
                      onTap: () => setState(() => _role = _SignUpRole.child),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleChoiceCard(
                      title: '부모님',
                      icon: Icons.elderly_rounded,
                      selected: _role == _SignUpRole.parent,
                      onTap: () => setState(() => _role = _SignUpRole.parent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                '이름',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(hint: '이름을 입력하세요'),
              ),
              const SizedBox(height: 20),
              Text(
                '이메일',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_verificationSent) {
                          setState(() => _verificationSent = false);
                        }
                      },
                      decoration: _fieldDecoration(hint: '이메일을 입력하세요'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isSendingCode ? null : _sendVerificationCode,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.orange,
                        side: const BorderSide(color: AppColors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radius),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Text(
                        _isSendingCode
                            ? '전송 중'
                            : _verificationSent
                            ? '재전송'
                            : '인증하기',
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _verificationSent
                    ? Padding(
                        key: const ValueKey('verification-code'),
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '인증번호',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSub,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _codeCtrl,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isConfirming) _confirmCode();
                              },
                              decoration: _fieldDecoration(
                                hint: '이메일로 받은 인증번호를 입력하세요',
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Text(
                '비밀번호',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  hint: '비밀번호를 입력하세요',
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '비밀번호 확인',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isSendingCode) _sendVerificationCode();
                },
                decoration: _fieldDecoration(
                  hint: '비밀번호를 다시 입력하세요',
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ItdaPrimaryButton(
                label: _verificationSent
                    ? (_isConfirming ? '인증 중...' : '인증 완료')
                    : (_isSendingCode ? '전송 중...' : '인증번호 받기'),
                onPressed: _isSendingCode || _isConfirming
                    ? null
                    : (_verificationSent
                          ? _confirmCode
                          : _sendVerificationCode),
                borderRadius: _radius,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChoiceCard extends StatelessWidget {
  const _RoleChoiceCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_SignUpScreenState._radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_SignUpScreenState._radius),
            border: Border.all(
              color: selected
                  ? AppColors.orange
                  : AppColors.border.withValues(alpha: 0.45),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: AppColors.orange),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
