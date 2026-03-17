import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppColors {
  static const background = Color(0xFFF3F5F9);
  static const surface = Colors.white;
  static const border = Color(0xFFDCE3EE);
  static const divider = Color(0xFFE7EDF5);
  static const textPrimary = Color(0xFF111A2C);
  static const textSecondary = Color(0xFF6C7A96);
  static const brand = Color(0xFF2E63F3);
  static const brandDark = Color(0xFF1E3F8F);
  static const headerTint = Color(0xFFEAF0FF);

  static const success = Color(0xFF24C37D);
  static const warning = Color(0xFFF59E0B);
  static const critical = Color(0xFFEF4444);
  static const info = Color(0xFF60A5FA);
  static const purple = Color(0xFF8B5CF6);

  static const successSoft = Color(0xFFD9F7E8);
  static const warningSoft = Color(0xFFFCE7C2);
  static const criticalSoft = Color(0xFFFCE1DE);
  static const infoSoft = Color(0xFFDCEAFF);
  static const purpleSoft = Color(0xFFF0E4FF);
}

class AppSpacing {
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s28 = 28.0;
  static const s32 = 32.0;
}

class AppRadius {
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 28.0;
}

class AppShadows {
  // Softer, layered card shadow for a more modern / elevated look
  static const card = [
    BoxShadow(
      color: Color(0x1A0E1726), // slightly stronger soft shadow
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0E1726),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(title,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 22)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.initials = 'TS',
    this.trailingText,
  });

  final String title;
  final String subtitle;
  final String initials;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.brandDark,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppShadows.card,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20)),
            ),
            if (trailingText != null)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0F7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  trailingText!,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 10),
        const Divider(height: 1),
      ],
    );
  }
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.height,
    this.minHeight,
    this.alignment,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? minHeight;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    // Use Material to get native elevation and ink behavior. Slightly tighter
    // radius and reduced default padding for a more refined, modern card.
    return Material(
      color: AppColors.surface,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: AppColors.border, width: 0.8),
      ),
      child: Container(
        height: height,
        constraints:
            minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
        alignment: alignment,
        padding: padding,
        child: child,
      ),
    );
  }
}

class AppAccentTopCard extends StatelessWidget {
  const AppAccentTopCard({
    super.key,
    required this.accent,
    required this.child,
    this.minHeight,
    this.contentPadding = const EdgeInsets.all(20),
  });

  final Color accent;
  final Widget child;
  final double? minHeight;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    // compute gradient colors derived from accent to get a brighter/tech look
    final _h = HSLColor.fromColor(accent);
    final _gradStart = _h
        .withSaturation(math.min(1.0, _h.saturation * 1.25))
        .withLightness(math.min(1.0, _h.lightness + 0.06))
        .toColor();
    final _gradEnd = _h
        .withSaturation(math.min(1.0, _h.saturation * 1.05))
        .withLightness(math.min(1.0, _h.lightness + 0.18))
        .toColor();

    return AppSurfaceCard(
      minHeight: minHeight,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradStart, _gradEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xxl),
                topRight: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: const SizedBox(height: 6, width: double.infinity),
          ),
          Padding(
            padding: contentPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class AppTechStatCard extends StatelessWidget {
  const AppTechStatCard({
    super.key,
    required this.tint,
    required this.accent,
    required this.icon,
    required this.value,
    required this.label,
    this.showAccentBand = true,
  });

  final Color tint;
  final Color accent;
  final IconData icon;
  final String value;
  final String label;

  // When true (default) show the bright top accent gradient band.
  // Set to false to render a plain card without the band.
  final bool showAccentBand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // compute a slightly brighter gradient for accent to make the top band pop
    final _h = HSLColor.fromColor(accent);
    final _gradStart = _h
        .withSaturation(math.min(1.0, _h.saturation * 1.25))
        .withLightness(math.min(1.0, _h.lightness + 0.06))
        .toColor();
    final _gradEnd = _h
        .withSaturation(math.min(1.0, _h.saturation * 1.05))
        .withLightness(math.min(1.0, _h.lightness + 0.18))
        .toColor();

    // Build a single card where the top gradient band is flush with the
    // card edge (no gap). The inner content has the tint background and the
    // band and content share the same corner radii so they appear as one unit.
    return AppSurfaceCard(
      minHeight: 108,
      alignment: Alignment.topLeft,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top gradient band (slightly thicker for more presence)
              showAccentBand
                  ? Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_gradStart, _gradEnd],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        // no separate borderRadius here; outer ClipRRect will handle clipping
                      ),
                    )
                  : const SizedBox.shrink(),

              // Content area — no extra border so band and content touch directly
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.xl),
                    bottomRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: accent, size: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800, fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary, height: 1.28),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.children,
    required this.bottomNavBar,
  });

  final List<Widget> children;
  final Widget bottomNavBar;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final bottomInset = MediaQuery.of(context).padding.bottom;
      return Scaffold(
        // allow the body to extend behind the bottomNavigationBar so the nav background can overlap
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: ListView(
            // leave space at the bottom equal to the nav height + inset so content doesn't get occluded
            padding: EdgeInsets.fromLTRB(
                14, 12, 14, kBottomNavigationBarHeight + bottomInset),
            children: [
              ...children,
            ],
          ),
        ),
        bottomNavigationBar: Container(
          // ensure the nav background extends into the device safe area
          padding: EdgeInsets.only(bottom: bottomInset),
          color: AppColors.surface,
          child: bottomNavBar,
        ),
      );
    });
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.leadingColor = AppColors.brand,
    this.trailing,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color leadingColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: leadingColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: leadingColor),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AppBottomNavItemData {
  const AppBottomNavItemData({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
  });

  final List<AppBottomNavItemData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: items.map((item) {
          final color = item.active ? AppColors.brand : AppColors.textSecondary;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: color),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: item.active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterSegment extends StatelessWidget {
  const FilterSegment({
    super.key,
    required this.labels,
    required this.selectedIndex,
  });

  final List<String> labels;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected ? AppShadows.card : null,
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
