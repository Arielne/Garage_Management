import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const bgApp = Color(0xFFF5F6F7);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceSunken = Color(0xFFECEEF0);
  static const surfaceDark = Color(0xFF3A3A3A);

  static const accent = Color(0xFFFF7A1A);
  static const accentPress = Color(0xFFE66A0E);
  static const accentSoft = Color(0xFFFFF1E6);

  /// Cột phụ trong biểu đồ. `accentSoft` là màu NỀN cho chip/badge — tô cột
  /// bằng nó thì gần như trắng trên nền thẻ (#FFFFFF) nên không nhìn thấy.
  static const accentMuted = Color(0xFFFFC398);

  static const textPrimary = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF6B7178);
  static const textTertiary = Color(0xFF9AA0A6);

  static const borderSubtle = Color(0xFFDDE0E3);
  static const divider = Color(0xFFECEEF0);

  static const statusDone = Color(0xFF2E9E5B);
  static const statusDoneSoft = Color(0xFFE7F4ED);
  static const statusWait = Color(0xFFE8A800);
  static const statusWaitSoft = Color(0xFFFCF4DE);
  static const statusError = Color(0xFFD64545);
  static const statusErrorSoft = Color(0xFFFBE9E9);
  static const statusIdle = Color(0xFFC4C8CC);
}
