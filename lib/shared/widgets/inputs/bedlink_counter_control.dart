import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Rapid Inventory Adjustment Counter Control designed for sub-10s updates.
/// Features large 48dp +/- buttons, large monospaced count readout, and non-negative constraints.
class BedLinkCounterControl extends StatelessWidget {
  const BedLinkCounterControl({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.label,
    this.unit = 'BEDS',
    this.enabled = true,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? label;
  final String unit;
  final bool enabled;

  bool get _canDecrement => enabled && value > min;
  bool get _canIncrement => enabled && value < max;

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.disabledBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrement Button (-)
              Material(
                color: _canDecrement ? AppColors.surfaceSubtle : AppColors.disabledBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: _canDecrement ? AppColors.borderStrong : AppColors.disabledBorder,
                  ),
                ),
                child: InkWell(
                  onTap: _canDecrement ? () => onChanged(value - 1) : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.remove_rounded,
                      size: 24,
                      color: _canDecrement ? AppColors.textPrimary : AppColors.disabledText,
                    ),
                  ),
                ),
              ),
              // Value Readout
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toString().padLeft(2, '0'),
                      style: AppTypography.operationalValueLg.copyWith(
                        color: enabled
                            ? (value == 0 ? AppColors.criticalRed : AppColors.textPrimary)
                            : AppColors.disabledText,
                      ),
                    ),
                    Text(
                      unit.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Increment Button (+)
              Material(
                color: _canIncrement ? AppColors.primarySlate : AppColors.disabledBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: _canIncrement ? () => onChanged(value + 1) : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: _canIncrement ? AppColors.textInverse : AppColors.disabledText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
