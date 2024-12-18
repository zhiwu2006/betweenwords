import 'package:flutter/material.dart';

class AppTheme {
  // 主色调
  static const Color primaryLight = Color(0xFF5C6BC0);  // 靛蓝色
  static const Color primaryDark = Color(0xFF7986CB);   // 亮靛蓝色
  
  // 背景色
  static const Color backgroundLight = Color(0xFFF5F7FA);  // 浅灰蓝色
  static const Color backgroundDark = Color(0xFF121212);   // 深色背景
  
  // 卡片颜色
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // 文字颜色
  static const Color textPrimaryLight = Color(0xFF1A237E);    // 深靛蓝色
  static const Color textSecondaryLight = Color(0xFF3949AB);  // 中靛蓝色
  static const Color textPrimaryDark = Color(0xFFE8EAF6);     // 浅靛蓝色
  static const Color textSecondaryDark = Color(0xFFC5CAE9);   // 更浅的靛蓝色
  
  // 强调色
  static const Color accentLight = Color(0xFFFF4081);  // 粉红色
  static const Color accentDark = Color(0xFFFF80AB);   // 浅粉红色

  // 字体样式
  static const TextStyle headingLight = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimaryLight,
    letterSpacing: 0.15,
  );
  
  static const TextStyle headingDark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimaryDark,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subheadingLight = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textSecondaryLight,
    letterSpacing: 0.1,
  );
  
  static const TextStyle subheadingDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textSecondaryDark,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondaryLight,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondaryDark,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // 卡片装饰
  static BoxDecoration cardDecorationLight = BoxDecoration(
    color: cardLight,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryLight.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration cardDecorationDark = BoxDecoration(
    color: cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryDark.withOpacity(0.1),
      width: 1,
    ),
  );

  // 需要复习的单词背景色
  static const Color reviewBackgroundLight = Color(0xFFFFEBEE);  // 浅粉色
  static const Color reviewBackgroundDark = Color(0xFF311B1B);   // 深红色

  // 渐变色
  static const LinearGradient primaryGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5C6BC0),  // 靛蓝色
      Color(0xFF3F51B5),  // 深靛蓝色
    ],
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7986CB),  // 亮靛蓝色
      Color(0xFF5C6BC0),  // 靛蓝色
    ],
  );
} 