import 'package:flutter/material.dart';

import 'admin_web_design.dart';

class AdminWebTopBar extends StatelessWidget {
  const AdminWebTopBar({
    super.key,
    this.showMenu = false,
    this.actions = const [],
    this.dark = false,
  });

  final bool showMenu;
  final List<Widget> actions;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 13, 20, 13),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF9FAFC),
        border: Border(
          bottom: BorderSide(
            color: dark ? AdminTechColors.panelBorder : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          if (dark) const Expanded(child: _Breadcrumb()),
          if (!dark) const Spacer(),
          if (dark) const _LiveBadge(),
          if (dark) const SizedBox(width: 10),
          ...actions,
        ],
      ),
    );
  }
}

/// Koyu temada sayfa yolu gibi çalışan, sabit "Lineer" imzası.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: AdminTechColors.accentGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        // Dar ekranda ikinci kısım gizlenir; böylece çubuk taşmaz.
        const Flexible(
          child: Text(
            'LINEER  /  OPERASYON PANELI',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AdminTechColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Sağ üstte sürekli akan durum göstergesi.
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
      decoration: BoxDecoration(
        color: AdminTechColors.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AdminTechColors.green.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdminTechPulseDot(color: AdminTechColors.green, size: 6),
          const SizedBox(width: 2),
          Text(
            'CANLI',
            style: adminTechLabelStyle(
              size: 10,
              weight: FontWeight.w800,
              color: AdminTechColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminWebActionButton extends StatelessWidget {
  const AdminWebActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (dark) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: AdminTechColors.cyan),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AdminTechColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminTechColors.textPrimary,
          side: const BorderSide(color: AdminTechColors.panelBorder),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white.withValues(alpha: 0.04),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminTechColors.textPrimary,
        side: const BorderSide(color: AdminTechColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AdminTechColors.surface,
      ),
    );
  }
}
