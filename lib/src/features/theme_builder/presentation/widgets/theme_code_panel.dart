import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/theme_generator_notifier.dart';

class ThemeCodePanel extends ConsumerWidget {
  const ThemeCodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeGeneratorNotifierProvider);
    final isDark = state.config.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GENERATED THEMEDATA',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1.0,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state.generatedCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme code copied to clipboard')),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 14),
                  label: Text('Copy Code', style: GoogleFonts.inter(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: state.config.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: SelectableText(
                state.generatedCode,
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFCE9178) : const Color(0xFF098658), // Theme-specific code color
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
