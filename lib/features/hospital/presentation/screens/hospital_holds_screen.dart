import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HospitalHoldsScreen extends StatelessWidget {
  const HospitalHoldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Active Holds & Reservations',
      subtitle: 'Inbound Ambulances & Held Beds',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Active Inbound Ambulances, Held Resource Items & Arrival Handoff (Implemented in Phase 8)',
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
