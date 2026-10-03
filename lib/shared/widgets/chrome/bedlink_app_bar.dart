import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/supabase_client_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/session_provider.dart';
import '../demo/dev_fixture_center.dart';
import 'bedlink_logo.dart';
import 'med_net_live_badge.dart';

/// Standardized BedLink Application Bar with branding, live status, and responsive header layout.
class BedLinkAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const BedLinkAppBar({
    this.title,
    this.subtitle,
    this.showLiveBadge = true,
    this.showBackButton = true,
    this.leading,
    this.actions,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final bool showLiveBadge;
  final bool showBackButton;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final bool canPop = Navigator.canPop(context) && showBackButton;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 360;

    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 12,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(height: 1, color: AppColors.borderSubtle),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ] else if (canPop) ...[
            InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (title == null) ...[
            const BedLinkLogo(compact: true),
          ] else ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySlate,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 16,
                color: AppColors.secondaryTeal,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (title != null) ...[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title!,
                    style: (isCompact ? AppTypography.cardTitle : AppTypography.sectionTitle).copyWith(
                      fontSize: isCompact ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && !isCompact)
                    Text(
                      subtitle!,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (showLiveBadge && screenWidth >= 360) ...[
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: MedNetLiveBadge(),
          ),
        ],
        if (session.role.isAuthenticated && screenWidth >= 520) ...[
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                session.role.displayName.toUpperCase(),
                style: AppTypography.operationalLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        ...?actions,
        if (ref.watch(supabaseConfigProvider).useMock)
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.secondaryTeal),
            tooltip: 'Dev Fixture Center (Mock Mode Only)',
            onPressed: () => DevFixtureCenter.show(context),
          ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, size: 20, color: AppColors.textSecondary),
          tooltip: 'Sign Out / Switch Role',
          onPressed: () {
            ref.read(sessionProvider.notifier).logout();
            context.go('/login');
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
