import 'package:flutter/material.dart';

class CeylonThemePreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const CeylonThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });
}

class AppTheme {
  static const List<CeylonThemePreset> presets = [
    CeylonThemePreset(
      id: 'emerald',
      name: 'Royal Emerald',
      primaryColor: Color(0xFF0F5132),
      secondaryColor: Color(0xFF059669),
      accentColor: Color(0xFF10B981),
    ),
    CeylonThemePreset(
      id: 'sapphire',
      name: 'Sapphire Coast',
      primaryColor: Color(0xFF0D3B66),
      secondaryColor: Color(0xFF2563EB),
      accentColor: Color(0xFF38BDF8),
    ),
    CeylonThemePreset(
      id: 'cinnamon',
      name: 'Ceylon Cinnamon',
      primaryColor: Color(0xFF7B3F00),
      secondaryColor: Color(0xFFD97706),
      accentColor: Color(0xFFF59E0B),
    ),
    CeylonThemePreset(
      id: 'tea',
      name: 'Nuwara Eliya Tea',
      primaryColor: Color(0xFF1E3A1E),
      secondaryColor: Color(0xFF15803D),
      accentColor: Color(0xFF4ADE80),
    ),
    CeylonThemePreset(
      id: 'ochre',
      name: 'Sigiriya Ochre',
      primaryColor: Color(0xFFA0522D),
      secondaryColor: Color(0xFFEA580C),
      accentColor: Color(0xFFFB923C),
    ),
    CeylonThemePreset(
      id: 'lotus',
      name: 'Lotus Sunset',
      primaryColor: Color(0xFF831843),
      secondaryColor: Color(0xFFDB2777),
      accentColor: Color(0xFFF472B6),
    ),
    CeylonThemePreset(
      id: 'kandy_gold',
      name: 'Kandy Gold',
      primaryColor: Color(0xFF854D0E),
      secondaryColor: Color(0xFFCA8A04),
      accentColor: Color(0xFFFACC15),
    ),
    CeylonThemePreset(
      id: 'ocean_reef',
      name: 'Ocean Reef',
      primaryColor: Color(0xFF115E59),
      secondaryColor: Color(0xFF0D9488),
      accentColor: Color(0xFF2DD4BF),
    ),
  ];

  static CeylonThemePreset activePreset = presets[0]; // Default Royal Emerald
  static Color customPrimaryColor = const Color(0xFF0F5132);
  static bool isDarkMode = false;

  static ThemeData get lightTheme {
    final primary = customPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: activePreset.secondaryColor,
        tertiary: activePreset.accentColor,
        surface: Colors.white,
        onSurface: const Color(0xFF0F172A),
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withAlpha(217),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final primary = customPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF090D16),
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: activePreset.secondaryColor,
        tertiary: activePreset.accentColor,
        surface: const Color(0xFF111827),
        onSurface: const Color(0xFFF9FAFB),
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF090D16),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF131D2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(20), width: 1),
        ),
      ),
    );
  }

  static void setPreset(String id) {
    final found = presets.firstWhere((p) => p.id == id, orElse: () => presets[0]);
    activePreset = found;
    customPrimaryColor = found.primaryColor;
  }

  static void setCustomColor(Color color) {
    customPrimaryColor = color;
  }
}
