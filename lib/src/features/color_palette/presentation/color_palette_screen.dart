import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math' as math;

part 'color_palette_screen.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain helpers
// ─────────────────────────────────────────────────────────────────────────────

class PaletteColor {
  const PaletteColor({required this.name, required this.color});
  final String name;
  final Color color;
}

class HarmonyPalette {
  const HarmonyPalette({required this.name, required this.colors});
  final String name;
  final List<PaletteColor> colors;
}

// ─────────────────────────────────────────────────────────────────────────────
// Color math
// ─────────────────────────────────────────────────────────────────────────────

class _ColorMath {
  static HSLColor toHsl(Color c) => HSLColor.fromColor(c);
  static Color fromHsl(HSLColor h) => h.toColor();

  /// Shift hue by [degrees]
  static Color shiftHue(Color c, double degrees) {
    final hsl = toHsl(c);
    return fromHsl(hsl.withHue((hsl.hue + degrees) % 360));
  }

  static Color withLightness(Color c, double l) =>
      fromHsl(toHsl(c).withLightness(l.clamp(0.0, 1.0)));

  /// WCAG contrast ratio
  static double contrast(Color a, Color b) {
    final la = _lum(a);
    final lb = _lum(b);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _lum(Color c) {
    double lin(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  }

  static String wcag(double ratio) {
    if (ratio >= 7) return 'AAA';
    if (ratio >= 4.5) return 'AA';
    if (ratio >= 3) return 'AA Large';
    return 'Fail';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State & Notifier
// ─────────────────────────────────────────────────────────────────────────────

class PaletteState {
  const PaletteState({
    this.seedColor = const Color(0xFF6366F1),
    this.harmonies = const [],
    this.material3Tones = const [],
  });

  final Color seedColor;
  final List<HarmonyPalette> harmonies;
  final List<PaletteColor> material3Tones;

  PaletteState copyWith({
    Color? seedColor,
    List<HarmonyPalette>? harmonies,
    List<PaletteColor>? material3Tones,
  }) =>
      PaletteState(
        seedColor: seedColor ?? this.seedColor,
        harmonies: harmonies ?? this.harmonies,
        material3Tones: material3Tones ?? this.material3Tones,
      );
}

@riverpod
class PaletteNotifier extends _$PaletteNotifier {
  @override
  PaletteState build() {
    const seed = Color(0xFF6366F1);
    return PaletteState(
      seedColor: seed,
      harmonies: _buildHarmonies(seed),
      material3Tones: _buildTones(seed),
    );
  }

  void setSeed(Color color) {
    state = state.copyWith(
      seedColor: color,
      harmonies: _buildHarmonies(color),
      material3Tones: _buildTones(color),
    );
  }

  List<HarmonyPalette> _buildHarmonies(Color seed) {
    return [
      HarmonyPalette(
        name: 'Complementary',
        colors: [
          PaletteColor(name: 'Primary', color: seed),
          PaletteColor(name: 'Complement', color: _ColorMath.shiftHue(seed, 180)),
        ],
      ),
      HarmonyPalette(
        name: 'Analogous',
        colors: [
          PaletteColor(name: '-30°', color: _ColorMath.shiftHue(seed, -30)),
          PaletteColor(name: 'Primary', color: seed),
          PaletteColor(name: '+30°', color: _ColorMath.shiftHue(seed, 30)),
        ],
      ),
      HarmonyPalette(
        name: 'Triadic',
        colors: [
          PaletteColor(name: 'Primary', color: seed),
          PaletteColor(name: '+120°', color: _ColorMath.shiftHue(seed, 120)),
          PaletteColor(name: '+240°', color: _ColorMath.shiftHue(seed, 240)),
        ],
      ),
      HarmonyPalette(
        name: 'Split Complementary',
        colors: [
          PaletteColor(name: 'Primary', color: seed),
          PaletteColor(name: '+150°', color: _ColorMath.shiftHue(seed, 150)),
          PaletteColor(name: '+210°', color: _ColorMath.shiftHue(seed, 210)),
        ],
      ),
      HarmonyPalette(
        name: 'Tetradic',
        colors: [
          PaletteColor(name: 'Primary', color: seed),
          PaletteColor(name: '+90°', color: _ColorMath.shiftHue(seed, 90)),
          PaletteColor(name: '+180°', color: _ColorMath.shiftHue(seed, 180)),
          PaletteColor(name: '+270°', color: _ColorMath.shiftHue(seed, 270)),
        ],
      ),
      HarmonyPalette(
        name: 'Monochromatic',
        colors: [
          PaletteColor(name: '10%', color: _ColorMath.withLightness(seed, 0.10)),
          PaletteColor(name: '25%', color: _ColorMath.withLightness(seed, 0.25)),
          PaletteColor(name: '40%', color: _ColorMath.withLightness(seed, 0.40)),
          PaletteColor(name: '55%', color: _ColorMath.withLightness(seed, 0.55)),
          PaletteColor(name: '70%', color: _ColorMath.withLightness(seed, 0.70)),
          PaletteColor(name: '85%', color: _ColorMath.withLightness(seed, 0.85)),
        ],
      ),
    ];
  }

  List<PaletteColor> _buildTones(Color seed) {
    final tones = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];
    return tones.map((t) {
      final l = t / 100.0;
      return PaletteColor(
        name: '$t',
        color: _ColorMath.withLightness(seed, l),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ColorPaletteScreen extends ConsumerStatefulWidget {
  const ColorPaletteScreen({super.key});

  @override
  ConsumerState<ColorPaletteScreen> createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends ConsumerState<ColorPaletteScreen> {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);

  final TextEditingController _hexController = TextEditingController(text: '#6366F1');

  // Quick seed presets
  static const _seeds = [
    Color(0xFF6366F1), Color(0xFF06B6D4), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFFEC4899),
    Color(0xFF8B5CF6), Color(0xFF14B8A6), Color(0xFFF97316),
  ];

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paletteNotifierProvider);
    final notifier = ref.read(paletteNotifierProvider.notifier);
    final isWide = MediaQuery.of(context).size.width > 860;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [state.seedColor, _ColorMath.shiftHue(state.seedColor, 60)]),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(width: 10),
            Text('Color Palette Generator',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: isWide
          ? Row(children: [
              SizedBox(width: 300, child: _buildSeedPanel(state, notifier)),
              Container(width: 1, color: _border),
              Expanded(child: _buildPalettePanel(state)),
            ])
          : Column(children: [
              _buildSeedPanel(state, notifier),
              Container(height: 1, color: _border),
              Expanded(child: _buildPalettePanel(state)),
            ]),
    );
  }

  // ── Seed Panel ──────────────────────────────────────────────────────────────
  Widget _buildSeedPanel(PaletteState state, PaletteNotifier notifier) {
    final seed = state.seedColor;
    final hex = '#${seed.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
    final contrastOnWhite = _ColorMath.contrast(seed, Colors.white);
    final contrastOnBlack = _ColorMath.contrast(seed, Colors.black);

    return Container(
      color: _surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big swatch
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [seed, _ColorMath.shiftHue(seed, 40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: seed.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
            ),
            child: Center(
              child: Text(hex,
                  style: GoogleFonts.robotoMono(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [const Shadow(blurRadius: 8)])),
            ),
          ),
          const SizedBox(height: 20),

          // Hex input
          _sectionLabel('HEX INPUT'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hexController,
                  onSubmitted: (v) => _applyHex(v, notifier),
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true, fillColor: _bg,
                    hintText: '#RRGGBB',
                    hintStyle: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: seed)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _applyHex(_hexController.text, notifier),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: seed, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick seeds
          _sectionLabel('QUICK SEEDS'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _seeds.map((c) {
              final isSelected = c == state.seedColor;
              return GestureDetector(
                onTap: () {
                  _hexController.text = '#${c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
                  notifier.setSeed(c);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 10)] : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Contrast checker
          _sectionLabel('CONTRAST (WCAG)'),
          const SizedBox(height: 10),
          _contrastRow('On White', seed, Colors.white, contrastOnWhite),
          const SizedBox(height: 8),
          _contrastRow('On Black', seed, Colors.black, contrastOnBlack),
        ],
      ),
    );
  }

  Widget _contrastRow(String label, Color fg, Color bg, double ratio) {
    final wcag = _ColorMath.wcag(ratio);
    final pass = wcag != 'Fail';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg == Colors.white ? Colors.white : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: bg == Colors.white ? Colors.black : Colors.white60)),
          const Spacer(),
          Text('${ratio.toStringAsFixed(1)}:1',
              style: GoogleFonts.robotoMono(
                  fontSize: 12, color: bg == Colors.white ? Colors.black87 : Colors.white70)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (pass ? Colors.green : Colors.red).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(wcag,
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.bold,
                    color: pass ? Colors.green : Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Palette Panel ───────────────────────────────────────────────────────────
  Widget _buildPalettePanel(PaletteState state) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Material 3 Tonal Palette
        _sectionLabel('MATERIAL 3 TONAL PALETTE'),
        const SizedBox(height: 12),
        _buildTonalPalette(state.material3Tones),
        const SizedBox(height: 28),
        _sectionLabel('COLOR HARMONIES'),
        const SizedBox(height: 12),
        ...state.harmonies.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildHarmonyCard(h),
            )),
      ],
    );
  }

  Widget _buildTonalPalette(List<PaletteColor> tones) {
    return Column(
      children: [
        Row(
          children: tones.map((t) {
            final isLight = _ColorMath.toHsl(t.color).lightness > 0.5;
            return Expanded(
              child: GestureDetector(
                onTap: () => _copyHex(t.color),
                child: Tooltip(
                  message: 'Tone ${t.name} — tap to copy',
                  child: Container(
                    height: 56,
                    color: t.color,
                    child: Center(
                      child: Text(t.name,
                          style: GoogleFonts.inter(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: isLight ? Colors.black54 : Colors.white60)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Hex row
        Row(
          children: tones.map((t) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _copyHex(t.color),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.03),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _shortHex(t.color),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white38),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHarmonyCard(HarmonyPalette harmony) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(harmony.name,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
          ),
          // Swatches
          Row(
            children: harmony.colors.map((pc) {
              final isLight = _ColorMath.toHsl(pc.color).lightness > 0.5;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _copyHex(pc.color),
                  child: Tooltip(
                    message: 'Tap to copy ${_shortHex(pc.color)}',
                    child: Container(
                      height: 80,
                      color: pc.color,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pc.name,
                                style: GoogleFonts.inter(
                                    fontSize: 9, color: isLight ? Colors.black45 : Colors.white54)),
                            Text(_shortHex(pc.color),
                                style: GoogleFonts.robotoMono(
                                    fontSize: 9, fontWeight: FontWeight.w700,
                                    color: isLight ? Colors.black : Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _applyHex(String input, PaletteNotifier notifier) {
    try {
      final clean = input.replaceAll('#', '').padLeft(6, '0');
      if (clean.length != 6) return;
      final color = Color(int.parse('FF$clean', radix: 16));
      notifier.setSeed(color);
      _hexController.text = '#${clean.toUpperCase()}';
    } catch (_) {}
  }

  void _copyHex(Color c) {
    final hex = '#${c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
    Clipboard.setData(ClipboardData(text: hex));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$hex copied!', style: GoogleFonts.inter()),
      backgroundColor: const Color(0xFF6366F1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 1),
    ));
  }

  String _shortHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';

  Widget _sectionLabel(String text) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.3), letterSpacing: 1.1));
}
