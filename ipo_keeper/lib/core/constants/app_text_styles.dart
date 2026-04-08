import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const heading2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const heading3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const body1 = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const body2 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static const money = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.profit, letterSpacing: -0.5);
}
