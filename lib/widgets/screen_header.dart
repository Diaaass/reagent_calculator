import 'package:flutter/material.dart';

/// Кастомный заголовок экрана: крупный title, мягкая подпись и
/// опциональные действия справа (по умолчанию — иконка колокольчика).
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Если передано — отображается вместо стандартного колокольчика.
  /// Каждый виджет обычно `IconButton` или их группа.
  final List<Widget>? actions;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActions = actions ??
        [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
        ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...effectiveActions,
        ],
      ),
    );
  }
}
