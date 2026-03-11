import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/widget_template.dart';
import '../data/widget_registry.dart';

part 'widget_generator_notifier.g.dart';

class WidgetGeneratorState {
  const WidgetGeneratorState({
    this.selectedTemplate,
    required this.propertyValues,
    required this.generatedCode,
  });

  final WidgetTemplate? selectedTemplate;
  final Map<String, dynamic> propertyValues;
  final String generatedCode;

  WidgetGeneratorState copyWith({
    WidgetTemplate? selectedTemplate,
    Map<String, dynamic>? propertyValues,
    String? generatedCode,
  }) {
    return WidgetGeneratorState(
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      propertyValues: propertyValues ?? this.propertyValues,
      generatedCode: generatedCode ?? this.generatedCode,
    );
  }
}

@riverpod
class WidgetGeneratorNotifier extends _$WidgetGeneratorNotifier {
  @override
  WidgetGeneratorState build() {
    return const WidgetGeneratorState(
      propertyValues: {},
      generatedCode: '',
    );
  }

  void selectTemplate(WidgetTemplate template) {
    final initialValues = <String, dynamic>{};
    for (final prop in template.properties) {
      initialValues[prop.key] = prop.defaultValue;
    }

    state = state.copyWith(
      selectedTemplate: template,
      propertyValues: initialValues,
      generatedCode: template.codeBuilder(initialValues),
    );
  }

  void updateProperty(String key, dynamic value) {
    final template = state.selectedTemplate;
    if (template == null) return;

    final newValues = Map<String, dynamic>.from(state.propertyValues);
    newValues[key] = value;

    state = state.copyWith(
      propertyValues: newValues,
      generatedCode: template.codeBuilder(newValues),
    );
  }
}
