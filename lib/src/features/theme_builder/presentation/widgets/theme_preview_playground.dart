import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/theme_generator_notifier.dart';

class ThemePreviewPlayground extends ConsumerWidget {
  const ThemePreviewPlayground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeGeneratorNotifierProvider);
    final c = state.config;

    final isDark = c.brightness == Brightness.dark;
    final bg = c.backgroundColor ?? (isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF));
    final surf = c.surfaceColor ?? (isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA));
    final accent = c.accentColor ?? c.primaryColor;
    final br = c.borderRadius;

    final liveTheme = ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      primaryColor: c.primaryColor,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primaryColor,
        primary: c.primaryColor,
        secondary: c.secondaryColor,
        tertiary: accent,
        surface: surf,
        brightness: c.brightness,
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(br),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primaryColor,
          foregroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(br)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primaryColor,
          side: BorderSide(color: c.primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(br)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(br)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(br),
          borderSide: BorderSide(color: c.primaryColor, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surf,
        selectedColor: c.primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(br / 2 + 2)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: c.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );

    return Theme(
      data: liveTheme,
      child: Container(
        color: bg,
        child: Column(
          children: [
            // ── Playground header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text(
                    'LIVE PREVIEW',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.35),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  // Radius badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'r=${br.round()}  • ${c.fontFamily}',
                      style: TextStyle(fontSize: 10, color: c.primaryColor, fontFamily: 'Roboto Mono'),
                    ),
                  ),
                ],
              ),
            ),
            // ── Scrollable preview content ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Buttons
                  _Label('Buttons', isDark),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Primary')),
                      FilledButton(onPressed: () {}, child: const Text('Filled')),
                      OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                      TextButton(onPressed: () {}, child: const Text('Text')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Card
                  _Label('Card', isDark),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(br / 2),
                                ),
                                child: Icon(Icons.auto_awesome, size: 16, color: c.primaryColor),
                              ),
                              const SizedBox(width: 10),
                              Text('Card Title', style: liveTheme.textTheme.titleSmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Surface and radius adapt to your config in real time. Try changing the border radius!',
                            style: liveTheme.textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chips
                  _Label('Chips', isDark),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(label: const Text('Design'), selected: true, onSelected: (_) {}),
                      FilterChip(label: const Text('Flutter'), selected: false, onSelected: (_) {}),
                      FilterChip(label: const Text('Code'), selected: false, onSelected: (_) {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Input
                  _Label('Input Field', isDark),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.mail_outline, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Controls
                  _Label('Controls', isDark),
                  Row(
                    children: [
                      Checkbox(value: true, activeColor: c.primaryColor, onChanged: (_) {}),

                      Text('Checked', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                      const SizedBox(width: 20),
                      Switch(value: true, activeColor: c.primaryColor, onChanged: (_) {}),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.title, this.isDark);
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white24 : Colors.black26,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
