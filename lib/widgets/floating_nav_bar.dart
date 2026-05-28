import 'package:flutter/material.dart';
import 'soft_container.dart';

/// Плавающий pill-навигатор: три иконки в одном контейнере soft-UI стиля.
/// Активная иконка подсвечивается primary-цветом, остальные — приглушённо.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<NavItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 0, 64, 18),
      child: SoftContainer(
        radius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              _NavButton(
                icon: items[i].icon,
                active: i == currentIndex,
                onTap: () => onChanged(i),
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  const NavItem(this.icon);
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavButton({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Icon(
          icon,
          color: active ? activeColor : inactiveColor.withValues(alpha: 0.7),
          size: 26,
        ),
      ),
    );
  }
}
