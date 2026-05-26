/// Чистая логика расчёта дозирования флотореагента.
/// Без Flutter-зависимостей — это позволяет легко покрыть её unit-тестами.
library;

/// Входные параметры расчёта.
class ReagentInput {
  /// Граммовка, г/т.
  final double dosageGramsPerTon;

  /// Концентрация реагента как доля: 0.3 = 30%.
  final double concentrationFraction;

  /// Переработка, т/ч.
  final double throughputTonsPerHour;

  const ReagentInput({
    required this.dosageGramsPerTon,
    required this.concentrationFraction,
    required this.throughputTonsPerHour,
  });

  /// Все ли входы валидны для расчёта. Концентрация — строго > 0,
  /// так как стоит в знаменателе формулы (деление на ноль недопустимо).
  /// При нуле/пустом поле UI оставит результат «—».
  bool get isValid =>
      dosageGramsPerTon >= 0 &&
      concentrationFraction > 0 &&
      throughputTonsPerHour >= 0;
}

/// Результат расчёта: вылив в мл/мин.
class ReagentResult {
  /// Вылив, мл/мин.
  final double flowMlPerMin;

  const ReagentResult({required this.flowMlPerMin});

  /// Производные значения для удобства отображения.
  double get flowMlPerHour => flowMlPerMin * 60;
  double get flowLitersPerHour => flowMlPerHour / 1000;
}

/// Основная формула:
///
///   граммовка (г/т) * переработка (т/ч) / концентрация (доля) / 60 (мин) = вылив (мл/мин)
///
/// Концентрация в знаменателе: при разбавленном реагенте (доля < 1) объём
/// рабочего раствора больше массы чистого реагента в соответствующее число
/// раз. Концентрация вводится долей: 0.3 = 30%.
/// Если позже понадобится вводить процентом (30 = 30%) — заменить
/// input.concentrationFraction на (input.concentrationFraction / 100).
ReagentResult calculateFlow(ReagentInput input) {
  final flow = input.dosageGramsPerTon *
      input.throughputTonsPerHour /
      input.concentrationFraction /
      60.0;

  return ReagentResult(flowMlPerMin: flow);
}
