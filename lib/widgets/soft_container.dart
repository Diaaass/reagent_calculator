import 'package:flutter/material.dart';
import '../theme.dart';

/// Контейнер в стиле soft UI: парные тени (светлая сверху-слева,
/// тёмная снизу-справа) дают эффект «выдавленного» из фона элемента.
class SoftContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  /// Глубина теней. Под крупные карточки — больше, под мелкие плашки — меньше.
  final double elevation;

  const SoftContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.color,
    this.elevation = 10,
  });

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<SoftColors>()!;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? soft.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: soft.darkShadow.withValues(alpha: 0.55),
            blurRadius: elevation * 1.6,
            offset: Offset(elevation * 0.45, elevation * 0.55),
          ),
          BoxShadow(
            color: soft.lightShadow.withValues(alpha: 0.9),
            blurRadius: elevation * 1.4,
            offset: Offset(-elevation * 0.35, -elevation * 0.4),
          ),
        ],
      ),
      child: child,
    );
  }
}
