import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/chrome/bedlink_logo.dart';
import '../../../../shared/widgets/chrome/med_net_live_badge.dart';

class SplashPlaceholderScreen extends ConsumerWidget {
  const SplashPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BedLinkLogo(showTagline: true),
              const SizedBox(height: 16),
              const MedNetLiveBadge(isLive: true),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: 40),
              BedLinkButton(
                label: 'Enter Application',
                icon: Icons.login_rounded,
                onPressed: () {
                  if (session.role.isAmbulance) {
                    context.go('/ambulance');
                  } else if (session.role.isHospital) {
                    context.go('/hospital');
                  } else {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
              BedLinkButton(
                label: 'Design System Showcase',
                variant: BedLinkButtonVariant.secondary,
                icon: Icons.palette_outlined,
                onPressed: () => context.go('/design-system'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
