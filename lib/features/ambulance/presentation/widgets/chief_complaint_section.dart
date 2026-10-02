import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_text_field.dart';
import '../providers/intake_provider.dart';

/// Chief Complaint and Diagnostic / Clinical Notes input section with rapid category tags.
class ChiefComplaintSection extends ConsumerStatefulWidget {
  const ChiefComplaintSection({super.key});

  @override
  ConsumerState<ChiefComplaintSection> createState() =>
      _ChiefComplaintSectionState();
}

class _ChiefComplaintSectionState extends ConsumerState<ChiefComplaintSection> {
  late final TextEditingController _complaintController;
  late final TextEditingController _notesController;

  static const List<String> _quickComplaints = [
    'Acute Chest Pain (Suspected STEMI)',
    'Severe Road Accident / Polytrauma',
    'Severe Respiratory Distress (SpO2 < 88%)',
    'Stroke / Acute Neurological Deficit',
    'Severe Burn Injury (> 20% TBSA)',
    'Pediatric Seizure / Febrile Emergency',
    'Septic Shock / Hypotension',
    'Obstetric Emergency / Active Labor',
  ];

  @override
  void initState() {
    super.initState();
    final intake = ref.read(patientIntakeProvider);
    _complaintController = TextEditingController(text: intake.chiefComplaint);
    _notesController = TextEditingController(text: intake.clinicalNotes);
  }

  @override
  void dispose() {
    _complaintController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intake = ref.watch(patientIntakeProvider);

    // Sync external preset changes to controllers if necessary
    if (intake.chiefComplaint != _complaintController.text &&
        !_complaintController.value.isComposingRangeValid) {
      _complaintController.text = intake.chiefComplaint;
    }
    if (intake.clinicalNotes != _notesController.text &&
        !_notesController.value.isComposingRangeValid) {
      _notesController.text = intake.clinicalNotes;
    }

    return BedLinkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHIEF COMPLAINT & CLINICAL PRESENTATION',
            style: AppTypography.operationalLabel,
          ),
          const SizedBox(height: 10),
          // Quick Complaint Categories Chips
          const Text(
            'RAPID TRIAGE CATEGORY (TAP TO AUTOFILL):',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickComplaints.map((complaint) {
              final isSelected = intake.chiefComplaint == complaint;
              return InkWell(
                onTap: () {
                  _complaintController.text = complaint;
                  ref
                      .read(patientIntakeProvider.notifier)
                      .setChiefComplaint(complaint);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySlate
                        : AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primarySlate
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    complaint,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Chief Complaint Text Field
          BedLinkTextField(
            controller: _complaintController,
            label: 'PRIMARY CHIEF COMPLAINT (REQUIRED)',
            hint: 'e.g. Crushing retrosternal chest pain with diaphoresis',
            prefixIcon: Icons.medical_services_outlined,
            onChanged: (val) {
              ref.read(patientIntakeProvider.notifier).setChiefComplaint(val);
            },
          ),
          const SizedBox(height: 14),
          // Diagnostic / Clinical Notes Multiline Field
          BedLinkTextField(
            controller: _notesController,
            label: 'CLINICAL & DIAGNOSTIC NOTES (OPTIONAL)',
            hint: 'Vitals, GCS, suspected pathologies, IV access established, O2 administered...',
            maxLines: 3,
            onChanged: (val) {
              ref.read(patientIntakeProvider.notifier).setClinicalNotes(val);
            },
          ),
        ],
      ),
    );
  }
}
