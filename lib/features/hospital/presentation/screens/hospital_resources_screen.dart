import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HospitalResourcesScreen extends StatelessWidget {
  const HospitalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Resource Inventory',
      subtitle: 'Fast 10s Availability Controls & Freshness',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: 6 Countable Resource Counters (+/-), "Confirm No Change" & Freshness Timestamps (Implemented in Phase 8)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Back to Hospital Dashboard'),
              onPressed: () => context.go('/hospital'),
            ),
          ],
        ),
      ),
    );
  }
}
