import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/models.dart';
import '../domain/reagent_calculation.dart';

/// Главная карточка с результатом. Синий градиент, очень скруглённая,
/// «+» в углу, тайл капель снизу-слева, две вторичные метрики снизу.
class HeroResultCard extends StatelessWidget {
  final ReagentResult? result;

  const HeroResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = result;
    const onColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C6EF5).withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 18),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF4C6EF5).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 220,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5A78F8), Color(0xFF3A5BE8)],
            ),
          ),
        child: Stack(
          children: [
            // Декоративный тайл капель в левом нижнем углу.
            Positioned(
              left: 12,
              bottom: 60,
              child: Opacity(
                opacity: 0.18,
                child: _DropGrid(),
              ),
            ),
            // «+» в правом верхнем углу.
            Positioned(
              top: 18,
              right: 22,
              child: Icon(
                Icons.add_rounded,
                color: onColor.withValues(alpha: 0.6),
                size: 32,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Расход Реагента',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onColor.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      r == null ? '0' : fmtNum(r.flowMlPerMin),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: r == null
                            ? onColor.withValues(alpha: 0.4)
                            : onColor,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        fontSize: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'мл/мин',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onColor.withValues(alpha: 0.85),
                    ),
                  ),
                  const Spacer(),
                  _SecondaryMetrics(result: r),
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

/// Полупрозрачная плашка с двумя метриками внизу карточки.
class _SecondaryMetrics extends StatelessWidget {
  final ReagentResult? result;
  const _SecondaryMetrics({required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              value: r == null ? '—' : fmtNum(r.flowLitersPerHour),
              unit: 'л/ч',
              caption: 'расход в час',
            ),
          ),
          Expanded(
            child: _Metric(
              value: r == null ? '—' : fmtNum(r.flowMlPerHour),
              unit: 'мл/ч',
              caption: 'расход в час',
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String unit;
  final String caption;

  const _Metric({
    required this.value,
    required this.unit,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/drop.svg',
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value $unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Тайл капель 3×2 для декоративного фона. Скромный размер,
/// низкая прозрачность задаётся снаружи через Opacity.
class _DropGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final drop = SvgPicture.asset(
      'assets/icons/drop.svg',
      width: 18,
      height: 18,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (row) {
        return Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (col) {
              return Padding(
                padding: EdgeInsets.only(left: col == 0 ? 0 : 8),
                child: drop,
              );
            }),
          ),
        );
      }),
    );
  }
}
