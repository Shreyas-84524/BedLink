import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// High-visibility 52px form input field with accessible touch targets and clear error display.
class BedLinkTextField extends StatelessWidget {
  const BedLinkTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelStrong,
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppTypography.bodyLarge.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.disabledText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
            errorText: errorText,
            errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.criticalDark),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.surfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderStrong, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.borderActive, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
