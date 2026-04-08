import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF1A6FFF);
  static const primaryLight = Color(0xFFE8F1FF);

  // Status
  static const applied = Color(0xFF1A6FFF);      // 청약완료 - 파랑
  static const allocated = Color(0xFFF59E0B);    // 배정확인 - 노랑
  static const refunded = Color(0xFF10B981);     // 환불완료 - 초록
  static const listed = Color(0xFF8B5CF6);       // 상장대기 - 보라
  static const sold = Color(0xFF6B7280);         // 매도완료 - 회색

  // Event
  static const subscription = Color(0xFF1A6FFF); // 청약
  static const refund = Color(0xFF10B981);        // 환불
  static const listing = Color(0xFFF59E0B);       // 상장
  static const forecast = Color(0xFF8B5CF6);      // 수요예측

  // Neutral
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  // Profit
  static const profit = Color(0xFFEF4444);   // 수익 - 빨강 (한국 주식 컨벤션)
  static const loss = Color(0xFF3B82F6);     // 손실 - 파랑
}
