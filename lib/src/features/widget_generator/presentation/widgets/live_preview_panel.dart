import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/widget_generator_notifier.dart';

class LivePreviewPanel extends ConsumerWidget {
  const LivePreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(widgetGeneratorNotifierProvider);
    final template = state.selectedTemplate;

    if (template == null) {
      return Container(
        color: const Color(0xFF000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_off_outlined, size: 48, color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                'Preview will appear here',
                style: GoogleFonts.inter(color: Colors.white.withOpacity(0.2)),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF000000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'LIVE PREVIEW',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey('${template.id}_${state.propertyValues.hashCode}'),
                  child: template.widgetBuilder(state.propertyValues),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
