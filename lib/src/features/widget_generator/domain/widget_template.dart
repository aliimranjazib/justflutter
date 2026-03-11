import 'package:flutter/widgets.dart';
import 'property_definition.dart';

class WidgetTemplate {
  const WidgetTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.properties,
    required this.codeBuilder,
    required this.widgetBuilder,
  });

  final String id;
  final String name;
  final String category;
  final IconData icon;
  final List<PropertyDefinition> properties;
  final String Function(Map<String, dynamic> values) codeBuilder;
  final Widget Function(Map<String, dynamic> values) widgetBuilder;
}
