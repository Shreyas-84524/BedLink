import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/status_badges.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/buttons/bedlink_icon_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/cards/bedlink_metric_card.dart';
import '../../../../shared/widgets/chrome/bedlink_logo.dart';
import '../../../../shared/widgets/chrome/med_net_live_badge.dart';
import '../../../../shared/widgets/inputs/bedlink_chips.dart';
import '../../../../shared/widgets/inputs/bedlink_counter_control.dart';
import '../../../../shared/widgets/inputs/bedlink_option_card.dart';
import '../../../../shared/widgets/inputs/bedlink_search_field.dart';
import '../../../../shared/widgets/inputs/bedlink_segmented_selector.dart';
import '../../../../shared/widgets/inputs/bedlink_text_field.dart';
import '../../../../shared/widgets/inputs/bedlink_validation_message.dart';

/// Comprehensive Development Showcase for all BedLink Design System Components.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  int _counterValue = 3;
  String _selectedUrgency = 'urgent';
  int _segmentedIndex = 0;
  bool _isLoadingButton = false;
  final Set<String> _addedResources = {'ICU Bed', 'Ventilator'};

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Design System Catalog',
      subtitle: 'Phase 2 Visual Benchmark & Primitives',
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSectionHeader('01. Brand & Chrome Components'),
          const BedLinkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BedLink Brand Identity & Live Status', style: AppTypography.labelStrong),
                SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    BedLinkLogo(showTagline: true),
                    MedNetLiveBadge(isLive: true),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    BedLinkLogo(compact: true),
                    MedNetLiveBadge(isLive: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('02. Color Tokens & Surface Palette'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildColorChip('Primary Slate', AppColors.primarySlate, AppColors.textInverse),
              _buildColorChip('Medical Teal', AppColors.secondaryTeal, AppColors.textInverse),
              _buildColorChip('Critical Red', AppColors.criticalRed, AppColors.textInverse),
              _buildColorChip('Warning Amber', AppColors.warningAmber, AppColors.textInverse),
              _buildColorChip('Info Blue', AppColors.infoBlue, AppColors.textInverse),
              _buildColorChip('Surface White', AppColors.surface, AppColors.textPrimary, hasBorder: true),
              _buildColorChip('Canvas Base', AppColors.background, AppColors.textPrimary, hasBorder: true),
              _buildColorChip('Subtle Grey', AppColors.surfaceSubtle, AppColors.textPrimary, hasBorder: true),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('03. Typography & Tabular Figures'),
          const BedLinkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display Header (28px Bold)', style: AppTypography.display),
                SizedBox(height: 6),
                Text('Screen Title (22px Bold)', style: AppTypography.screenTitle),
                SizedBox(height: 6),
                Text('Section Title (18px Bold)', style: AppTypography.sectionTitle),
                SizedBox(height: 6),
                Text('Card Title (16px Bold)', style: AppTypography.cardTitle),
                SizedBox(height: 6),
                Text('Body Regular (14px Clean)', style: AppTypography.body),
                SizedBox(height: 6),
                Text('OPERATIONAL LABEL (11px UPPERCASE)', style: AppTypography.operationalLabel),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Text('Tabular Metrics (JetBrains Mono):', style: AppTypography.labelStrong),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('02:00 MIN', style: AppTypography.operationalValueLg),
                    Text('14 MIN • 4.2 KM', style: AppTypography.operationalValue),
                    Text('03 BEDS', style: AppTypography.operationalValueSm),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('04. Action Buttons System'),
          Column(
            children: [
              BedLinkButton(
                label: 'Primary Black CTA (52px)',
                icon: Icons.flash_on_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              BedLinkButton(
                label: 'Medical Available Action (Teal)',
                icon: Icons.check_circle_rounded,
                variant: BedLinkButtonVariant.available,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              BedLinkButton(
                label: 'Critical / Divert Action (Red)',
                icon: Icons.warning_rounded,
                variant: BedLinkButtonVariant.critical,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              BedLinkButton(
                label: 'Secondary Outlined Button',
                variant: BedLinkButtonVariant.secondary,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BedLinkButton(
                      label: 'Compact Action',
                      variant: BedLinkButtonVariant.compact,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BedLinkButton(
                      label: _isLoadingButton ? 'Loading...' : 'Toggle Loading',
                      isLoading: _isLoadingButton,
                      onPressed: () {
                        setState(() => _isLoadingButton = !_isLoadingButton);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  BedLinkIconButton(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh Action',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('05. Cards & Clinical Surfaces'),
          const Column(
            children: [
              BedLinkCard(
                variant: BedLinkCardVariant.defaultCard,
                child: Text('Default Surface Card (Crisp 1px Slate Border)', style: AppTypography.body),
              ),
              SizedBox(height: 8),
              BedLinkCard(
                variant: BedLinkCardVariant.recommended,
                child: Text('Recommended Match Card (2px Medical Teal Border)', style: AppTypography.body),
              ),
              SizedBox(height: 8),
              BedLinkCard(
                variant: BedLinkCardVariant.critical,
                child: Text('Critical Divert Alert Card (4px Left Red Accent)', style: AppTypography.body),
              ),
              SizedBox(height: 8),
              BedLinkCard(
                variant: BedLinkCardVariant.warning,
                child: Text('Warning / Surge Alert Card (4px Left Amber Accent)', style: AppTypography.body),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: BedLinkMetricCard(
                      label: 'Road ETA',
                      value: '12',
                      unit: 'MIN',
                      icon: Icons.navigation_rounded,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: BedLinkMetricCard(
                      label: 'ICU Vacancy',
                      value: '04',
                      unit: 'BEDS',
                      valueColor: AppColors.secondaryTeal,
                      icon: Icons.hotel_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('06. Status Badges & Telemetry Chips'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FreshnessBadge.fromMinutes(2),
              FreshnessBadge.fromMinutes(12),
              FreshnessBadge.fromMinutes(35),
              HospitalLoadBadge.fromOccupancy(0.65),
              HospitalLoadBadge.fromOccupancy(0.95),
              const EmergencyUrgencyBadge(acuity: EmergencyAcuity.critical),
              const EmergencyUrgencyBadge(acuity: EmergencyAcuity.urgent),
              AvailabilityBadge.fromCount(4),
              AvailabilityBadge.fromCount(0),
              const ConnectivityBadge(state: ConnectivityState.live),
              const ReservationStatusBadge(status: ReservationStatus.locked),
              const ReservationStatusBadge(status: ReservationStatus.accepted),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('07. Rapid Inventory Counter & Form Controls'),
          BedLinkCounterControl(
            label: 'ICU Bed Availability (Tap +/- to adjust):',
            value: _counterValue,
            onChanged: (val) => setState(() => _counterValue = val),
          ),
          const SizedBox(height: 16),
          const BedLinkSearchField(),
          const SizedBox(height: 16),
          const BedLinkTextField(
            label: 'Patient Triage ID / Notes',
            hint: 'e.g. STEMI Protocol, O2 Sat 88%',
            prefixIcon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 16),
          BedLinkSegmentedSelector<int>(
            label: 'Gender Selection:',
            options: const [
              BedLinkSegmentOption(value: 0, label: 'Male', icon: Icons.male_rounded),
              BedLinkSegmentOption(value: 1, label: 'Female', icon: Icons.female_rounded),
              BedLinkSegmentOption(value: 2, label: 'Unknown', icon: Icons.person_outline_rounded),
            ],
            selectedValue: _segmentedIndex,
            onChanged: (idx) => setState(() => _segmentedIndex = idx),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('08. Option Cards & Clinical Requirement Chips'),
          BedLinkOptionCard(
            title: 'Critical • Tier 1',
            subtitle: 'Immediate life-threat (Cardiac arrest, Severe trauma, Shock)',
            isSelected: _selectedUrgency == 'critical',
            accentColor: AppColors.criticalRed,
            icon: Icons.emergency_rounded,
            onTap: () => setState(() => _selectedUrgency = 'critical'),
          ),
          const SizedBox(height: 8),
          BedLinkOptionCard(
            title: 'Urgent • Tier 2',
            subtitle: 'Potentially unstable, expedited bed needed (Chest pain, Stroke)',
            isSelected: _selectedUrgency == 'urgent',
            accentColor: AppColors.warningAmber,
            icon: Icons.warning_amber_rounded,
            onTap: () => setState(() => _selectedUrgency = 'urgent'),
          ),
          const SizedBox(height: 16),
          const Text('Active Clinical Requirements:', style: AppTypography.labelStrong),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BedLinkRequirementChip(
                label: 'ICU Bed',
                quantity: 1,
                onRemove: () {},
              ),
              BedLinkRequirementChip(
                label: 'Mechanical Ventilator',
                quantity: 1,
                onRemove: () {},
              ),
              BedLinkRequirementChip(
                label: 'Cardiac Cath Lab',
                isCountable: false,
                onRemove: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Quick Add Presets:', style: AppTypography.labelStrong),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BedLinkQuickAddChip(
                label: 'Oxygen Bed',
                isAdded: _addedResources.contains('Oxygen Bed'),
                onTap: () {
                  setState(() {
                    if (_addedResources.contains('Oxygen Bed')) {
                      _addedResources.remove('Oxygen Bed');
                    } else {
                      _addedResources.add('Oxygen Bed');
                    }
                  });
                },
              ),
              BedLinkQuickAddChip(
                label: 'Pediatric ICU',
                isAdded: _addedResources.contains('Pediatric ICU'),
                onTap: () {
                  setState(() {
                    if (_addedResources.contains('Pediatric ICU')) {
                      _addedResources.remove('Pediatric ICU');
                    } else {
                      _addedResources.add('Pediatric ICU');
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const BedLinkValidationMessage(
            message: 'Mandatory Requirement: Select at least 1 countable bed or ventilator.',
            severity: ValidationSeverity.error,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.operationalLabel.copyWith(
          fontSize: 12,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildColorChip(String name, Color color, Color textColor, {bool hasBorder = false}) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: hasBorder ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
