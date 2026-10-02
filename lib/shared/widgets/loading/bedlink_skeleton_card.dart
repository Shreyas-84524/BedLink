import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../cards/bedlink_card.dart';

/// Lightweight skeleton placeholder card for asynchronous loading states.
/// Does not require third-party shimmer packages.
class BedLinkSkeletonCard extends StatelessWidget {
  const BedLinkSkeletonCard({
    this.height = 100,
    this.lines = 3,
    this.margin,
    super.key,
  });

  final double height;
  final int lines;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return BedLinkCard(
      variant: BedLinkCardVariant.muted,
      margin: margin,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlaceholder(width: 120, height: 14),
              _buildPlaceholder(width: 60, height: 18, radius: 4),
            ],
          ),
          const SizedBox(height: 12),
          _buildPlaceholder(width: double.infinity, height: 16),
          if (lines > 1) ...[
            const SizedBox(height: 8),
            _buildPlaceholder(width: 200, height: 12),
          ],
          if (lines > 2) ...[
            const SizedBox(height: 8),
            _buildPlaceholder(width: 140, height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderSubtle,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
