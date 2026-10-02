import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';
import '../buttons/bedlink_button.dart';
import '../cards/bedlink_card.dart';
import '../chrome/bedlink_app_bar.dart';

/// 404 / Route Not Found Error Screen for BedLink.
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({
    super.key,
    required this.uri,
  });

  final String uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BedLinkAppBar(
        title: 'NAVIGATION ERROR',
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
                    variant: BedLinkCardVariant.warning,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 28,
                              color: AppColors.warningAmber,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ROUTE NOT FOUND',
                                style: AppTypography.cardTitle.copyWith(
                                  color: AppColors.warningAmber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The requested clinical dispatch path "$uri" does not exist or has been relocated.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error Code: 404_ROUTE_UNKNOWN',
                          style: AppTypography.operationalLabel.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BedLinkButton(
                    label: session.isAmbulance
                        ? 'RETURN TO AMBULANCE DASHBOARD'
                        : (session.isHospital ? 'RETURN TO HOSPITAL TRIAGE' : 'RETURN TO HOME / LOGIN'),
                    icon: Icons.arrow_back_rounded,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
