import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../domain/property_definition.dart';
import '../../application/widget_generator_notifier.dart';

class PropertyEditorPanel extends ConsumerWidget {
  const PropertyEditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(widgetGeneratorNotifierProvider);
    final template = state.selectedTemplate;

    if (template == null) {
      return Container(
        color: const Color(0xFF0F0F0F),
        child: Center(
          child: Text(
            'Select a widget to edit properties',
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F0F0F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'PROPERTIES: ${template.name}',
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              itemCount: template.properties.length,
              itemBuilder: (context, index) {
                final prop = template.properties[index];
                final value = state.propertyValues[prop.key];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prop.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildEditor(context, ref, prop, value),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, WidgetRef ref, PropertyDefinition prop, dynamic value) {
    switch (prop.type) {
      case PropertyType.slider:
        return Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveTrackColor: Colors.white.withOpacity(0.05),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF3B82F6).withOpacity(0.1),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: prop.min ?? 0,
                  max: prop.max ?? 100,
                  onChanged: (v) => ref.read(widgetGeneratorNotifierProvider.notifier).updateProperty(prop.key, v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white.withOpacity(0.5)),
            ),
          ],
        );
      case PropertyType.colorPicker:
        return GestureDetector(
          onTap: () => _showColorPicker(context, ref, prop, value as int),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(value as int),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '#${value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        );
      case PropertyType.textInput:
        return TextField(
          onChanged: (v) => ref.read(widgetGeneratorNotifierProvider.notifier).updateProperty(prop.key, v),
          controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
        );
      case PropertyType.toggle:
        return Switch(
          value: value as bool,
          activeColor: const Color(0xFF3B82F6),
          onChanged: (v) => ref.read(widgetGeneratorNotifierProvider.notifier).updateProperty(prop.key, v),
        );
      default:
        return Text('Editor for ${prop.type} not implemented');
    }
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, PropertyDefinition prop, int currentColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text('Pick a color', style: GoogleFonts.inter(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Color(currentColor),
            onColorChanged: (color) => ref.read(widgetGeneratorNotifierProvider.notifier).updateProperty(prop.key, color.value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
