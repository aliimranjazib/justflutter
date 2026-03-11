import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/property_definition.dart';
import '../domain/widget_template.dart';

part 'widget_registry.g.dart';

class WidgetRegistry {
  List<WidgetTemplate> getTemplates() {
    return [
      _elevatedButtonTemplate(),
      _outlinedButtonTemplate(),
      _textButtonTemplate(),
      _fabTemplate(),
      _textFieldTemplate(),
      _containerTemplate(),
      _cardTemplate(),
      _listViewTemplate(),
      _chipTemplate(),
    ];
  }

  WidgetTemplate _elevatedButtonTemplate() {
    return WidgetTemplate(
      id: 'elevated_button',
      name: 'ElevatedButton',
      category: 'Buttons',
      icon: LucideIcons.mousePointerClick,
      properties: [
        const PropertyDefinition(
          key: 'label',
          label: 'Label Text',
          type: PropertyType.textInput,
          defaultValue: 'Click Me',
        ),
        const PropertyDefinition(
          key: 'borderRadius',
          label: 'Border Radius',
          type: PropertyType.slider,
          defaultValue: 8.0,
          min: 0,
          max: 50,
        ),
        const PropertyDefinition(
          key: 'backgroundColor',
          label: 'Background Color',
          type: PropertyType.colorPicker,
          defaultValue: 0xFF2563EB,
        ),
        const PropertyDefinition(
          key: 'foregroundColor',
          label: 'Text Color',
          type: PropertyType.colorPicker,
          defaultValue: 0xFFFFFFFF,
        ),
        const PropertyDefinition(
          key: 'elevation',
          label: 'Elevation',
          type: PropertyType.slider,
          defaultValue: 2.0,
          min: 0,
          max: 20,
        ),
      ],
      widgetBuilder: (v) => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(v['backgroundColor'] as int),
          foregroundColor: Color(v['foregroundColor'] as int),
          elevation: v['elevation'] as double,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(v['borderRadius'] as double),
          ),
        ),
        child: Text(v['label'] as String),
      ),
      codeBuilder: (v) => '''
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0x${(v['backgroundColor'] as int).toRadixString(16)}),
    foregroundColor: const Color(0x${(v['foregroundColor'] as int).toRadixString(16)}),
    elevation: ${v['elevation']},
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(${v['borderRadius']}),
    ),
  ),
  child: const Text('${v['label']}'),
)''',
    );
  }

  WidgetTemplate _textFieldTemplate() {
    return WidgetTemplate(
      id: 'text_field',
      name: 'TextField',
      category: 'Inputs',
      icon: LucideIcons.type,
      properties: [
        const PropertyDefinition(
          key: 'hintText',
          label: 'Hint Text',
          type: PropertyType.textInput,
          defaultValue: 'Enter text here',
        ),
        const PropertyDefinition(
          key: 'filled',
          label: 'Filled',
          type: PropertyType.toggle,
          defaultValue: true,
        ),
        const PropertyDefinition(
          key: 'fillColor',
          label: 'Fill Color',
          type: PropertyType.colorPicker,
          defaultValue: 0xFFF3F4F6,
        ),
        const PropertyDefinition(
          key: 'borderRadius',
          label: 'Border Radius',
          type: PropertyType.slider,
          defaultValue: 10.0,
          min: 0,
          max: 30,
        ),
      ],
      widgetBuilder: (v) => TextField(
        decoration: InputDecoration(
          hintText: v['hintText'] as String,
          filled: v['filled'] as bool,
          fillColor: Color(v['fillColor'] as int),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(v['borderRadius'] as double),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      codeBuilder: (v) => '''
TextField(
  decoration: InputDecoration(
    hintText: '${v['hintText']}',
    filled: ${v['filled']},
    fillColor: const Color(0x${(v['fillColor'] as int).toRadixString(16)}),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(${v['borderRadius']}),
      borderSide: BorderSide.none,
    ),
  ),
)''',
    );
  }

  WidgetTemplate _containerTemplate() {
    return WidgetTemplate(
      id: 'container',
      name: 'Container',
      category: 'Layout',
      icon: LucideIcons.square,
      properties: [
        const PropertyDefinition(
          key: 'width',
          label: 'Width',
          type: PropertyType.slider,
          defaultValue: 100.0,
          min: 20,
          max: 300,
        ),
        const PropertyDefinition(
          key: 'height',
          label: 'Height',
          type: PropertyType.slider,
          defaultValue: 100.0,
          min: 20,
          max: 300,
        ),
        const PropertyDefinition(
          key: 'color',
          label: 'Color',
          type: PropertyType.colorPicker,
          defaultValue: 0xFF3B82F6,
        ),
        const PropertyDefinition(
          key: 'borderRadius',
          label: 'Border Radius',
          type: PropertyType.slider,
          defaultValue: 12.0,
          min: 0,
          max: 100,
        ),
      ],
      widgetBuilder: (v) => Container(
        width: v['width'] as double,
        height: v['height'] as double,
        decoration: BoxDecoration(
          color: Color(v['color'] as int),
          borderRadius: BorderRadius.circular(v['borderRadius'] as double),
        ),
      ),
      codeBuilder: (v) => '''
Container(
  width: ${v['width']},
  height: ${v['height']},
  decoration: BoxDecoration(
    color: const Color(0x${(v['color'] as int).toRadixString(16)}),
    borderRadius: BorderRadius.circular(${v['borderRadius']}),
  ),
)''',
    );
  }

  WidgetTemplate _outlinedButtonTemplate() {
    return WidgetTemplate(
      id: 'outlined_button',
      name: 'OutlinedButton',
      category: 'Buttons',
      icon: LucideIcons.mousePointer,
      properties: [
        const PropertyDefinition(key: 'label', label: 'Label Text', type: PropertyType.textInput, defaultValue: 'Outlined'),
        const PropertyDefinition(key: 'color', label: 'Color', type: PropertyType.colorPicker, defaultValue: 0xFF3B82F6),
        const PropertyDefinition(key: 'borderRadius', label: 'Border Radius', type: PropertyType.slider, defaultValue: 8.0, min: 0, max: 50),
      ],
      widgetBuilder: (v) => OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(v['color'] as int),
          side: BorderSide(color: Color(v['color'] as int)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(v['borderRadius'] as double)),
        ),
        child: Text(v['label'] as String),
      ),
      codeBuilder: (v) => '''
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0x${(v['color'] as int).toRadixString(16)}),
    side: const BorderSide(color: Color(0x${(v['color'] as int).toRadixString(16)})),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(${v['borderRadius']}),
    ),
  ),
  child: const Text('${v['label']}'),
)''',
    );
  }

  WidgetTemplate _textButtonTemplate() {
    return WidgetTemplate(
      id: 'text_button',
      name: 'TextButton',
      category: 'Buttons',
      icon: LucideIcons.type,
      properties: [
        const PropertyDefinition(key: 'label', label: 'Label Text', type: PropertyType.textInput, defaultValue: 'Text Button'),
        const PropertyDefinition(key: 'color', label: 'Color', type: PropertyType.colorPicker, defaultValue: 0xFF3B82F6),
      ],
      widgetBuilder: (v) => TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(foregroundColor: Color(v['color'] as int)),
        child: Text(v['label'] as String),
      ),
      codeBuilder: (v) => '''
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: const Color(0x${(v['color'] as int).toRadixString(16)}),
  ),
  child: const Text('${v['label']}'),
)''',
    );
  }

  WidgetTemplate _fabTemplate() {
    return WidgetTemplate(
      id: 'fab',
      name: 'FloatingActionButton',
      category: 'Buttons',
      icon: LucideIcons.plus,
      properties: [
        const PropertyDefinition(key: 'backgroundColor', label: 'Background Color', type: PropertyType.colorPicker, defaultValue: 0xFF3B82F6),
        const PropertyDefinition(key: 'foregroundColor', label: 'Icon Color', type: PropertyType.colorPicker, defaultValue: 0xFFFFFFFF),
        const PropertyDefinition(key: 'mini', label: 'Mini Size', type: PropertyType.toggle, defaultValue: false),
      ],
      widgetBuilder: (v) => FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(v['backgroundColor'] as int),
        foregroundColor: Color(v['foregroundColor'] as int),
        mini: v['mini'] as bool,
        child: const Icon(Icons.add),
      ),
      codeBuilder: (v) => '''
FloatingActionButton(
  onPressed: () {},
  backgroundColor: const Color(0x${(v['backgroundColor'] as int).toRadixString(16)}),
  foregroundColor: const Color(0x${(v['foregroundColor'] as int).toRadixString(16)}),
  mini: ${v['mini']},
  child: const Icon(Icons.add),
)''',
    );
  }

  WidgetTemplate _cardTemplate() {
    return WidgetTemplate(
      id: 'card',
      name: 'Card',
      category: 'Layout',
      icon: LucideIcons.layout,
      properties: [
        const PropertyDefinition(key: 'elevation', label: 'Elevation', type: PropertyType.slider, defaultValue: 2.0, min: 0, max: 20),
        const PropertyDefinition(key: 'color', label: 'Color', type: PropertyType.colorPicker, defaultValue: 0xFF1F2937),
        const PropertyDefinition(key: 'borderRadius', label: 'Border Radius', type: PropertyType.slider, defaultValue: 12.0, min: 0, max: 50),
      ],
      widgetBuilder: (v) => Card(
        elevation: v['elevation'] as double,
        color: Color(v['color'] as int),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(v['borderRadius'] as double)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Card Content', style: TextStyle(color: Colors.white)),
        ),
      ),
      codeBuilder: (v) => '''
Card(
  elevation: ${v['elevation']},
  color: const Color(0x${(v['color'] as int).toRadixString(16)}),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(${v['borderRadius']}),
  ),
  child: const Padding(
    padding: EdgeInsets.all(16.0),
    child: Text('Card Content'),
  ),
)''',
    );
  }

  WidgetTemplate _listViewTemplate() {
    return WidgetTemplate(
      id: 'list_view',
      name: 'ListView.builder',
      category: 'Layout',
      icon: LucideIcons.list,
      properties: [
        const PropertyDefinition(key: 'itemCount', label: 'Item Count', type: PropertyType.slider, defaultValue: 5.0, min: 1, max: 20),
        const PropertyDefinition(key: 'padding', label: 'Padding', type: PropertyType.slider, defaultValue: 16.0, min: 0, max: 40),
      ],
      widgetBuilder: (v) => SizedBox(
        height: 200,
        child: ListView.builder(
          padding: EdgeInsets.all(v['padding'] as double),
          itemCount: (v['itemCount'] as double).toInt(),
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.circle, size: 12, color: Colors.blue),
            title: Text('Item \$index', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
      codeBuilder: (v) => '''
ListView.builder(
  padding: const EdgeInsets.all(${v['padding']}),
  itemCount: ${(v['itemCount'] as double).toInt()},
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('Item \\\$index'),
    );
  },
)''',
    );
  }

  WidgetTemplate _chipTemplate() {
    return WidgetTemplate(
      id: 'chip',
      name: 'Chip',
      category: 'Display',
      icon: LucideIcons.tag,
      properties: [
        const PropertyDefinition(key: 'label', label: 'Label', type: PropertyType.textInput, defaultValue: 'Flutter'),
        const PropertyDefinition(key: 'backgroundColor', label: 'Background Color', type: PropertyType.colorPicker, defaultValue: 0xFF3B82F6),
      ],
      widgetBuilder: (v) => Chip(
        label: Text(v['label'] as String),
        backgroundColor: Color(v['backgroundColor'] as int),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      codeBuilder: (v) => '''
Chip(
  label: const Text('${v['label']}'),
  backgroundColor: const Color(0x${(v['backgroundColor'] as int).toRadixString(16)}),
  labelStyle: const TextStyle(color: Colors.white),
)''',
    );
  }
}

@riverpod
WidgetRegistry widgetRegistry(WidgetRegistryRef ref) {
  return WidgetRegistry();
}
