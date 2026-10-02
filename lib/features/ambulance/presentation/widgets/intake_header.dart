import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/intake_provider.dart';

/// Operational context and workflow progress banner for Active Patient Intake.
class IntakeHeader extends ConsumerWidget {
  const IntakeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final unitTitle = session.organizationName ?? 'Mumbai EMS Unit 101';

    return BedLinkCard(
      variant: BedLinkCardVariant.highlighted,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKFLOW STEP 01 OF 05',
                      style: AppTypography.operationalLabel.copyWith(
                        color: AppColors.secondaryTeal,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ACTIVE PATIENT INTAKE',
                      style: AppTypography.operationalDataBold.copyWith(
                        fontSize: 16,
                        color: AppColors.primarySlate,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const BedLinkBadge(
                label: 'STEP 1 • TRIAGE',
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.airport_shuttle_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    unitTitle.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.gps_fixed_rounded,
                      size: 14, color: AppColors.secondaryTeal),
                  const SizedBox(width: 4),
                  Text(
                    'DADAR • ZONE 2',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryTeal,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Demo Autofill Shortcut for Paramedics
          InkWell(
            onTap: () {
              ref.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '⚡ Fill Demo STEMI Cardiac Case (Ramesh Patil, 58y, Critical)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primarySlate,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
