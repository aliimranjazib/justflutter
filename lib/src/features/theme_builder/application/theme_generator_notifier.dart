import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/theme_config.dart';

part 'theme_generator_notifier.g.dart';

class ThemeGeneratorState {
  const ThemeGeneratorState({
    required this.config,
    required this.generatedCode,
  });

  final ThemeConfig config;
  final String generatedCode;

  ThemeGeneratorState copyWith({
    ThemeConfig? config,
    String? generatedCode,
  }) {
    return ThemeGeneratorState(
      config: config ?? this.config,
      generatedCode: generatedCode ?? this.generatedCode,
    );
  }
}

@riverpod
class ThemeGeneratorNotifier extends _$ThemeGeneratorNotifier {
  @override
  ThemeGeneratorState build() {
    const initialConfig = ThemeConfig(
      primaryColor: Color(0xFF5E6AD2),
      secondaryColor: Color(0xFF1F2937),
      brightness: Brightness.dark,
      backgroundColor: Color(0xFF0A0A0A),
      surfaceColor: Color(0xFF111111),
      accentColor: Color(0xFFE4E669),
      fontFamily: 'Inter',
      borderRadius: 8,
    );
    return ThemeGeneratorState(
      config: initialConfig,
      generatedCode: _generateCode(initialConfig),
    );
  }

  void updateConfig(ThemeConfig newConfig) {
    state = state.copyWith(
      config: newConfig,
      generatedCode: _generateCode(newConfig),
    );
  }

  void applyPreset(ThemePreset preset) {
    final newConfig = ThemeConfig(
      primaryColor: preset.primary,
      secondaryColor: preset.secondary,
      brightness: preset.brightness,
      backgroundColor: preset.background,
      surfaceColor: preset.surface,
      accentColor: preset.accent,
      fontFamily: preset.fontFamily,
      borderRadius: preset.borderRadius,
    );
    updateConfig(newConfig);
  }

  String _hex(Color c) =>
      c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0');

  String _generateCode(ThemeConfig c) {
    final isDark = c.brightness == Brightness.dark;
    final bg = c.backgroundColor ?? (isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF));
    final surf = c.surfaceColor ?? (isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA));
    final accent = c.accentColor ?? c.primaryColor;
    final br = c.borderRadius;
    final font = c.fontFamily;

    final primaryHex = _hex(c.primaryColor);
    final secondaryHex = _hex(c.secondaryColor);
    final bgHex = _hex(bg);
    final surfHex = _hex(surf);
    final accentHex = _hex(accent);

    return '''ThemeData(
  useMaterial3: true,
  brightness: Brightness.${isDark ? 'dark' : 'light'},
  fontFamily: '$font',
  primaryColor: const Color(0x$primaryHex),

  // Color Scheme
  colorScheme: ColorScheme.${isDark ? 'dark' : 'light'}(
    primary: const Color(0x$primaryHex),
    onPrimary: ${isDark ? 'Colors.white' : 'Colors.black'},
    secondary: const Color(0x$secondaryHex),
    onSecondary: ${isDark ? 'Colors.white' : 'Colors.black'},
    tertiary: const Color(0x$accentHex),
    surface: const Color(0x$surfHex),
    onSurface: ${isDark ? 'const Color(0xFFEDEDED)' : 'const Color(0xFF111111)'},
    background: const Color(0x$bgHex),
    onBackground: ${isDark ? 'const Color(0xFFEDEDED)' : 'const Color(0xFF111111)'},
    error: const Color(0xFFCF6679),
  ),

  scaffoldBackgroundColor: const Color(0x$bgHex),

  // AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0x$bgHex),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: '$font',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: ${isDark ? 'Colors.white' : 'Colors.black'},
    ),
    iconTheme: IconThemeData(
      color: ${isDark ? 'Colors.white' : 'Colors.black'},
    ),
  ),

  // Cards
  cardTheme: CardTheme(
    color: const Color(0x$surfHex),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular($br),
      side: BorderSide(
        color: ${isDark ? 'Colors.white12' : 'Colors.black12'},
      ),
    ),
    margin: EdgeInsets.zero,
  ),

  // Elevated Button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0x$primaryHex),
      foregroundColor: ${isDark ? 'Colors.white' : 'Colors.black'},
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($br),
      ),
      textStyle: const TextStyle(
        fontFamily: '$font',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),

  // Filled Button
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0x$primaryHex),
      foregroundColor: ${isDark ? 'Colors.white' : 'Colors.black'},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($br),
      ),
    ),
  ),

  // Outlined Button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0x$primaryHex),
      side: const BorderSide(color: Color(0x$primaryHex)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($br),
      ),
    ),
  ),

  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0x$surfHex),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular($br),
      borderSide: const BorderSide(color: Color(0x$secondaryHex)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular($br),
      borderSide: BorderSide(
        color: ${isDark ? 'Colors.white12' : 'Colors.black12'},
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular($br),
      borderSide: const BorderSide(
        color: Color(0x$primaryHex),
        width: 2,
      ),
    ),
    labelStyle: TextStyle(
      fontFamily: '$font',
      color: ${isDark ? 'Colors.white54' : 'Colors.black54'},
    ),
  ),

  // Divider
  dividerTheme: DividerThemeData(
    color: ${isDark ? 'Colors.white10' : 'Colors.black10'},
    thickness: 1,
    space: 1,
  ),

  // Chip
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0x$surfHex),
    selectedColor: const Color(0x$primaryHex),
    labelStyle: const TextStyle(fontFamily: '$font', fontSize: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(${br / 2}),
    ),
  ),

  // FAB
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0x$primaryHex),
    foregroundColor: ${isDark ? 'Colors.white' : 'Colors.black'},
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(${br + 4}),
    ),
  ),
)''';
  }
}
