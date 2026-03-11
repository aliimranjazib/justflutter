import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/widget_generator_notifier.dart';

class CodeGeneratorPanel extends ConsumerWidget {
  const CodeGeneratorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(widgetGeneratorNotifierProvider.select((s) => s.generatedCode));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GENERATED CODE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 14),
                  label: Text('Copy', style: GoogleFonts.inter(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: SelectableText(
                code,
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: const Color(0xFF9CDCFE),
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
