import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../application/theme_generator_notifier.dart';

const _fontFamilies = [
  'Inter',
  'Poppins',
  'Roboto',
  'Roboto Mono',
  'Lato',
  'Nunito',
];

class ColorInputPanel extends ConsumerWidget {
  const ColorInputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeGeneratorNotifierProvider.select((s) => s.config));
    final notifier = ref.read(themeGeneratorNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section: Colors ────────────────────────────────────────────
          _SectionLabel('COLORS'),
          const SizedBox(height: 16),
          _ColorSelector(
            label: 'Primary',
            color: config.primaryColor,
            onChanged: (c) => notifier.updateConfig(config.copyWith(primaryColor: c)),
          ),
          const SizedBox(height: 12),
          _ColorSelector(
            label: 'Secondary',
            color: config.secondaryColor,
            onChanged: (c) => notifier.updateConfig(config.copyWith(secondaryColor: c)),
          ),
          const SizedBox(height: 12),
          _ColorSelector(
            label: 'Background',
            color: config.backgroundColor ?? (config.brightness == Brightness.dark ? Colors.black : Colors.white),
            onChanged: (c) => notifier.updateConfig(config.copyWith(backgroundColor: c)),
          ),
          const SizedBox(height: 12),
          _ColorSelector(
            label: 'Surface',
            color: config.surfaceColor ?? (config.brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFFAFAFA)),
            onChanged: (c) => notifier.updateConfig(config.copyWith(surfaceColor: c)),
          ),
          const SizedBox(height: 12),
          _ColorSelector(
            label: 'Accent',
            color: config.accentColor ?? config.primaryColor,
            onChanged: (c) => notifier.updateConfig(config.copyWith(accentColor: c)),
          ),

          const SizedBox(height: 28),

          // ─── Section: Brightness ────────────────────────────────────────
          _SectionLabel('BRIGHTNESS'),
          const SizedBox(height: 12),
          _BrightnessToggle(config: config, notifier: notifier),

          const SizedBox(height: 28),

          // ─── Section: Typography ────────────────────────────────────────
          _SectionLabel('TYPOGRAPHY'),
          const SizedBox(height: 12),
          _FontFamilySelector(
            value: config.fontFamily,
            onChanged: (font) => notifier.updateConfig(config.copyWith(fontFamily: font)),
          ),

          const SizedBox(height: 28),

          // ─── Section: Shape ─────────────────────────────────────────────
          _SectionLabel('BORDER RADIUS'),
          const SizedBox(height: 4),
          _BorderRadiusSlider(
            value: config.borderRadius,
            primaryColor: config.primaryColor,
            onChanged: (v) => notifier.updateConfig(config.copyWith(borderRadius: v)),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white.withValues(alpha: 0.3),
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Brightness toggle ─────────────────────────────────────────────────────────
class _BrightnessToggle extends StatelessWidget {
  const _BrightnessToggle({required this.config, required this.notifier});
  final dynamic config;
  final dynamic notifier;

  @override
  Widget build(BuildContext context) {
    final isDark = config.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(isDark ? Icons.dark_mode : Icons.light_mode,
            size: 16, color: Colors.white54),
        const SizedBox(width: 10),
        Text(
          isDark ? 'Dark Mode' : 'Light Mode',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
        ),
        const Spacer(),
        Switch.adaptive(
          value: isDark,
          activeColor: config.primaryColor,
          onChanged: (val) => notifier.updateConfig(
            config.copyWith(brightness: val ? Brightness.dark : Brightness.light),
          ),
        ),
      ],
    );
  }
}

// ── Font family dropdown ──────────────────────────────────────────────────────
class _FontFamilySelector extends StatelessWidget {
  const _FontFamilySelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = _fontFamilies.contains(value) ? value : _fontFamilies.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF111111),
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          iconEnabledColor: Colors.white38,
          items: _fontFamilies
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: (f) => f != null ? onChanged(f) : null,
        ),
      ),
    );
  }
}

// ── Border radius slider ──────────────────────────────────────────────────────
class _BorderRadiusSlider extends StatelessWidget {
  const _BorderRadiusSlider({
    required this.value,
    required this.primaryColor,
    required this.onChanged,
  });
  final double value;
  final Color primaryColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbColor: primaryColor,
            activeTrackColor: primaryColor,
            inactiveTrackColor: Colors.white12,
            overlayColor: primaryColor.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 32,
            divisions: 32,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0 (Sharp)', style: GoogleFonts.inter(fontSize: 10, color: Colors.white24)),
            Text('${value.round()}px', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600)),
            Text('32 (Pill)', style: GoogleFonts.inter(fontSize: 10, color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 8),
        // Preview
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(value),
              ),
              alignment: Alignment.center,
              child: Text('Preview', style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Color selector ────────────────────────────────────────────────────────────
class _ColorSelector extends StatelessWidget {
  const _ColorSelector({required this.label, required this.color, required this.onChanged});
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // Swatch
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white30, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  '#${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            onColorChanged: onChanged,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
