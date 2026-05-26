import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

/// Общее состояние приложения — единственный источник правды.
/// История расчётов и пользовательский справочник реагентов хранятся в
/// памяти и зеркалятся в SharedPreferences, чтобы переживать перезапуск.
class AppState extends ChangeNotifier {
  /// Ключи в SharedPreferences. Если когда-нибудь поменяется формат —
  /// меняем суффикс версии, старые данные просто будут проигнорированы.
  static const _historyKey = 'history_v1';
  static const _reagentsKey = 'reagents_v1';

  final SharedPreferences _prefs;
  final List<HistoryEntry> _history;
  List<Reagent> _reagents;

  AppState({required SharedPreferences prefs})
      : _prefs = prefs,
        _history = _loadHistory(prefs),
        _reagents = _loadReagents(prefs);

  // --- История ------------------------------------------------------------

  /// История, новые записи сверху.
  List<HistoryEntry> get history => List.unmodifiable(_history);

  void addHistory(HistoryEntry entry) {
    _history.insert(0, entry);
    _persistHistory();
    notifyListeners();
  }

  /// Удаляет одну запись по ссылке. HistoryEntry — immutable и без операции
  /// ==, поэтому удаление работает по identity, что нас устраивает.
  void removeHistoryEntry(HistoryEntry entry) {
    final removed = _history.remove(entry);
    if (!removed) return;
    _persistHistory();
    notifyListeners();
  }

  void clearHistory() {
    if (_history.isEmpty) return;
    _history.clear();
    _persistHistory();
    notifyListeners();
  }

  // --- Реагенты -----------------------------------------------------------

  /// Текущий справочник. При первом запуске берётся из sampleReagents.
  List<Reagent> get reagents => List.unmodifiable(_reagents);

  void addReagent(Reagent r) {
    _reagents.add(r);
    _persistReagents();
    notifyListeners();
  }

  /// Заменяет существующий реагент новым. По identity находим старый
  /// в списке; если его уже нет (race / параллельное удаление) — молча
  /// игнорируем.
  void updateReagent(Reagent old, Reagent updated) {
    final i = _reagents.indexOf(old);
    if (i == -1) return;
    _reagents[i] = updated;
    _persistReagents();
    notifyListeners();
  }

  void deleteReagent(Reagent r) {
    final removed = _reagents.remove(r);
    if (!removed) return;
    _persistReagents();
    notifyListeners();
  }

  /// Возвращает справочник к набору по умолчанию.
  void resetReagents() {
    _reagents = List.from(sampleReagents);
    _persistReagents();
    notifyListeners();
  }

  // --- Персистентность ---------------------------------------------------

  /// Читает историю из SharedPreferences. При повреждённых данных
  /// возвращает пустой список — не валим приложение из-за старого формата.
  static List<HistoryEntry> _loadHistory(SharedPreferences prefs) {
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Читает справочник. При первом запуске или повреждении данных
  /// возвращаем стандартный набор, чтобы у пользователя всегда был
  /// рабочий стартовый список.
  static List<Reagent> _loadReagents(SharedPreferences prefs) {
    final raw = prefs.getString(_reagentsKey);
    if (raw == null || raw.isEmpty) return List.from(sampleReagents);
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Reagent.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List.from(sampleReagents);
    }
  }

  void _persistHistory() {
    final encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    _prefs.setString(_historyKey, encoded);
  }

  void _persistReagents() {
    final encoded = jsonEncode(_reagents.map((e) => e.toJson()).toList());
    _prefs.setString(_reagentsKey, encoded);
  }
}
