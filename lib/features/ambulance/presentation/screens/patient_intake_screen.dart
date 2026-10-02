import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class PatientIntakeScreen extends StatelessWidget {
  const PatientIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Patient Intake',
      subtitle: 'Step 1 of 4 • Patient Information',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Patient Demographics, Urgency & Chief Complaint Form (Implemented in Phase 4)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Proceed to Bed Requirements (/ambulance/requirements)'),
              onPressed: () => context.go('/ambulance/requirements'),
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Back to Dashboard'),
              onPressed: () => context.go('/ambulance'),
            ),
          ],
        ),
      ),
    );
  }
}
