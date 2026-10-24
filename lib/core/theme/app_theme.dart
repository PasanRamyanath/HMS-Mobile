import 'package:flutter/material.dart';

/// Web Version Asset Registry (`hms-frontend/public/images` -> `assets/images`)
class WebAssets {
  static const String galleFortHero = 'assets/images/galle-fort-villa-hero.jpg';
  static const String boutiqueCourtyardLogin = 'assets/images/boutique-courtyard-login.jpg';
  static const String roomDeluxeOcean = 'assets/images/room-deluxe-ocean.jpg';
  static const String roomBeachfrontVilla = 'assets/images/room-beachfront-pool-villa.jpg';
  static const String roomHeritageSuite = 'assets/images/room-heritage-master-suite.jpg';
  static const String spaAyurvedaPavilion = 'assets/images/spa-ayurveda-pavilion.jpg';
  static const String dishCrabHoppers = 'assets/images/dish-jaffna-crab-hoppers.jpg';
  static const String dishCuttlefishArrack = 'assets/images/dish-cuttlefish-arrack.jpg';

  static const String roomThumbDeluxe = 'assets/images/rooms/deluxe-ocean.webp';
  static const String roomThumbChalet = 'assets/images/rooms/family-chalet.webp';
  static const String roomThumbStandard = 'assets/images/rooms/standard-double.webp';

  static const String appIcon192 = 'assets/icons/icon-192.png';
  static const String appIcon512 = 'assets/icons/icon-512.png';

  /// Resolves the best matching room photograph for a given room category name.
  static String roomImageForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('villa') || lower.contains('pavillion') || lower.contains('beachfront')) {
      return roomBeachfrontVilla;
    }
    if (lower.contains('suite') || lower.contains('colonial') || lower.contains('heritage')) {
      return roomHeritageSuite;
    }
    if (lower.contains('garden') || lower.contains('superior') || lower.contains('courtyard')) {
      return boutiqueCourtyardLogin;
    }
    return roomDeluxeOcean;
  }

  /// Resolves the best matching dish photograph for a given dish/item name or course.
  static String dishImageForItem(String name, {bool isBeverage = false}) {
    final lower = name.toLowerCase();
    if (isBeverage ||
        lower.contains('arrack') ||
        lower.contains('cuttlefish') ||
        lower.contains('tuna') ||
        lower.contains('cocktail') ||
        lower.contains('coconut') ||
        lower.contains('thambili')) {
      return dishCuttlefishArrack;
    }
    return dishCrabHoppers;
  }
}

/// Curated Ceylon Hospitality Luxury Palette Preset (1:1 parity with `src/lib/themeColor.ts`)
class CeylonThemePreset {
  final String id;
  final String name;
  final String subtitle;
  final String hexCode;
  final String category;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData icon;

  const CeylonThemePreset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.hexCode,
    required this.category,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.icon = Icons.eco_rounded,
  });
}

/// Reactive notifier so any theme mode or brand color update triggers a full UI rebuild.
class ThemeController extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Unified Web-Parity Theme Engine (`apple-hig-theme.css` + `muiTheme.ts` + `themeColor.ts`)
class AppTheme {
  static final ThemeController notifier = ThemeController();

