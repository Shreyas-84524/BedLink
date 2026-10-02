import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'chrome/bedlink_app_bar.dart';

/// Reusable structural scaffold for BedLink screens with consistent BedLinkAppBar and role chrome.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.bottomNavigationBar,
    this.showLiveBadge = true,
    this.showBackButton = true,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showLiveBadge;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BedLinkAppBar(
        title: title,
        subtitle: subtitle,
        showLiveBadge: showLiveBadge,
        showBackButton: showBackButton,
        actions: actions,
      ),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
