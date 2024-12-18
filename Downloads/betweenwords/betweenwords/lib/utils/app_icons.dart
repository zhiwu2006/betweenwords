import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // PNG 图标
  static Image getIcon(String name, {double? width, double? height, Color? color}) {
    return Image.asset(
      'assets/icons/$name.png',
      width: width,
      height: height,
      color: color,
    );
  }

  // SVG 图标
  static Widget getSvgIcon(String name, {double? width, double? height, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // 预定义的图标名称常量
  static const String category = 'category';
  static const String word = 'word';
  static const String translate = 'translate';
  static const String example = 'example';
  static const String pronunciation = 'pronunciation';
  // ... 添加更多图标名称
} 