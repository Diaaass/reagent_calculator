import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Строка ввода: иконка-аватар в круге слева, поле в центре, суффикс справа.
/// Поле отображает label мелким текстом сверху (как в дизайне),
/// а введённое значение — крупным внутри pill.
class InputRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  /// Либо иконка из Material, либо путь к SVG-ассету (для капли).
  final IconData? icon;
  final String? svgAsset;

  const InputRow({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    this.icon,
    this.svgAsset,
  }) : assert(icon != null || svgAsset != null,
            'Нужно передать icon или svgAsset');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AvatarIcon(icon: icon, svgAsset: svgAsset, color: primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 2),
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            suffix,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final Color color;

  const _AvatarIcon({this.icon, this.svgAsset, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      alignment: Alignment.center,
      child: svgAsset != null
          ? SvgPicture.asset(
              svgAsset!,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            )
          : Icon(icon, color: color, size: 22),
    );
  }
}
