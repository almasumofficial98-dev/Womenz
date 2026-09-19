import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft Aesthetic Palette
  static const Color background = Color(0xFFF9F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF4F6FB);
  
  // Brand Pastels
  static const Color primaryPink = Color(0xFFFF7B98);
  static const Color softPink = Color(0xFFFFE8ED);
  static const Color lightPink = Color(0xFFFFF0F4);

  static const Color primaryBlue = Color(0xFF6C92F8);
  static const Color softBlue = Color(0xFFEAF0FF);
  static const Color lightBlue = Color(0xFFF2F6FF);

  static const Color primaryPeach = Color(0xFFFF9E6D);
  static const Color softPeach = Color(0xFFFFF1EB);

  static const Color primaryPurple = Color(0xFF9E7BFF);
  static const Color softPurple = Color(0xFFF3EFFF);

  static const Color textPrimary = Color(0xFF222B45);
  static const Color textSecondary = Color(0xFF8F9BB3);
  static const Color textMuted = Color(0xFFC5CEE0);

  // Cycle & Phase Color Aliases
  static const Color primaryViolet = Color(0xFF4A154B);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color softLavender = Color(0xFFF3E8FF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E1B4B);

  static const Color menstrualRed = Color(0xFFEC4899);
  static const Color follicularGreen = Color(0xFF10B981);
  static const Color ovulationTeal = Color(0xFF06B6D4);
  static const Color lutealAmber = Color(0xFFF59E0B);

  static const Color pcodTagBg = Color(0xFFFEF3C7);
  static const Color pcodTagText = Color(0xFF92400E);
  static const Color irregularTagBg = Color(0xFFE0E7FF);
  static const Color irregularTagText = Color(0xFF3730A3);

  // Soft Neumorphic / Glassmorphic Shadow Styles
  static List<BoxShadow> softShadow({Color? shadowColor, double opacity = 0.08, double blur = 20}) {
    return [
      BoxShadow(
        color: (shadowColor ?? const Color(0xFF90A4AE)).withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.9),
        blurRadius: 10,
        spreadRadius: -2,
        offset: const Offset(-4, -4),
      ),
    ];
  }

  static List<BoxShadow> glowingShadow(Color glowColor, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: glowColor.withOpacity(opacity),
        blurRadius: 18,
        spreadRadius: 2,
        offset: const Offset(0, 8),
      ),
    ];
  }

  // Smooth Card Decoration
  static BoxDecoration cardDecoration({
    Color color = Colors.white,
    double radius = 24,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border ?? Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
      boxShadow: shadows ?? softShadow(),
    );
  }

  // Glassmorphic Tile Decoration
  static BoxDecoration glassDecoration({
    required List<Color> gradientColors,
    double radius = 24,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.plusJakartaSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        background: background,
        surface: surface,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
