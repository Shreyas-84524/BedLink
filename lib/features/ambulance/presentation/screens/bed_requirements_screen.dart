import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class BedRequirementsScreen extends StatelessWidget {
  const BedRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bed Need Assessment',
      subtitle: 'Step 2 of 4 • Clinical Requirements',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Mandatory Countable Resources & Clinical Capability Selection (Implemented in Phase 5)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Find Compatible Hospitals (/ambulance/hospitals)'),
              onPressed: () => context.go('/ambulance/hospitals'),
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Back to Intake'),
              onPressed: () => context.go('/ambulance/intake'),
            ),
          ],
        ),
      ),
    );
  }
}
