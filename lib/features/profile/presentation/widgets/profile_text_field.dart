import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onBlur;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onBlur?.call();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([controller, focusNode]),
        builder: (context, child) {
          final hasValue = controller.text.trim().isNotEmpty;
          final hasError = errorText != null;
          final isFocused = focusNode.hasFocus;
          final borderColor = hasError
              ? AppColors.error
              : isFocused
              ? AppColors.brandGreen
              : Colors.transparent;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.inputLabel),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor,
                      width: isFocused || hasError ? 1 : 0,
                    ),
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  textCapitalization: textCapitalization,
                  autofillHints: autofillHints,
                  autocorrect: false,
                  enableSuggestions: keyboardType != TextInputType.emailAddress,
                  cursorColor: hasError
                      ? AppColors.error
                      : AppColors.brandGreen,
                  style: AppTextStyles.inputValue.copyWith(
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: AppTextStyles.inputPlaceholder,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(errorText!, style: AppTextStyles.errorText),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}