  // Web Version Core Neutral & Surface Tokens (Light Mode - Default)
  static const Color lightCanvas = Color(0xFFF4F7F5); // Warm Alabaster (#F4F7F5)
  static const Color lightSurface = Color(0xFFFFFFFF); // Crisp White (#FFFFFF)
  static const Color lightSubtleSurface = Color(0xFFF8FAFC); // Inner Card (#F8FAFC)
  static const Color lightMutedSurface = Color(0xFFEEF2EF); // Apple Gray 100 (#EEF2EF)
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200 (#E2E8F0)
  static const Color lightBorderStrong = Color(0xFFCBD5E1); // Slate 300 (#CBD5E1)
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900 (#0F172A)
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600 (#475569)
  static const Color lightTextMuted = Color(0xFF64748B); // Slate 500 (#64748B)

  // Web Version Core Neutral & Surface Tokens (Dark Mode - `html.dark`)
  static const Color darkCanvas = Color(0xFF0B1120); // Deep Navy Slate (#0B1120)
  static const Color darkSurface = Color(0xFF111827); // Slate 900 Card (#111827)
  static const Color darkSubtleSurface = Color(0xFF1E293B); // Slate 800 Inner (#1E293B)
  static const Color darkMutedSurface = Color(0xFF263349); // Elevated Slate (#263349)
  static const Color darkBorder = Color(0xFF1E293B); // Dark Border (#1E293B)
  static const Color darkBorderStrong = Color(0xFF334155); // Slate 700 (#334155)
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (#F8FAFC)
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300 (#CBD5E1)
  static const Color darkTextMuted = Color(0xFF94A3B8); // Slate 400 (#94A3B8)

  // Web Version Semantic Status Colors
  static const Color emeraldSuccess = Color(0xFF16A34A);
  static const Color emeraldTextLight = Color(0xFF065F46);
  static const Color emeraldBgLight = Color(0xFFECFDF5);
  static const Color emeraldBorderLight = Color(0xFFA7F3D0);

  static const Color amberWarning = Color(0xFFD97706);
  static const Color amberTextLight = Color(0xFFB45309);
  static const Color amberBgLight = Color(0xFFFFFBEB);
  static const Color amberBorderLight = Color(0xFFFDE68A);

  static const Color roseError = Color(0xFFDC2626);
  static const Color roseTextLight = Color(0xFFB91C1C);
  static const Color roseBgLight = Color(0xFFFEF2F2);
  static const Color roseBorderLight = Color(0xFFFECACA);

  static const Color skyInfo = Color(0xFF0284C7);
  static const Color skyTextLight = Color(0xFF1D4ED8);
  static const Color skyBgLight = Color(0xFFEFF6FF);
  static const Color skyBorderLight = Color(0xFFBFDBFE);

  /// 1:1 Curated Ceylon Luxury Palettes from `hms-frontend/src/lib/themeColor.ts`
  static const List<CeylonThemePreset> presets = [
    CeylonThemePreset(
      id: 'ceylon-emerald',
      name: 'Ceylon Emerald',
      subtitle: 'Botanical rainforest & tea estate luxury',
      hexCode: '#0B6E4F',
      category: 'Botanical',
      primaryColor: Color(0xFF0B6E4F),
      secondaryColor: Color(0xFF0D7450),
      accentColor: Color(0xFF10B981),
      icon: Icons.eco_rounded,
    ),
    CeylonThemePreset(
      id: 'ocean-sapphire',
      name: 'Ocean Sapphire',
      subtitle: 'Galle Fort maritime & southern coastline',
      hexCode: '#0284C7',
      category: 'Coastal',
      primaryColor: Color(0xFF0284C7),
      secondaryColor: Color(0xFF0369A1),
      accentColor: Color(0xFF38BDF8),
      icon: Icons.waves_rounded,
    ),
    CeylonThemePreset(
      id: 'sunset-coral',
      name: 'Sunset Coral',
      subtitle: 'Bentota & Mirissa golden hour warmth',
      hexCode: '#E8772E',
      category: 'Warmth',
      primaryColor: Color(0xFFE8772E),
      secondaryColor: Color(0xFFC2410C),
      accentColor: Color(0xFFFB923C),
      icon: Icons.wb_twilight_rounded,
    ),
    CeylonThemePreset(
      id: 'royal-amethyst',
      name: 'Royal Amethyst',
      subtitle: 'Highland boutique villas & luxury suites',
      hexCode: '#7C3AED',
      category: 'Heritage',
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFF6D28D9),
      accentColor: Color(0xFFA78BFA),
      icon: Icons.diamond_rounded,
    ),
    CeylonThemePreset(
      id: 'kandyan-gold',
      name: 'Kandyan Gold',
      subtitle: 'Kingdom of Kandy heritage brass & amber',
      hexCode: '#D97706',
      category: 'Heritage',
      primaryColor: Color(0xFFD97706),
      secondaryColor: Color(0xFFB45309),
      accentColor: Color(0xFFFBBF24),
      icon: Icons.temple_buddhist_rounded,
    ),
    CeylonThemePreset(
      id: 'obsidian-slate',
      name: 'Obsidian Slate',
      subtitle: 'Minimalist executive monochrome',
      hexCode: '#334155',
      category: 'Executive',
      primaryColor: Color(0xFF334155),
      secondaryColor: Color(0xFF1E293B),
      accentColor: Color(0xFF64748B),
      icon: Icons.business_center_rounded,
    ),
    CeylonThemePreset(
      id: 'cinnamon-ruby',
      name: 'Cinnamon Ruby',
      subtitle: 'Ceylon spice island deep crimson',
      hexCode: '#BE123C',
      category: 'Warmth',
      primaryColor: Color(0xFFBE123C),
      secondaryColor: Color(0xFF9F1239),
      accentColor: Color(0xFFFB7185),
      icon: Icons.local_fire_department_rounded,
    ),
    CeylonThemePreset(
      id: 'palm-leaf',
      name: 'Palm Leaf',
      subtitle: 'Tropical palm grove fresh lime & jade',
      hexCode: '#15803D',
      category: 'Botanical',
      primaryColor: Color(0xFF15803D),
      secondaryColor: Color(0xFF166534),
      accentColor: Color(0xFF22C55E),
      icon: Icons.park_rounded,
    ),
  ];

  static CeylonThemePreset activePreset = presets[0]; // Default Ceylon Botanical Emerald (#0B6E4F)
  static Color customPrimaryColor = const Color(0xFF0B6E4F);

  /// Default to the Web Version's calm Light Mode (`#F4F7F5` canvas + `#FFFFFF` cards).
  /// Users can switch to Dark Mode or System Mode at any time.
  static ThemeMode themeMode = ThemeMode.light;

  static bool get isDarkMode => themeMode == ThemeMode.dark;
  static set isDarkMode(bool value) {
    themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifier.notify();
  }

  static void toggleThemeMode() {
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }
    notifier.notify();
  }

  static void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifier.notify();
  }

  /// Soft mint/brand surface tint matching `--brand-surface` (`#ECFDF5` / `rgba(r,g,b,0.09)`)
  static Color brandSurfaceTint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return customPrimaryColor.withAlpha(42);
    }
    if (customPrimaryColor.toARGB32() == const Color(0xFF0B6E4F).toARGB32() ||
        customPrimaryColor.toARGB32() == const Color(0xFF0D7450).toARGB32()) {
      return const Color(0xFFECFDF5);
    }
    return customPrimaryColor.withAlpha(22);
  }

