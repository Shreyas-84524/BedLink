import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/chrome/bedlink_logo.dart';
import '../../../../shared/widgets/chrome/med_net_live_badge.dart';
import '../../../../shared/widgets/inputs/bedlink_chips.dart';
import '../../../../shared/widgets/inputs/bedlink_segmented_selector.dart';
import '../../../../shared/widgets/inputs/bedlink_text_field.dart';
import '../../../../shared/widgets/inputs/bedlink_validation_message.dart';
import '../../domain/models/auth_credentials.dart';

/// Clinical Authentication & Role Selection Screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: '1010101010');
  final _passwordController = TextEditingController(text: 'password123');

  UserRole _selectedRole = UserRole.ambulanceCrew;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole newRole) {
    if (_selectedRole == newRole) return;
    setState(() {
      _selectedRole = newRole;
      if (newRole == UserRole.ambulanceCrew) {
        _identifierController.text = '1010101010';
        _passwordController.text = 'password123';
      } else {
        _identifierController.text = '9090909090';
        _passwordController.text = 'password123';
      }
    });
    ref.read(sessionProvider.notifier).clearError();
  }

  void _fillDemoAmbulance() {
    setState(() {
      _selectedRole = UserRole.ambulanceCrew;
      _identifierController.text = '1010101010';
      _passwordController.text = 'password123';
    });
    ref.read(sessionProvider.notifier).clearError();
  }

  void _fillDemoHospital() {
    setState(() {
      _selectedRole = UserRole.hospitalStaff;
      _identifierController.text = '9090909090';
      _passwordController.text = 'password123';
    });
    ref.read(sessionProvider.notifier).clearError();
  }

  Future<void> _handleLogin() async {
    ref.read(sessionProvider.notifier).clearError();

    final credentials = AuthCredentials(
      identifier: _identifierController.text,
      password: _passwordController.text,
      role: _selectedRole,
    );

    final success = await ref.read(sessionProvider.notifier).login(credentials);
    if (success && mounted) {
      if (_selectedRole.isAmbulance) {
        context.go('/ambulance');
      } else if (_selectedRole.isHospital) {
        context.go('/hospital');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Chrome Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => context.go('/'),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textSecondary),
                                SizedBox(width: 4),
                                Text('STARTUP', style: AppTypography.operationalLabel),
                              ],
                            ),
                          ),
                        ),
                        const MedNetLiveBadge(),
                      ],
                    ),

                    // Main Form Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Center(child: BedLinkLogo(compact: false, showTagline: true)),
                        const SizedBox(height: 8),
                        const Text(
                          'EMERGENCY NETWORK ACCESS',
                          style: AppTypography.operationalLabel,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your clinical role and authenticate to access dispatch or bed allocation services.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Role Selector
                        const Text('SELECT ROLE', style: AppTypography.operationalLabel),
                        const SizedBox(height: 6),
                        BedLinkSegmentedSelector<UserRole>(
                          selectedValue: _selectedRole,
                          onChanged: _onRoleChanged,
                          options: const [
                            BedLinkSegmentOption(
                              value: UserRole.ambulanceCrew,
                              label: 'Ambulance Crew',
                              icon: Icons.emergency_rounded,
                            ),
                            BedLinkSegmentOption(
                              value: UserRole.hospitalStaff,
                              label: 'Hospital Staff',
                              icon: Icons.local_hospital_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Form Container Card
                        BedLinkCard(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Role Banner inside Card
                                Row(
                                  children: [
                                    Icon(
                                      _selectedRole.isAmbulance
                                          ? Icons.emergency_outlined
                                          : Icons.local_hospital_outlined,
                                      size: 18,
                                      color: _selectedRole.isAmbulance
                                          ? AppColors.primarySlate
                                          : AppColors.secondaryTeal,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedRole.isAmbulance
                                            ? 'AMBULANCE DISPATCH & INTAKE'
                                            : 'HOSPITAL TRIAGE & CAPACITY',
                                        style: AppTypography.operationalLabel.copyWith(
                                          color: AppColors.primarySlate,
                                        ),
                                      ),
                                    ),
                                    BedLinkBadge(
                                      label: _selectedRole.isAmbulance ? 'ZONE 1' : 'CAMPUS A',
                                    ),
                                  ],
                                ),
                                const Divider(height: 16, color: AppColors.border),

                                // Error Banner if present
                                if (session.errorMessage != null) ...[
                                  BedLinkValidationMessage(
                                    message: session.errorMessage!,
                                    severity: ValidationSeverity.error,
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // ID Field
                                BedLinkTextField(
                                  label: _selectedRole.isAmbulance
                                      ? '10-Digit ID / Vehicle Callsign'
                                      : '10-Digit Staff ID / Hospital Code',
                                  hint: _selectedRole.isAmbulance ? 'e.g. 1010101010' : 'e.g. 9090909090',
                                  controller: _identifierController,
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 12),

                                // Password Field
                                BedLinkTextField(
                                  label: 'Security Passcode / Password',
                                  hint: 'Enter clinical access passcode',
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Submit Button
                                BedLinkButton(
                                  label: _selectedRole.isAmbulance
                                      ? 'AUTHENTICATE AS AMBULANCE'
                                      : 'AUTHENTICATE AS HOSPITAL',
                                  icon: Icons.shield_outlined,
                                  variant: _selectedRole.isAmbulance
                                      ? BedLinkButtonVariant.primary
                                      : BedLinkButtonVariant.available,
                                  isLoading: session.isLoading,
                                  onPressed: _handleLogin,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fast Demo Shortcuts Card
                        BedLinkCard(
                          variant: BedLinkCardVariant.muted,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEMO TEST CREDENTIALS',
                                style: AppTypography.operationalLabel.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  BedLinkQuickAddChip(
                                    label: '⚡ Fill Demo Crew (101)',
                                    onTap: _fillDemoAmbulance,
                                  ),
                                  BedLinkQuickAddChip(
                                    label: '⚡ Fill Demo Hospital (KEM)',
                                    onTap: _fillDemoHospital,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Security & Compliance Footer
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: AppColors.textMuted),
                            SizedBox(width: 4),
                            Text(
                              'MED-NET SECURE DISPATCH PROTOCOL • 256-BIT TLS',
                              style: AppTypography.operationalLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => context.go('/design-system'),
                          child: Text(
                            'Open Design System Catalog',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.secondaryTeal,
                              decoration: TextDecoration.underline,
                            ),
                          ),
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
}
