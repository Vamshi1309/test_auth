// lib/core/constants/app_sizes.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Use these constants INSIDE your widgets
/// DO NOT use in theme definitions
class AppSizes {
  // Spacing values (use these for consistency)
  static double xs = 4.r;
  static double sm = 8.r;
  static double md = 16.r;
  static double lg = 24.r;
  static double xl = 32.r;

  // Padding
  static EdgeInsets get paddingH16 => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingV16 => EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get paddingAll16 => EdgeInsets.all(16.r);
  static EdgeInsets get paddingAll24 => EdgeInsets.all(24.r);

  // Gaps
  static SizedBox get gap8 => SizedBox(height: 8.h, width: 8.w);
  static SizedBox get gap12 => SizedBox(height: 12.h, width: 12.w);
  static SizedBox get gap16 => SizedBox(height: 16.h, width: 16.w);
  static SizedBox get gap24 => SizedBox(height: 24.h, width: 24.w);

  // Border Radius
  static double get radiusSmall => 8.r;
  static double get radiusMedium => 12.r;
  static double get radiusLarge => 16.r;

  // Icon sizes
  static double get iconSmall => 20.r;
  static double get iconMedium => 24.r;
  static double get iconLarge => 32.r;

  // Button heights
  static double get buttonHeight => 56.h;
  static double get buttonHeightSmall => 44.h;
}
