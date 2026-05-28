import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Единая тема приложения в стиле soft UI / neumorphic.
/// Фон off-white, элементы «плавают» с парой мягких теней,
/// акцент — насыщенный индиго-синий из дизайна.

const Color _seed = Color(0xFF4C6EF5);
const Color _softBackground = Color(0xFFF0F2F7);
const Color _softSurface = Color(0xFFF7F9FC);
// Левый край pill-инпута (чуть темнее) — задаёт эффект «вдавленности».
const Color _softInputDark = Color(0xFFD9DEE7);
// Правый край pill-инпута (светлее), почти как фон.
const Color _softInputLight = Color(0xFFEEF0F5);

/// Цвета теней для soft-UI контейнеров. Хранятся в ThemeExtension,
/// чтобы виджеты не хардкодили значения и можно было поддержать
/// тёмную тему отдельным набором.
class SoftColors extends ThemeExtension<SoftColors> {
  final Color background;
  final Color surface;
  final Color inputDark;
  final Color inputLight;
  final Color lightShadow;
  final Color darkShadow;

  const SoftColors({
    required this.background,
    required this.surface,
    required this.inputDark,
    required this.inputLight,
    required this.lightShadow,
    required this.darkShadow,
  });

  static const light = SoftColors(
    background: _softBackground,
    surface: _softSurface,
    inputDark: _softInputDark,
    inputLight: _softInputLight,
    lightShadow: Color(0xFFFFFFFF),
    darkShadow: Color(0xFFB5BCCB),
  );

  @override
  SoftColors copyWith({
    Color? background,
    Color? surface,
    Color? inputDark,
    Color? inputLight,
    Color? lightShadow,
    Color? darkShadow,
  }) =>
      SoftColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        inputDark: inputDark ?? this.inputDark,
        inputLight: inputLight ?? this.inputLight,
        lightShadow: lightShadow ?? this.lightShadow,
        darkShadow: darkShadow ?? this.darkShadow,
      );

  @override
  SoftColors lerp(ThemeExtension<SoftColors>? other, double t) {
    if (other is! SoftColors) return this;
    return SoftColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputDark: Color.lerp(inputDark, other.inputDark, t)!,
      inputLight: Color.lerp(inputLight, other.inputLight, t)!,
      lightShadow: Color.lerp(lightShadow, other.lightShadow, t)!,
      darkShadow: Color.lerp(darkShadow, other.darkShadow, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  const soft = SoftColors.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme.copyWith(surface: soft.background),
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    extensions: const [soft],
    textTheme: textTheme,
    scaffoldBackgroundColor: soft.background,

    // Фон полей задаём вручную через градиент в InputRow,
    // поэтому здесь делаем декорацию максимально прозрачной.
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: const OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
