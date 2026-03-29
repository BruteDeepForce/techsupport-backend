import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SaaS Design System — Light, Clean, Professional
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const bg = Color(0xFFF8FAFC); // Slate 50
  static const bgSurface = Color(0xFFFFFFFF);
  static const bgElevated = Color(0xFFFFFFFF);
  static const bgHover = Color(0xFFF1F5F9); // Slate 100

  // ── Borders ───────────────────────────────────────────────────────────────
  static const border = Color(0xFFE2E8F0); // Slate 200
  static const borderSubtle = Color(0xFFF1F5F9); // Slate 100

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0F172A); // Slate 900
  static const textSecondary = Color(0xFF475569); // Slate 600
  static const textTertiary = Color(0xFF94A3B8); // Slate 400

  // ── Accent — SaaS Indigo ────────────────────────────────────────────────
  static const accent = Color(0xFF4F46E5); // Indigo 600
  static const accentMuted = Color(0xFF818CF8); // Indigo 400
  static const accentBg = Color(0xFFEEF2FF); // Indigo 50

  // ── Status (vibrant, clear — SaaS style) ────────────────────────────
  static const statusBlue = Color(0xFF3B82F6); // Blue 500
  static const statusGreen = Color(0xFF10B981); // Emerald 500
  static const statusYellow = Color(0xFFF59E0B); // Amber 500
  static const statusOrange = Color(0xFFF97316); // Orange 500
  static const statusRed = Color(0xFFEF4444); // Red 500
  static const statusPurple = Color(0xFF8B5CF6); // Violet 500
  static const statusGray = Color(0xFF64748B); // Slate 500

  // ── Status backgrounds ────────────────────────────────────────────────────
  static const statusBlueBg = Color(0xFFDBEAFE); // Blue 100
  static const statusGreenBg = Color(0xFFD1FAE5); // Emerald 100
  static const statusYellowBg = Color(0xFFFEF3C7); // Amber 100
  static const statusOrangeBg = Color(0xFFFFEDD5); // Orange 100
  static const statusRedBg = Color(0xFFFEE2E2); // Red 100
  static const statusPurpleBg = Color(0xFFEDE9FE); // Violet 100
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const base = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

class AppRadius {
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 10.0;
  static const xl = 12.0;
  static const full = 99.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Linear Card — dark surface with subtle border
// ─────────────────────────────────────────────────────────────────────────────

class LinearCard extends StatelessWidget {
  const LinearCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge — compact, muted pill
// ─────────────────────────────────────────────────────────────────────────────

class LinearBadge extends StatelessWidget {
  const LinearBadge({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
  });

  final String label;
  final Color color;
  final Color? bgColor;

  Color get _bg {
    if (bgColor != null) return bgColor!;
    if (color == AppColors.statusGreen) return AppColors.statusGreenBg;
    if (color == AppColors.statusYellow) return AppColors.statusYellowBg;
    if (color == AppColors.statusOrange) return AppColors.statusOrangeBg;
    if (color == AppColors.statusRed) return AppColors.statusRedBg;
    if (color == AppColors.statusBlue) return AppColors.statusBlueBg;
    if (color == AppColors.statusPurple) return AppColors.statusPurpleBg;
    return AppColors.bgElevated;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority Icon — Linear's colored circle/diamond indicators
// ─────────────────────────────────────────────────────────────────────────────

class LinearPriority extends StatelessWidget {
  const LinearPriority({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header — ultra-minimal label
// ─────────────────────────────────────────────────────────────────────────────

class LinearSection extends StatelessWidget {
  const LinearSection({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Issue Row — Linear's signature compact list item
// ─────────────────────────────────────────────────────────────────────────────

class LinearIssueRow extends StatelessWidget {
  const LinearIssueRow({
    super.key,
    required this.id,
    required this.title,
    this.priority,
    this.statusColor,
    this.label,
    this.labelColor,
    this.assignee,
    this.onTap,
    this.showDivider = true,
  });

  final String id;
  final String title;
  final Color? priority;
  final Color? statusColor;
  final String? label;
  final Color? labelColor;
  final String? assignee;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5))
              : null,
        ),
        child: Row(
          children: [
            if (priority != null) ...[
              LinearPriority(color: priority!),
              const SizedBox(width: 10),
            ],
            if (statusColor != null) ...[
              _StatusCircle(color: statusColor!),
              const SizedBox(width: 10),
            ],
            Text(
              id,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (label != null && labelColor != null) ...[
              const SizedBox(width: 8),
              LinearBadge(label: label!, color: labelColor!),
            ],
            if (assignee != null) ...[
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  assignee!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Pill — compact metric display
// ─────────────────────────────────────────────────────────────────────────────

class LinearStatPill extends StatelessWidget {
  const LinearStatPill({
    super.key,
    required this.value,
    required this.label,
    this.color,
  });

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Sidebar item (used as bottom tab)
// ─────────────────────────────────────────────────────────────────────────────

class LinearTabItem {
  const LinearTabItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.count,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final int? count;
  final VoidCallback? onTap;
}

class LinearTabBar extends StatelessWidget {
  const LinearTabBar({
    super.key,
    required this.items,
  });

  final List<LinearTabItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(
            top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items.map((item) {
              final color =
                  item.active ? AppColors.accent : AppColors.textTertiary;
              return Expanded(
                child: GestureDetector(
                  onTap: item.onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.icon, color: color, size: 22),
                        if (item.count != null)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${item.count}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight:
                            item.active ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Shell — Linear app frame
// ─────────────────────────────────────────────────────────────────────────────

class LinearPageShell extends StatelessWidget {
  const LinearPageShell({
    super.key,
    required this.title,
    required this.children,
    required this.tabBar,
    this.subtitle,
    this.showBack = false,
    this.trailing,
    this.scrollPhysics,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget tabBar;
  final bool showBack;
  final Widget? trailing;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF1E3A8A); // SaaS Deep Blue / Indigo 900

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: deepBlue,
        body: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24, // Extra padding for overlap effect
              ),
              color: deepBlue,
              child: Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  if (showBack) const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null)
                          const SizedBox(height: 2),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            // ── Content Area ─────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 24),
                    physics: scrollPhysics,
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: tabBar,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Tabs — Linear's segment control
// ─────────────────────────────────────────────────────────────────────────────

class LinearFilterTabs extends StatelessWidget {
  const LinearFilterTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
  });

  final List<String> labels;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.bgElevated : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Command Button — Linear's subtle action button
// ─────────────────────────────────────────────────────────────────────────────

class LinearCommand extends StatelessWidget {
  const LinearCommand({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textTertiary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vercel Background System
// ─────────────────────────────────────────────────────────────────────────────

class VercelBackground extends StatelessWidget {
  const VercelBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: child,
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Linear Brand Logo — minimalist icon with three parallel lines
// ─────────────────────────────────────────────────────────────────────────────

class LinearLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const LinearLogo({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // If a color is provided, we use a ColorFiltered to tint the logo (e.g. for white-only splash)
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
    );
  }
}



