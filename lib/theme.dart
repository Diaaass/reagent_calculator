import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Единая тема приложения в стиле soft UI / neumorphic.
/// Фон off-white, элементы «плавают» с парой мягких теней,
/// акцент — насыщенный индиго-синий из дизайна.

const Color _seed = Color(0xFF3D5BF6);
const Color _softBackground = Color(0xFFEDEFF3);
const Color _softSurface = Color(0xFFF4F6FA);
const Color _softInputFill = Color(0xFFE6E9EF);

/// Цвета теней для soft-UI контейнеров. Хранятся в ThemeExtension,
/// чтобы виджеты не хардкодили значения и можно было поддержать
/// тёмную тему отдельным набором.
class SoftColors extends ThemeExtension<SoftColors> {
  final Color background;
  final Color surface;
  final Color inputFill;
  final Color lightShadow;
  final Color darkShadow;

  const SoftColors({
    required this.background,
    required this.surface,
    required this.inputFill,
    required this.lightShadow,
    required this.darkShadow,
  });

  static const light = SoftColors(
    background: _softBackground,
    surface: _softSurface,
    inputFill: _softInputFill,
    lightShadow: Color(0xFFFFFFFF),
    darkShadow: Color(0xFFBEC4D0),
  );

  static const dark = SoftColors(
    background: Color(0xFF1B1E27),
    surface: Color(0xFF222632),
    inputFill: Color(0xFF1B1E27),
    lightShadow: Color(0xFF2C3142),
    darkShadow: Color(0xFF11131A),
  );

  @override
  SoftColors copyWith({
    Color? background,
    Color? surface,
    Color? inputFill,
    Color? lightShadow,
    Color? darkShadow,
  }) =>
      SoftColors(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        inputFill: inputFill ?? this.inputFill,
        lightShadow: lightShadow ?? this.lightShadow,
        darkShadow: darkShadow ?? this.darkShadow,
      );

  @override
  SoftColors lerp(ThemeExtension<SoftColors>? other, double t) {
    if (other is! SoftColors) return this;
    return SoftColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      lightShadow: Color.lerp(lightShadow, other.lightShadow, t)!,
      darkShadow: Color.lerp(darkShadow, other.darkShadow, t)!,
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final soft = brightness == Brightness.dark ? SoftColors.dark : SoftColors.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme.copyWith(surface: soft.background),
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    extensions: [soft],
    textTheme: textTheme,
    scaffoldBackgroundColor: soft.background,

    // Pill-инпуты без видимой рамки. Заливка чуть темнее фона, чтобы
    // поле «утопало» в подложке (inset neumorphic-эффект).
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: soft.inputFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
