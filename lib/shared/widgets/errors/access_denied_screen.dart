import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/session_provider.dart';
import '../buttons/bedlink_button.dart';
import '../cards/bedlink_card.dart';
import '../chrome/bedlink_app_bar.dart';

/// Screen displayed when an authenticated user attempts to access a route restricted to another role.
class AccessDeniedScreen extends ConsumerWidget {
  const AccessDeniedScreen({
    super.key,
    required this.attemptedRoute,
    required this.requiredRole,
  });

  final String attemptedRoute;
  final UserRole requiredRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BedLinkAppBar(
        title: 'ACCESS RESTRICTED',
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BedLinkCard(
                    variant: BedLinkCardVariant.critical,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.gpp_bad_outlined,
                              size: 28,
                              color: AppColors.criticalRed,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'RESTRICTED OPERATIONAL ZONE',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.criticalRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your authenticated profile (${session.role.displayName}) does not possess clinical permissions to view route "$attemptedRoute".',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Required Role: ${requiredRole.displayName}',
                          style: AppTypography.operationalLabel.copyWith(
                            color: AppColors.primarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BedLinkButton(
                    label: session.isAmbulance
                        ? 'RETURN TO AMBULANCE DISPATCH'
                        : (session.isHospital ? 'RETURN TO HOSPITAL TRIAGE' : 'RETURN TO LOGIN'),
                    icon: Icons.home_outlined,
                    variant: BedLinkButtonVariant.primary,
                    onPressed: () {
                      if (session.isAmbulance) {
                        context.go('/ambulance');
                      } else if (session.isHospital) {
                        context.go('/hospital');
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  BedLinkButton(
                    label: 'SWITCH CLINICAL ACCOUNT',
                    icon: Icons.switch_account_outlined,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () async {
                      await ref.read(sessionProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
