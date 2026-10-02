import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'En Route & Navigation',
      subtitle: 'Destination: Confirmed Bed Held',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Turn-by-Turn Route Guidance, Live ETA & Arrival Confirmation (Implemented in Phase 9)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Confirm Arrival at Emergency Department'),
              onPressed: () => context.go('/ambulance'),
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Back to Hold Status'),
              onPressed: () => context.go('/ambulance/hold'),
            ),
          ],
        ),
      ),
    );
  }
}
