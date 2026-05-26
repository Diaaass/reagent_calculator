import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/models.dart';
import 'domain/reagent_calculation.dart';
import 'state/app_state.dart';
import 'screens/calculator_screen.dart';
import 'screens/reference_screen.dart';
import 'screens/history_screen.dart';
import 'theme.dart';

Future<void> main() async {
  // Нужно до любого асинхронного вызова, иначе плагины недоступны.
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ReagentApp(appState: AppState(prefs: prefs)));
}

class ReagentApp extends StatelessWidget {
  /// Единственный источник правды для всего приложения.
  final AppState appState;

  const ReagentApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор реагентов',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system, // авто светлая/тёмная под систему
      home: HomeShell(appState: appState),
    );
  }
}

/// Корневой каркас: владеет UI-состоянием формы и нижней навигацией.
/// AppState приходит сверху и переживает rebuild'ы.
class HomeShell extends StatefulWidget {
  final AppState appState;

  const HomeShell({super.key, required this.appState});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _dosageCtrl = TextEditingController();
  final _concentrationCtrl = TextEditingController();
  final _throughputCtrl = TextEditingController();

  int _index = 0;
  ReagentResult? _result;

  /// Какой реагент выбран на калькуляторе. null — пользователь вводит
  /// концентрацию вручную; имя записывается в HistoryEntry.reagentName.
  Reagent? _selectedReagent;

  /// Поднимается на момент программного присвоения концентрации
  /// (выбор реагента из справочника), чтобы листенер не сбрасывал
  /// selectedReagent сразу после установки.
  bool _settingConcentrationProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _dosageCtrl.addListener(_recalculate);
    _throughputCtrl.addListener(_recalculate);
    _concentrationCtrl.addListener(_onConcentrationChanged);
  }

  @override
  void dispose() {
    _dosageCtrl.dispose();
    _concentrationCtrl.dispose();
    _throughputCtrl.dispose();
    super.dispose();
  }

  double? _parse(String raw) {
    if (raw.trim().isEmpty) return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  /// Любое изменение поля концентрации (программное игнорируем) сбрасывает
  /// выбранный реагент — пользователь начал вводить вручную.
  void _onConcentrationChanged() {
    if (!_settingConcentrationProgrammatically && _selectedReagent != null) {
      setState(() => _selectedReagent = null);
    }
    _recalculate();
  }

  void _recalculate() {
    final dosage = _parse(_dosageCtrl.text);
    final concentration = _parse(_concentrationCtrl.text);
    final throughput = _parse(_throughputCtrl.text);

    if (dosage == null || concentration == null || throughput == null) {
      setState(() => _result = null);
      return;
    }

    final input = ReagentInput(
      dosageGramsPerTon: dosage,
      concentrationFraction: concentration,
      throughputTonsPerHour: throughput,
    );
    setState(() => _result = input.isValid ? calculateFlow(input) : null);
  }

  void _reset() {
    _dosageCtrl.clear();
    _concentrationCtrl.clear();
    _throughputCtrl.clear();
    setState(() => _selectedReagent = null);
  }

  void _save() {
    final r = _result;
    if (r == null) return;
    widget.appState.addHistory(HistoryEntry(
      time: DateTime.now(),
      dosage: _parse(_dosageCtrl.text) ?? 0,
      concentration: _parse(_concentrationCtrl.text) ?? 0,
      throughput: _parse(_throughputCtrl.text) ?? 0,
      flowMlPerMin: r.flowMlPerMin,
      reagentName: _selectedReagent?.name,
    ));
  }

  /// Тап по реагенту в справочнике: программно подставляем концентрацию,
  /// запоминаем выбор и уходим на калькулятор.
  void _selectReagent(Reagent r) {
    _settingConcentrationProgrammatically = true;
    _concentrationCtrl.text = fmtNum(r.concentration);
    _settingConcentrationProgrammatically = false;
    setState(() {
      _selectedReagent = r;
      _index = 0;
    });
  }

  void _clearSelectedReagent() {
    setState(() => _selectedReagent = null);
  }

  /// Подсказка под полем концентрации. Если ввод похож на проценты,
  /// мягко подсказываем, не блокируя ввод.
  String _concentrationHelper() {
    final c = _parse(_concentrationCtrl.text);
    if (c != null && c > 1) {
      return 'Похоже на процент. Введите долю: 0.3 = 30%';
    }
    return '0.3 = 30%';
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CalculatorScreen(
        dosageCtrl: _dosageCtrl,
        concentrationCtrl: _concentrationCtrl,
        throughputCtrl: _throughputCtrl,
        result: _result,
        onReset: _reset,
        onSave: _result == null ? null : _save,
        selectedReagent: _selectedReagent,
        onClearReagent: _clearSelectedReagent,
        concentrationHelper: _concentrationHelper(),
      ),
      ReferenceScreen(
        appState: widget.appState,
        onSelect: _selectReagent,
      ),
      HistoryScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Справочник',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'История',
          ),
        ],
      ),
    );
  }
}
