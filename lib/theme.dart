import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Единая тема приложения в стиле soft UI / neumorphic.
/// Фон off-white, элементы «плавают» с парой мягких теней,
/// акцент — насыщенный индиго-синий из дизайна.

/// Точный синий из дизайна. Используется как primary везде, где нужен
/// акцент: кнопка, hero-карточка, активная иконка, рамки аватаров.
/// Material 3 без override превращает seed в десатурированный тон,
/// поэтому ColorScheme.fromSeed мы доводим вручную через copyWith.
const Color appPrimary = Color(0xFF4C6EF5);
const Color appPrimaryDark = Color(0xFF3A5BE8);

const Color _softBackground = Color(0xFFF0F2F7);
const Color _softSurface = Color(0xFFF7F9FC);
const Color _softInputDark = Color(0xFFD9DEE7);
const Color _softInputLight = Color(0xFFEEF0F5);

/// Цвета теней для soft-UI контейнеров. Хранятся в ThemeExtension,
/// чтобы виджеты не хардкодили значения.
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
  final scheme = ColorScheme.fromSeed(
    seedColor: appPrimary,
    brightness: brightness,
  ).copyWith(
    // Override, чтобы primary совпадал с синим из дизайна, а не с
    // десатурированным тоном из тональной палитры Material 3.
    primary: appPrimary,
    onPrimary: Colors.white,
  );
  const soft = SoftColors.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme.copyWith(surface: soft.background),
  );

  // Manrope — самый близкий аналог SF Pro из доступных Google Fonts:
  // современная геометрия, мягкие изгибы, хорошо смотрится на iOS-стиле.
  final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
    bodyColor: const Color(0xFF1F2330),
    displayColor: const Color(0xFF1F2330),
  );

  return base.copyWith(
    extensions: const [soft],
    textTheme: textTheme.copyWith(
      headlineSmall: textTheme.headlineSmall?.copyWith(
        letterSpacing: -0.5,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        letterSpacing: -0.3,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        letterSpacing: -0.2,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: -0.1),
    ),
    scaffoldBackgroundColor: soft.background,

    // Фон полей задаём вручную через градиент в InputRow,
    // поэтому здесь делаем декорацию максимально прозрачной.
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
