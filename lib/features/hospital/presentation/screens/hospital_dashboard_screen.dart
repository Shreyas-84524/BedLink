import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class HospitalDashboardScreen extends StatelessWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Hospital Dashboard',
      subtitle: 'KEM Hospital • Emergency Triage Desk',
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
                    'Hospital Coordination Center',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage resource availability, review incoming emergency transfer requests, and monitor active bed holds.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Resource Inventory & Freshness (/hospital/resources)'),
            onPressed: () => context.go('/hospital/resources'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Incoming Emergency Offers (/hospital/requests)'),
            onPressed: () => context.go('/hospital/requests'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.bookmark_added_outlined),
            label: const Text('Active Reservations & Holds (/hospital/holds)'),
            onPressed: () => context.go('/hospital/holds'),
          ),
        ],
      ),
    );
  }
}
