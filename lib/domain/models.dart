/// Модели данных приложения и вспомогательные функции форматирования.
library;

/// Реагент из справочника.
class Reagent {
  final String name;

  /// Класс реагента (вспениватель, депрессор и т.д.).
  final String category;

  /// Рабочая концентрация как доля: 0.3 = 30%.
  final double concentration;

  const Reagent({
    required this.name,
    required this.category,
    required this.concentration,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'concentration': concentration,
      };

  factory Reagent.fromJson(Map<String, dynamic> json) => Reagent(
        name: json['name'] as String,
        category: json['category'] as String,
        concentration: (json['concentration'] as num).toDouble(),
      );
}

/// Встроенный справочник реагентов.
const List<Reagent> sampleReagents = [
  Reagent(name: 'Бутиловый ксантогенат', category: 'Ксантогенаты', concentration: 0.20),
  Reagent(name: 'Сосновое масло', category: 'Вспениватели', concentration: 0.15),
  Reagent(name: 'Аэрофлот (БМК)', category: 'Дитиофосфаты', concentration: 0.30),
  Reagent(name: 'Т-80', category: 'Вспениватели', concentration: 0.10),
  Reagent(name: 'Сульфид натрия', category: 'Сульфидизаторы', concentration: 0.25),
  Reagent(name: 'Силикат натрия', category: 'Депрессоры', concentration: 0.40),
];

/// Одна запись в истории расчётов.
class HistoryEntry {
  final DateTime time;
  final double dosage; // г/т
  final double concentration; // доля
  final double throughput; // т/ч
  final double flowMlPerMin; // мл/мин

  /// Имя реагента, если расчёт делали по выбранному из справочника.
  /// Может отсутствовать в старых записях — поэтому nullable.
  final String? reagentName;

  const HistoryEntry({
    required this.time,
    required this.dosage,
    required this.concentration,
    required this.throughput,
    required this.flowMlPerMin,
    this.reagentName,
  });

  /// Сериализация в JSON-совместимую Map. Время храним как ISO-8601 строку.
  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'dosage': dosage,
        'concentration': concentration,
        'throughput': throughput,
        'flowMlPerMin': flowMlPerMin,
        'reagentName': reagentName,
      };

  /// Поле reagentName появилось позже — в старых записях его нет,
  /// `json['reagentName']` тогда вернёт null, что нас устраивает.
  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        time: DateTime.parse(json['time'] as String),
        dosage: (json['dosage'] as num).toDouble(),
        concentration: (json['concentration'] as num).toDouble(),
        throughput: (json['throughput'] as num).toDouble(),
        flowMlPerMin: (json['flowMlPerMin'] as num).toDouble(),
        reagentName: json['reagentName'] as String?,
      );
}

/// Форматирует число: целое — без дробной части, иначе 2 знака.
/// Разряды тысяч разделяются пробелом: 27000 -> "27 000".
String fmtNum(double v) {
  final s = (v == v.roundToDouble()) ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  return _groupThousands(s);
}

String _groupThousands(String s) {
  final parts = s.split('.');
  final intPart = parts[0];
  final neg = intPart.startsWith('-');
  final digits = neg ? intPart.substring(1) : intPart;

  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  final grouped = (neg ? '-' : '') + buf.toString();
  return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
}

/// Время в формате ЧЧ:ММ.
String fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

const _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// Заголовок группы по дате: "Сегодня, 24 мая" / "Вчера, 23 мая" / "20 мая".
String dateLabel(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;

  final base = '${t.day} ${_months[t.month - 1]}';
  if (diff == 0) return 'Сегодня, $base';
  if (diff == 1) return 'Вчера, $base';
  return base;
}
