import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const heroTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 39,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -1.56,
  );

  static const screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 31,
    fontWeight: FontWeight.w600,
    height: 39 / 31,
    letterSpacing: -1,
  );

  static const screenSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
  );

  static const sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: -0.6,
  );

  static const body = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const bodyMuted = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
  );

  static const primaryButton = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
  );

  static const secondaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
  );

  static const inputLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
  );

  static const inputValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
  );

  static const inputPlaceholder = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
  );

  static const errorText = TextStyle(
    color: AppColors.error,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
  );

  static const sheetTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 25,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -1,
  );

  static const optionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 26 / 18,
  );

  static const optionDescription = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
  );

  static const successLabel = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 26 / 16,
  );

  static const subscriptionAmount = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 30 / 24,
    letterSpacing: -0.5,
  );

  static const statValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const tabLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const tabLabelActive = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const smallLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );
}
