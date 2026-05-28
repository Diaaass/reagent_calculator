import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/models.dart';
import '../domain/reagent_calculation.dart';
import '../widgets/actions_row.dart';
import '../widgets/hero_result_card.dart';
import '../widgets/input_row.dart';
import '../widgets/screen_header.dart';

/// Экран калькулятора в soft-UI стиле. Поля ввода и пересчёт живут в
/// HomeShell, сюда передаются готовые контроллеры и результат —
/// экран только отображает и пробрасывает действия.
class CalculatorScreen extends StatelessWidget {
  final TextEditingController dosageCtrl;
  final TextEditingController concentrationCtrl;
  final TextEditingController throughputCtrl;
  final ReagentResult? result;

  /// null — сохранять нечего (результат не посчитан), действия неактивны.
  final VoidCallback? onSave;

  const CalculatorScreen({
    super.key,
    required this.dosageCtrl,
    required this.concentrationCtrl,
    required this.throughputCtrl,
    required this.result,
    required this.onSave,
  });

  String _resultText() {
    final r = result;
    if (r == null) return 'Расчёт не выполнен';
    return 'Расход реагента: ${fmtNum(r.flowMlPerMin)} мл/мин '
        '(${fmtNum(r.flowLitersPerHour)} л/ч, ${fmtNum(r.flowMlPerHour)} мл/ч)';
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _resultText()));
    _showSnack(context, 'Скопировано в буфер');
  }

  void _share() {
    Share.share(_resultText());
  }

  void _save(BuildContext context) {
    onSave?.call();
    _showSnack(context, 'Расчёт сохранён в историю');
  }

  void _calculate(BuildContext context) {
    // Расчёт идёт автоматически по listener'ам в HomeShell — кнопка
    // даёт тактильный отклик и при готовом результате сохраняет в историю.
    HapticFeedback.mediumImpact();
    if (result != null) _save(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResult = result != null;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenHeader(
              title: 'Калькулятор',
              subtitle: 'Расчет расхода реагентов',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HeroResultCard(result: result),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Исходные данные',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  InputRow(
                    controller: dosageCtrl,
                    label: 'Граммовка',
                    suffix: 'г/т',
                    svgAsset: 'assets/icons/folder_minus.svg',
                  ),
                  const SizedBox(height: 14),
                  InputRow(
                    controller: concentrationCtrl,
                    label: 'Концентрация',
                    suffix: 'дол.',
                    svgAsset: 'assets/icons/drop.svg',
                  ),
                  const SizedBox(height: 14),
                  InputRow(
                    controller: throughputCtrl,
                    label: 'Переработка',
                    suffix: 'т/ч',
                    icon: Icons.local_shipping_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4C6EF5).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () => _calculate(context),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.calculate_outlined, size: 22),
                    label: const Text(
                      'Рассчитать',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ActionsRow(
              onCopy: hasResult ? () => _copy(context) : null,
              onShare: hasResult ? _share : null,
              onSave: hasResult ? () => _save(context) : null,
            ),
          ],
        ),
      ),
    );
  }
}