  /// Soft brand border matching `--brand-border` (`#A7F3D0` / `rgba(r,g,b,0.28)`)
  static Color brandBorderTint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return customPrimaryColor.withAlpha(95);
    }
    if (customPrimaryColor.toARGB32() == const Color(0xFF0B6E4F).toARGB32() ||
        customPrimaryColor.toARGB32() == const Color(0xFF0D7450).toARGB32()) {
      return const Color(0xFFA7F3D0);
    }
    return customPrimaryColor.withAlpha(75);
  }

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color innerCardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSubtleSurface : lightSubtleSurface;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorderStrong : lightBorder;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : lightTextMuted;

  static ThemeData get lightTheme {
    final primary = customPrimaryColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightCanvas,
      dividerColor: lightBorder,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: activePreset.secondaryColor,
        onSecondary: Colors.white,
        tertiary: activePreset.accentColor,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        error: roseError,
        outline: lightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: lightTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          backgroundColor: lightSurface,
          minimumSize: const Size(44, 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          side: const BorderSide(color: lightBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: roseError, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSubtleSurface,
        selectedColor: primary.withAlpha(28),
        side: const BorderSide(color: lightBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(color: lightTextPrimary, fontSize: 12, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 16,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final primary = customPrimaryColor;
    final darkBrand = Color.lerp(primary, Colors.white, 0.16) ?? primary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkBrand,
      scaffoldBackgroundColor: darkCanvas,
      dividerColor: darkBorder,
      colorScheme: ColorScheme.dark(
        primary: darkBrand,
        onPrimary: Colors.white,
        secondary: activePreset.secondaryColor,
        onSecondary: Colors.white,
        tertiary: activePreset.accentColor,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: const Color(0xFFFB7185),
        outline: darkBorderStrong,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          backgroundColor: darkSubtleSurface,
          minimumSize: const Size(44, 42),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          side: const BorderSide(color: darkBorderStrong, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSubtleSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderStrong, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorderStrong, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBrand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFB7185), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSubtleSurface,
        selectedColor: darkBrand.withAlpha(50),
        side: const BorderSide(color: darkBorderStrong, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(color: darkTextPrimary, fontSize: 12, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: darkBrand, fontSize: 12, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderStrong,
        thickness: 1,
        space: 16,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorderStrong),
        ),
      ),
    );
  }

  static void setPreset(String id) {
    final normalized = id == 'emerald' ? 'ceylon-emerald' : id;
    final found = presets.firstWhere(
      (p) => p.id == normalized || p.id.contains(normalized),
      orElse: () => presets[0],
    );
    activePreset = found;
    customPrimaryColor = found.primaryColor;
    notifier.notify();
  }

  static void setCustomColor(Color color) {
    customPrimaryColor = color;
    notifier.notify();
  }

  static void resetDefault() {
    activePreset = presets[0];
    customPrimaryColor = presets[0].primaryColor;
    themeMode = ThemeMode.light;
    notifier.notify();
  }
}
