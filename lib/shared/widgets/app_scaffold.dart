import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/session_provider.dart';

/// Reusable structural scaffold for BedLink screens with consistent header and role indicators.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.bottomNavigationBar,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          if (session.role.isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  session.role.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryTeal,
                  ),
                ),
                backgroundColor: AppColors.surfaceSubtle,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: EdgeInsets.zero,
              ),
            ),
          ...?actions,
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            tooltip: 'Logout / Reset',
            onPressed: () {
              ref.read(sessionProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
