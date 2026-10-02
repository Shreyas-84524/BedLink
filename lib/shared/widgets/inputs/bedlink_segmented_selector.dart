import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class BedLinkSegmentOption<T> {
  const BedLinkSegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Accessible Segmented Selector with >=48dp tap target and strong selection state.
class BedLinkSegmentedSelector<T> extends StatelessWidget {
  const BedLinkSegmentedSelector({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.label,
    super.key,
  });

  final List<BedLinkSegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final String? label;

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
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            children: options.map((option) {
              final bool isSelected = option.value == selectedValue;

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySlate : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (option.icon != null) ...[
                            Icon(
                              option.icon,
                              size: 16,
                              color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: (isSelected ? AppTypography.button : AppTypography.label).copyWith(
                                color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
