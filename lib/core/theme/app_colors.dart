import 'package:flutter/material.dart';

/// 잇다(itda) 공통 브랜드 팔레트 — 자녀·부모·역할 선택 동일
class AppColors {
  AppColors._();

  static const orangeDark = Color(0xFFC87020);
  static const orange = Color(0xFFEF9F27);
  static const orangeMid = Color(0xFFF5B84F);
  static const orangeLight = Color(0xFFFAEEDA);
  static const orangePale = Color(0xFFFFF8EC);
  static const text = Color(0xFF3D2B14);
  static const textSub = Color(0xFF8A6F4A);
  static const textMuted = Color(0xFFC2A876);
  static const danger = Color(0xFFD9534F);
  static const dangerLight = Color(0xFFFBE9E7);
  static const success = Color(0xFF5CB85C);
  static const successLight = Color(0xFFE6F4E6);
  static const coral1 = Color(0xFFD85A30);
  static const coral2 = Color(0xFFF0997B);
  static const purple1 = Color(0xFF8874C7);
  static const purple2 = Color(0xFFA594D8);
  static const warnBg = Color(0xFFFEF3E0);
  static const border = Color(0xFFF2DCB0);
}

/// [AppColors]와 동일 팔레트. 기존 `ItdaColors` 참조를 유지할 때 사용합니다.
typedef ItdaColors = AppColors;
