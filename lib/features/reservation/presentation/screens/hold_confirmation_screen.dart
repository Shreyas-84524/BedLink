import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HoldConfirmationScreen extends StatelessWidget {
  const HoldConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Hold Confirmation',
      subtitle: 'Step 4 of 4 • 2-Minute Server Hold',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: 120s Circular Countdown, Target Destination & Fallback Progress (Implemented in Phase 7)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Confirm & Start Navigation (/ambulance/navigation)'),
              onPressed: () => context.go('/ambulance/navigation'),
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Back to Hospital Matches'),
              onPressed: () => context.go('/ambulance/hospitals'),
            ),
          ],
        ),
      ),
    );
  }
}
