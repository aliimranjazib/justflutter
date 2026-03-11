enum PropertyType { slider, colorPicker, textInput, dropdown, toggle, intInput }

class PropertyDefinition {
  const PropertyDefinition({
    required this.key,
    required this.label,
    required this.type,
    required this.defaultValue,
    this.min,
    this.max,
    this.options,
  });

  final String key;
  final String label;
  final PropertyType type;
  final dynamic defaultValue;
  final double? min;
  final double? max;
  final List<String>? options;
}
