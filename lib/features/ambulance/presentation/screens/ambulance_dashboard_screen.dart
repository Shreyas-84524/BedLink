import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class AmbulanceDashboardScreen extends StatelessWidget {
  const AmbulanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ambulance Dashboard',
      subtitle: 'Active Unit: Unit 101 • Standby',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Dispatch Ready',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No active emergency transfer in progress. Initiate patient intake when responding to a call.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Start Patient Intake (/ambulance/intake)'),
            onPressed: () => context.go('/ambulance/intake'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            child: const Text('Direct to Requirements (/ambulance/requirements)'),
            onPressed: () => context.go('/ambulance/requirements'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            child: const Text('Direct to Hospital Discovery (/ambulance/hospitals)'),
            onPressed: () => context.go('/ambulance/hospitals'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            child: const Text('Direct to Hold Confirmation (/ambulance/hold)'),
            onPressed: () => context.go('/ambulance/hold'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            child: const Text('Direct to Navigation (/ambulance/navigation)'),
            onPressed: () => context.go('/ambulance/navigation'),
          ),
        ],
      ),
    );
  }
}
