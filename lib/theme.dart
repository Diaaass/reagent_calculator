// TODO (оффлайн-шрифт): сейчас Inter тянется через google_fonts по сети.
// На фабрике интернета может не быть — нужно вшить TTF в сборку:
//   1) положить в assets/fonts/: Inter-Regular.ttf, Inter-Medium.ttf,
//      Inter-SemiBold.ttf, Inter-Bold.ttf (скачать с fonts.google.com/specimen/Inter);
//   2) в pubspec.yaml в секции flutter объявить family Inter с этими файлами
//      и весами 400/500/600/700;
//   3) тут заменить GoogleFonts.interTextTheme(base.textTheme) на
//      base.textTheme.apply(fontFamily: 'Inter'), а оба вызова GoogleFonts.inter(...)
//      на TextStyle(fontFamily: 'Inter', ...) с теми же параметрами;
//   4) убрать пакет google_fonts из pubspec.yaml.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Единая современная тема приложения.
/// Подключает шрифт Inter и причёсывает поля, карточки, шапку и навигацию,
/// чтобы интерфейс выглядел законченным, а не «дефолтным».

const Color _seed = Color(0xFF1565C0); // глубокий индустриальный синий

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
  );

  // Inter поверх стандартной типографики Material 3.
  final textTheme = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
    ),

    // Заполненные скруглённые поля без жёсткой рамки — выглядят современнее,
    // и в них приятнее попадать пальцем.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.primary),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      elevation: 3,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
