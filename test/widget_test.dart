// Базовый smoke-тест: приложение собирается и отрисовывает три вкладки.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reagent_calculator/main.dart';
import 'package:reagent_calculator/state/app_state.dart';

void main() {
  testWidgets('ReagentApp поднимается и показывает все вкладки', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState(prefs: prefs);

    await tester.pumpWidget(ReagentApp(appState: appState));
    await tester.pumpAndSettle();

    expect(find.text('Калькулятор'), findsWidgets);
    expect(find.text('Справочник'), findsOneWidget);
    expect(find.text('История'), findsOneWidget);
  });
}
