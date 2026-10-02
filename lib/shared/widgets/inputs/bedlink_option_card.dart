import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Selectable Option Card used for clinical urgency, chief complaints, and intake choices.
class BedLinkOptionCard extends StatelessWidget {
  const BedLinkOptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.icon,
    this.accentColor,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? badge;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = accentColor ?? AppColors.primarySlate;

    return Material(
      color: isSelected ? AppColors.surface : AppColors.surfaceSubtle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? selectedColor : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? selectedColor : AppColors.borderSubtle,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? selectedColor : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.cardTitle.copyWith(
                              color: isSelected ? selectedColor : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ?badge,
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? selectedColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? selectedColor : AppColors.borderStrong,
                    width: 2.0,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: AppColors.textInverse)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
