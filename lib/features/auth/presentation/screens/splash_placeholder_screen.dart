import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/providers/session_provider.dart';

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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primarySlate,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 40,
                  color: AppColors.secondaryTeal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primarySlate,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (session.role.isAmbulance) {
                    context.go('/ambulance');
                  } else if (session.role.isHospital) {
                    context.go('/hospital');
                  } else {
                    context.go('/login');
                  }
                },
                child: const Text('Enter Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
