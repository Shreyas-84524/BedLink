import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Clinical urgency / ESI triage tier for patient allocation.
enum ClinicalUrgency {
  routine(
    label: 'ROUTINE',
    levelTitle: 'Level 3 • Stable / Non-Urgent',
    description: 'Vital signs stable, no acute life or limb threat.',
    color: AppColors.secondaryTeal,
    backgroundColor: Color(0xFFCCFBF1),
    borderColor: AppColors.secondaryTeal,
  ),
  urgent(
    label: 'URGENT',
    levelTitle: 'Level 2 • High Acuity / Emergent',
    description: 'Potential for rapid deterioration or severe pain.',
    color: AppColors.warningAmber,
    backgroundColor: Color(0xFFFEF3C7),
    borderColor: AppColors.warningAmber,
  ),
  critical(
    label: 'CRITICAL',
    levelTitle: 'Level 1 • Immediate Resuscitation',
    description: 'Imminent life threat, unstable airway, shock, or severe trauma.',
    color: AppColors.criticalRed,
    backgroundColor: Color(0xFFFEE2E2),
    borderColor: AppColors.criticalRed,
  );

  const ClinicalUrgency({
    required this.label,
    required this.levelTitle,
    required this.description,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final String levelTitle;
  final String description;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  bool get isCritical => this == ClinicalUrgency.critical;
  bool get isUrgent => this == ClinicalUrgency.urgent;
  bool get isRoutine => this == ClinicalUrgency.routine;
}
