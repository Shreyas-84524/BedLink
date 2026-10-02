import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HospitalDiscoveryScreen extends StatelessWidget {
  const HospitalDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Hospital Match Grid',
      subtitle: 'Step 3 of 4 • Ranked Candidates',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Ranked Compatible Hospitals & Match Grid (Implemented in Phase 6)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Request 2-Min Hold (/ambulance/hold)'),
              onPressed: () => context.go('/ambulance/hold'),
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Back to Requirements'),
              onPressed: () => context.go('/ambulance/requirements'),
            ),
          ],
        ),
      ),
    );
  }
}
