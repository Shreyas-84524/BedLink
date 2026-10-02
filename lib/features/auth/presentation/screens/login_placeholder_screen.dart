import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

class LoginPlaceholderScreen extends ConsumerWidget {
  const LoginPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('BedLink Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Role & Sign In',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Foundation mock login for role-based navigation verification.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            BedLinkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emergency_rounded, color: AppColors.secondaryTeal),
                      SizedBox(width: 8),
                      Text(
                        'Ambulance Crew Flow',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Unit 101 • Mumbai EMS Central',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  BedLinkButton(
                    label: 'Login as Ambulance Crew',
                    onPressed: () {
                      ref.read(sessionProvider.notifier).loginAsAmbulance();
                      context.go('/ambulance');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BedLinkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_hospital_rounded, color: AppColors.primarySlate),
                      SizedBox(width: 8),
                      Text(
                        'Hospital Staff Flow',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'KEM Hospital • Emergency Triage Desk',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  BedLinkButton(
                    label: 'Login as Hospital Staff',
                    variant: BedLinkButtonVariant.available,
                    onPressed: () {
                      ref.read(sessionProvider.notifier).loginAsHospital();
                      context.go('/hospital');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            BedLinkButton(
              label: 'Explore Design System Catalog',
              variant: BedLinkButtonVariant.secondary,
              icon: Icons.palette_outlined,
              onPressed: () => context.go('/design-system'),
            ),
          ],
        ),
      ),
    );
  }
}
