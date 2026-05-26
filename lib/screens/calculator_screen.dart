import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/models.dart';
import '../domain/reagent_calculation.dart';

/// Экран калькулятора. Поля ввода и логика подсчёта живут в HomeShell,
/// сюда передаются готовые контроллеры и результат — экран только отображает.
class CalculatorScreen extends StatelessWidget {
  final TextEditingController dosageCtrl;
  final TextEditingController concentrationCtrl;
  final TextEditingController throughputCtrl;
  final ReagentResult? result;
  final VoidCallback onReset;

  /// null — сохранять нечего (результат не посчитан), кнопка неактивна.
  final VoidCallback? onSave;

  /// Выбранный из справочника реагент. Если есть — над полем концентрации
  /// показывается чип с именем и крестиком для сброса.
  final Reagent? selectedReagent;
  final VoidCallback onClearReagent;

  /// Подсказка под полем концентрации. Меняется снаружи: при значении > 1
  /// показывается мягкое «похоже на процент».
  final String concentrationHelper;

  const CalculatorScreen({
    super.key,
    required this.dosageCtrl,
    required this.concentrationCtrl,
    required this.throughputCtrl,
    required this.result,
    required this.onReset,
    required this.onSave,
    required this.selectedReagent,
    required this.onClearReagent,
    required this.concentrationHelper,
  });

  void _save(BuildContext context) {
    onSave?.call();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(content: Text('Расчёт сохранён в историю')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        actions: [
          IconButton(
            tooltip: 'Сбросить',
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NumberField(
              controller: dosageCtrl,
              label: 'Граммовка',
              suffix: 'г/т',
            ),
            const SizedBox(height: 12),
            if (selectedReagent != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: const Icon(Icons.science_outlined, size: 18),
                  label: Text(selectedReagent!.name),
                  onDeleted: onClearReagent,
                ),
              ),
              const SizedBox(height: 8),
            ],
            _NumberField(
              controller: concentrationCtrl,
              label: 'Концентрация реагента',
              suffix: 'доля',
              helper: concentrationHelper,
            ),
            const SizedBox(height: 12),
            _NumberField(
              controller: throughputCtrl,
              label: 'Переработка',
              suffix: 'т/ч',
            ),
            const SizedBox(height: 24),
            _ResultCard(result: result),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSave == null ? null : () => _save(context),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Сохранить расчёт',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? helper;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    // Заполненный скруглённый стиль приходит из inputDecorationTheme в theme.dart.
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        helperText: helper,
      ),
    );
  }
}

/// Главная плашка с результатом расчёта.
/// Градиент primary → затемнённый primary, мягкая цветная тень, крупное
/// число с авто-уменьшением через FittedBox и блок вторичных метрик внизу.
class _ResultCard extends StatelessWidget {
  final ReagentResult? result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final r = result;
    final onColor = scheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            // Затемнённый primary даёт глубину, не уходя в чёрный.
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.28),
              scheme.primary,
            ),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, color: onColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'ВЫЛИВ',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onColor.withValues(alpha: 0.85),
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // FittedBox защищает от переполнения, если число станет очень большим.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  r == null ? '—' : fmtNum(r.flowMlPerMin),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: onColor,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'мл/мин',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (r != null) ...[
            const SizedBox(height: 20),
            _SecondaryMetrics(
              litersPerHour: r.flowLitersPerHour,
              mlPerHour: r.flowMlPerHour,
              onColor: onColor,
            ),
          ],
        ],
      ),
    );
  }
}

/// Полупрозрачная плашка под основным числом с двумя метриками
/// и тонким разделителем между ними.
class _SecondaryMetrics extends StatelessWidget {
  final double litersPerHour;
  final double mlPerHour;
  final Color onColor;

  const _SecondaryMetrics({
    required this.litersPerHour,
    required this.mlPerHour,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: onColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricCell(
              value: fmtNum(litersPerHour),
              unit: 'л/ч',
              onColor: onColor,
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: onColor.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _MetricCell(
              value: fmtNum(mlPerHour),
              unit: 'мл/ч',
              onColor: onColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String value;
  final String unit;
  final Color onColor;

  const _MetricCell({
    required this.value,
    required this.unit,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: onColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: theme.textTheme.bodySmall?.copyWith(
            color: onColor.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
