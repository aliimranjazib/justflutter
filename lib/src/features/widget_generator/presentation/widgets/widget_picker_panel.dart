import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/widget_template.dart';
import '../../data/widget_registry.dart';
import '../../application/widget_generator_notifier.dart';

class WidgetPickerPanel extends ConsumerWidget {
  const WidgetPickerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(widgetRegistryProvider).getTemplates();
    final selectedTemplate = ref.watch(widgetGeneratorNotifierProvider.select((s) => s.selectedTemplate));

    final categories = <String, List<WidgetTemplate>>{};
    for (final t in templates) {
      categories.putIfAbsent(t.category, () => []).add(t);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'WIDGETS',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.4),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryName = categories.keys.elementAt(index);
                final categoryTemplates = categories[categoryName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        categoryName.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.2),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    ...categoryTemplates.map((t) {
                      final isSelected = selectedTemplate?.id == t.id;
                      return _WidgetPickerTile(
                        template: t,
                        isSelected: isSelected,
                        onTap: () => ref.read(widgetGeneratorNotifierProvider.notifier).selectTemplate(t),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetPickerTile extends StatelessWidget {
  const _WidgetPickerTile({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  final WidgetTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                template.icon,
                size: 18,
                color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 12),
              Text(
                template.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
