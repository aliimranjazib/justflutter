import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/theme_config.dart';
import '../../data/theme_presets.dart';
import '../../application/theme_generator_notifier.dart';

// ── Filter categories ────────────────────────────────────────────────────────
const _categories = [
  ('all', 'All'),
  ('dark', '🌑 Dark'),
  ('light', '🌕 Light'),
  ('vivid', '🌈 Vivid'),
  ('earthy', '🍂 Earthy'),
  ('dev', '💜 Dev'),
  ('apps', '📱 Apps'),
];

class PresetGallery extends ConsumerStatefulWidget {
  const PresetGallery({super.key});

  @override
  ConsumerState<PresetGallery> createState() => _PresetGalleryState();
}

class _PresetGalleryState extends ConsumerState<PresetGallery> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final filtered = ThemePresets.byCategory(_selectedCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Text(
            'TRENDY PRESETS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 1.0,
            ),
          ),
        ),

        // ── Filter chips ─────────────────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            children: _categories.map((cat) {
              final isActive = _selectedCategory == cat.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Text(
                      cat.$2,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // ── List ────────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _PresetTile(preset: filtered[index]),
          ),
        ),
      ],
    );
  }
}

// ── Preset Tile ───────────────────────────────────────────────────────────────
class _PresetTile extends ConsumerWidget {
  const _PresetTile({required this.preset});
  final ThemePreset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeConfig = ref.watch(themeGeneratorNotifierProvider.select((s) => s.config));
    final isSelected = activeConfig.primaryColor == preset.primary &&
        activeConfig.secondaryColor == preset.secondary &&
        activeConfig.brightness == preset.brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => ref.read(themeGeneratorNotifierProvider.notifier).applyPreset(preset),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? preset.primary.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? preset.primary.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: preset.primary.withValues(alpha: 0.15), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Name & selection check
                  Expanded(
                    child: Text(
                      preset.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: preset.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 11, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // ── Swatch row ─────────────────────────────────────────────
              Row(
                children: [
                  _Swatch(color: preset.primary, label: 'Primary'),
                  const SizedBox(width: 6),
                  _Swatch(color: preset.secondary, label: 'Secondary'),
                  if (preset.surface != null) ...[
                    const SizedBox(width: 6),
                    _Swatch(color: preset.surface!, label: 'Surface'),
                  ],
                  if (preset.accent != null) ...[
                    const SizedBox(width: 6),
                    _Swatch(color: preset.accent!, label: 'Accent'),
                  ],
                  const Spacer(),
                  // Font badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Text(
                      preset.fontFamily,
                      style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.white30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                preset.description,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white30, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
        ),
      ),
    );
  }
}
