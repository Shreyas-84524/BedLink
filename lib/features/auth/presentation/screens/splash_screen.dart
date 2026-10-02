import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/chrome/bedlink_logo.dart';
import '../../../../shared/widgets/chrome/med_net_live_badge.dart';

/// Professional BedLink Startup / Splash Screen.
///
/// Communicates clinical network identity, initialization status, and role entry point.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _simulateStartupSequence();
  }

  Future<void> _simulateStartupSequence() async {
    // Fast 600ms startup verification
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });

      // If user is already authenticated, router redirect will take them to their shell
      final session = ref.read(sessionProvider);
      if (session.isAuthenticated) {
        if (session.isAmbulance) {
          context.go('/ambulance');
        } else if (session.isHospital) {
          context.go('/hospital');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Chrome Bar
                    const Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        BedLinkBadge(
                          label: 'MUMBAI ZONE',
                        ),
                        MedNetLiveBadge(),
                      ],
                    ),

                    // Central Branding & Status
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        const BedLinkLogo(compact: false, showTagline: true),
                        const SizedBox(height: 12),
                        const Text(
                          'EMERGENCY HOSPITAL ALLOCATION',
                          style: AppTypography.operationalLabel,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rapid bed discovery, dynamic triage & live en-route patient allocation for Mumbai.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // System Readiness Checklist Card
                        BedLinkCard(
                          variant: BedLinkCardVariant.highlighted,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_user_outlined,
                                    size: 18,
                                    color: AppColors.secondaryTeal,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'NETWORK READINESS CHECK',
                                      style: AppTypography.operationalLabel.copyWith(
                                        color: AppColors.primarySlate,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16, color: AppColors.border),
                              _buildStatusRow(
                                label: 'MED-NET Realtime Sync',
                                status: _isInitializing ? 'CONNECTING...' : 'ONLINE',
                                isReady: !_isInitializing,
                              ),
                              const SizedBox(height: 8),
                              _buildStatusRow(
                                label: 'Hospital Triage Grid',
                                status: _isInitializing ? 'INITIALIZING...' : 'CONNECTED (18 Hosps)',
                                isReady: !_isInitializing,
                              ),
                              const SizedBox(height: 8),
                              _buildStatusRow(
                                label: 'ORS Road Matrix Gateway',
                                status: _isInitializing ? 'READY' : 'STANDBY',
                                isReady: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Action Panel
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        BedLinkButton(
                          label: 'PROCEED TO LOGIN',
                          icon: Icons.login_rounded,
                          variant: BedLinkButtonVariant.primary,
                          isLoading: _isInitializing,
                          onPressed: () => context.go('/login'),
                        ),
                        const SizedBox(height: 12),
                        BedLinkButton(
                          label: 'VIEW DESIGN SYSTEM',
                          icon: Icons.palette_outlined,
                          variant: BedLinkButtonVariant.secondary,
                          onPressed: () => context.go('/design-system'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'BedLink v1.0.0 • Mumbai Emergency Dispatch Protocol',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required String label,
    required String status,
    required bool isReady,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: AppTypography.operationalDataBold.copyWith(
            fontSize: 11,
            color: isReady ? AppColors.secondaryTeal : AppColors.warningAmber,
          ),
        ),
      ],
    );
  }
}
