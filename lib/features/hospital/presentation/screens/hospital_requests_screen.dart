import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HospitalRequestsScreen extends StatelessWidget {
  const HospitalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Incoming Emergency Requests',
      subtitle: '2-Minute Transfer Offers',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Placeholder: Incoming Transfer Modal, 120s Server Timer & Accept/Reject Controls (Implemented in Phase 8)',
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
