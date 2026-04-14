import 'package:flutter/material.dart';

class AppColors {
  // 고향마켓 브랜드 컬러 - 자연/농촌 감성 (Premium Update)
  static const Color primary = Color(0xFF2E7D32);       // 짙은 초록 (농촌)
  static const Color primaryLight = Color(0xFF60AD5E);   // 밝은 초록
  static const Color primaryDark = Color(0xFF1B5E20);    // 더 깊은 초록
  static const Color accent = Color(0xFFFF8F00);         // 따뜻한 주황 (수확)
  static const Color accentLight = Color(0xFFFFBF47);    // 밝은 주황

  // 프리미엄 그라데이션
  static const List<Color> primaryGradient = [Color(0xFF2E7D32), Color(0xFF66BB6A)];
  static const List<Color> accentGradient = [Color(0xFFFF8F00), Color(0xFFFFB300)];
  static const List<Color> glassGradient = [Colors.white70, Colors.white30];

  // 배경 및 표면
  static const Color background = Color(0xFFF8F9FA);    // 더 깨끗하고 밝은 배경
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color glassBg = Color(0xB3FFFFFF);      // 70% 투명도 화이트

  // 텍스트
  static const Color textPrimary = Color(0xFF1A1C1E);   // 더 깊은 검정
  static const Color textSecondary = Color(0xFF42474E); // 가공적인 회색
  static const Color textHint = Color(0xFF8E9199);

  // 상태
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFFFB74D);

  // 디자인 시스템 토큰
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  
  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // 카테고리 태그 (파스텔톤으로 개선)
  static const Color tagVegetable = Color(0xFFE8F5E9);
  static const Color tagFruit = Color(0xFFFFF3E0);
  static const Color tagSeafood = Color(0xFFE3F2FD);
  static const Color tagGrain = Color(0xFFFFF8E1);
  static const Color tagProcessed = Color(0xFFF3E5F5);
  static const Color tagSalt = Color(0xFFECEFF1);
}
