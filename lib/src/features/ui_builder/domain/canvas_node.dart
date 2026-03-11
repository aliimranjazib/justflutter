import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widget types supported by the canvas
// ─────────────────────────────────────────────────────────────────────────────

enum CanvasWidgetType {
  // Display
  text,
  icon,
  image,
  divider,
  progressIndicator,
  // Layout
  container,
  sizedBox,
  center,
  padding,
  row,
  column,
  // Input
  elevatedButton,
  outlinedButton,
  textButton,
  textField,
  switchWidget,
  checkboxWidget,
  // Compound
  card,
  listTile,
  chip,
  floatingActionButton,
}

// Meta info shown in the palette
class PaletteEntry {
  const PaletteEntry({
    required this.type,
    required this.label,
    required this.icon,
    required this.category,
  });
  final CanvasWidgetType type;
  final String label;
  final IconData icon;
  final String category;
}

const kPalette = <PaletteEntry>[
  // Display
  PaletteEntry(type: CanvasWidgetType.text, label: 'Text', icon: Icons.text_fields, category: 'Display'),
  PaletteEntry(type: CanvasWidgetType.icon, label: 'Icon', icon: Icons.star_border, category: 'Display'),
  PaletteEntry(type: CanvasWidgetType.image, label: 'Image', icon: Icons.image_outlined, category: 'Display'),
  PaletteEntry(type: CanvasWidgetType.divider, label: 'Divider', icon: Icons.horizontal_rule, category: 'Display'),
  PaletteEntry(type: CanvasWidgetType.progressIndicator, label: 'Progress', icon: Icons.refresh, category: 'Display'),
  // Layout
  PaletteEntry(type: CanvasWidgetType.container, label: 'Container', icon: Icons.crop_square, category: 'Layout'),
  PaletteEntry(type: CanvasWidgetType.sizedBox, label: 'SizedBox', icon: Icons.space_bar, category: 'Layout'),
  PaletteEntry(type: CanvasWidgetType.center, label: 'Center', icon: Icons.filter_center_focus, category: 'Layout'),
  PaletteEntry(type: CanvasWidgetType.padding, label: 'Padding', icon: Icons.padding, category: 'Layout'),
  PaletteEntry(type: CanvasWidgetType.row, label: 'Row', icon: Icons.view_column_outlined, category: 'Layout'),
  PaletteEntry(type: CanvasWidgetType.column, label: 'Column', icon: Icons.view_agenda_outlined, category: 'Layout'),
  // Input
  PaletteEntry(type: CanvasWidgetType.elevatedButton, label: 'ElevatedButton', icon: Icons.smart_button, category: 'Input'),
  PaletteEntry(type: CanvasWidgetType.outlinedButton, label: 'OutlinedButton', icon: Icons.radio_button_unchecked, category: 'Input'),
  PaletteEntry(type: CanvasWidgetType.textButton, label: 'TextButton', icon: Icons.title, category: 'Input'),
  PaletteEntry(type: CanvasWidgetType.textField, label: 'TextField', icon: Icons.text_format, category: 'Input'),
  PaletteEntry(type: CanvasWidgetType.switchWidget, label: 'Switch', icon: Icons.toggle_on_outlined, category: 'Input'),
  PaletteEntry(type: CanvasWidgetType.checkboxWidget, label: 'Checkbox', icon: Icons.check_box_outlined, category: 'Input'),
  // Compound
  PaletteEntry(type: CanvasWidgetType.card, label: 'Card', icon: Icons.credit_card, category: 'Compound'),
  PaletteEntry(type: CanvasWidgetType.listTile, label: 'ListTile', icon: Icons.list, category: 'Compound'),
  PaletteEntry(type: CanvasWidgetType.chip, label: 'Chip', icon: Icons.label_outline, category: 'Compound'),
  PaletteEntry(type: CanvasWidgetType.floatingActionButton, label: 'FAB', icon: Icons.add_circle_outline, category: 'Compound'),
];

// ─────────────────────────────────────────────────────────────────────────────
// CanvasNode — the tree node
// ─────────────────────────────────────────────────────────────────────────────

class CanvasNode {
  CanvasNode({
    required this.id,
    required this.type,
    Map<String, dynamic>? props,
    List<CanvasNode>? children,
  })  : props = props ?? _defaultProps(type),
        children = children ?? [];

  final String id;
  final CanvasWidgetType type;
  final Map<String, dynamic> props;
  final List<CanvasNode> children;

  CanvasNode copyWith({
    Map<String, dynamic>? props,
    List<CanvasNode>? children,
  }) {
    return CanvasNode(
      id: id,
      type: type,
      props: props ?? Map<String, dynamic>.from(this.props),
      children: children ?? List<CanvasNode>.from(this.children),
    );
  }

  String get label => _labelOf(type);
}

String _labelOf(CanvasWidgetType t) {
  return kPalette.firstWhere((e) => e.type == t).label;
}

Map<String, dynamic> _defaultProps(CanvasWidgetType type) {
  return switch (type) {
    CanvasWidgetType.text => {
        'text': 'Hello, Flutter!',
        'fontSize': 16.0,
        'fontWeight': 'normal',
        'color': 0xFF212121,
        'textAlign': 'left',
      },
    CanvasWidgetType.icon => {
        'icon': 'favorite',
        'size': 32.0,
        'color': 0xFF6366F1,
      },
    CanvasWidgetType.image => {
        'url': 'https://picsum.photos/300/200',
        'width': 300.0,
        'height': 200.0,
        'fit': 'cover',
        'borderRadius': 8.0,
      },
    CanvasWidgetType.divider => {
        'thickness': 1.0,
        'color': 0xFFE0E0E0,
        'indent': 0.0,
      },
    CanvasWidgetType.progressIndicator => {
        'color': 0xFF6366F1,
        'size': 32.0,
      },
    CanvasWidgetType.container => {
        'color': 0xFF4FC3F7,
        'width': 200.0,
        'height': 100.0,
        'borderRadius': 8.0,
        'paddingAll': 16.0,
      },
    CanvasWidgetType.sizedBox => {
        'width': 64.0,
        'height': 16.0,
      },
    CanvasWidgetType.center => {
        'label': 'Center',
      },
    CanvasWidgetType.padding => {
        'paddingAll': 16.0,
      },
    CanvasWidgetType.row => {
        'mainAxisAlignment': 'start',
        'spacing': 8.0,
      },
    CanvasWidgetType.column => {
        'mainAxisAlignment': 'start',
        'spacing': 8.0,
      },
    CanvasWidgetType.elevatedButton => {
        'label': 'Click Me',
        'color': 0xFF6366F1,
        'textColor': 0xFFFFFFFF,
        'borderRadius': 8.0,
      },
    CanvasWidgetType.outlinedButton => {
        'label': 'Click Me',
        'color': 0xFF6366F1,
        'borderRadius': 8.0,
      },
    CanvasWidgetType.textButton => {
        'label': 'Click Me',
        'color': 0xFF6366F1,
      },
    CanvasWidgetType.textField => {
        'hintText': 'Enter text...',
        'labelText': 'Label',
        'borderRadius': 8.0,
      },
    CanvasWidgetType.switchWidget => {
        'value': true,
        'activeColor': 0xFF6366F1,
      },
    CanvasWidgetType.checkboxWidget => {
        'value': true,
        'label': 'Check me',
        'activeColor': 0xFF6366F1,
      },
    CanvasWidgetType.card => {
        'elevation': 2.0,
        'color': 0xFFFFFFFF,
        'borderRadius': 12.0,
        'paddingAll': 16.0,
      },
    CanvasWidgetType.listTile => {
        'title': 'List Item',
        'subtitle': 'Subtitle text',
        'icon': 'inbox',
        'iconColor': 0xFF6366F1,
      },
    CanvasWidgetType.chip => {
        'label': 'Chip',
        'color': 0xFF6366F1,
        'textColor': 0xFFFFFFFF,
      },
    CanvasWidgetType.floatingActionButton => {
        'icon': 'add',
        'color': 0xFF6366F1,
        'tooltip': 'Add',
      },
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Code generator
// ─────────────────────────────────────────────────────────────────────────────

String generateCode(List<CanvasNode> nodes) {
  if (nodes.isEmpty) return '// Drag widgets onto the canvas to generate code';

  final buf = StringBuffer();
  buf.writeln('// Generated by JustFlutter UI Builder');
  buf.writeln('// ─────────────────────────────────────');
  buf.writeln('Column(');
  buf.writeln('  children: [');
  for (final node in nodes) {
    buf.write(_nodeCode(node, indent: 4));
    buf.writeln(',');
  }
  buf.writeln('  ],');
  buf.write(')');
  return buf.toString();
}

String _nodeCode(CanvasNode node, {int indent = 0}) {
  final pad = ' ' * indent;
  final p = node.props;

  String hexColor(int argb) {
    final hex = argb.toRadixString(16).padLeft(8, '0').toUpperCase();
    return 'const Color(0x$hex)';
  }

  switch (node.type) {
    case CanvasWidgetType.text:
      final fw = p['fontWeight'] == 'bold' ? 'FontWeight.bold' : 'FontWeight.normal';
      final ta = switch (p['textAlign']) {
        'center' => 'TextAlign.center',
        'right' => 'TextAlign.right',
        _ => 'TextAlign.left'
      };
      return '''${pad}Text(
${pad}  '${p['text']}',
${pad}  textAlign: $ta,
${pad}  style: const TextStyle(
${pad}    fontSize: ${p['fontSize']},
${pad}    fontWeight: $fw,
${pad}    color: ${hexColor(p['color'])},
${pad}  ),
${pad})''';

    case CanvasWidgetType.icon:
      return '''${pad}Icon(
${pad}  Icons.${p['icon']},
${pad}  size: ${p['size']},
${pad}  color: ${hexColor(p['color'])},
${pad})''';

    case CanvasWidgetType.image:
      return '''${pad}ClipRRect(
${pad}  borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}  child: Image.network(
${pad}    '${p['url']}',
${pad}    width: ${p['width']},
${pad}    height: ${p['height']},
${pad}    fit: BoxFit.${p['fit']},
${pad}  ),
${pad})''';

    case CanvasWidgetType.divider:
      return '''${pad}Divider(
${pad}  thickness: ${p['thickness']},
${pad}  indent: ${p['indent']},
${pad}  color: ${hexColor(p['color'])},
${pad})''';

    case CanvasWidgetType.progressIndicator:
      return '''${pad}SizedBox(
${pad}  width: ${p['size']},
${pad}  height: ${p['size']},
${pad}  child: CircularProgressIndicator(
${pad}    color: ${hexColor(p['color'])},
${pad}  ),
${pad})''';

    case CanvasWidgetType.container:
      final childCode = node.children.isEmpty
          ? ''
          : '\n${_nodeCode(node.children.first, indent: indent + 2)},\n$pad';
      return '''${pad}Container(
${pad}  width: ${p['width']},
${pad}  height: ${p['height']},
${pad}  padding: const EdgeInsets.all(${p['paddingAll']}),
${pad}  decoration: BoxDecoration(
${pad}    color: ${hexColor(p['color'])},
${pad}    borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}  ),${childCode.isEmpty ? '' : '\n${pad}  child: $childCode'}
${pad})''';

    case CanvasWidgetType.sizedBox:
      return '${pad}const SizedBox(width: ${p['width']}, height: ${p['height']})';

    case CanvasWidgetType.center:
      final inner = node.children.isEmpty
          ? '${pad}  const SizedBox()'
          : _nodeCode(node.children.first, indent: indent + 2);
      return '${pad}Center(\n${pad}  child:\n$inner,\n${pad})';

    case CanvasWidgetType.padding:
      final inner = node.children.isEmpty
          ? '${pad}  const SizedBox()'
          : _nodeCode(node.children.first, indent: indent + 2);
      return '${pad}Padding(\n${pad}  padding: const EdgeInsets.all(${p['paddingAll']}),\n${pad}  child:\n$inner,\n${pad})';

    case CanvasWidgetType.row:
      final maa = 'MainAxisAlignment.${p['mainAxisAlignment']}';
      final childrenCode = node.children.isEmpty
          ? '${pad}    const SizedBox(width: 8), const SizedBox(width: 8),'
          : node.children.map((c) => '${_nodeCode(c, indent: indent + 4)},').join('\n');
      return '${pad}Row(\n${pad}  mainAxisAlignment: $maa,\n${pad}  children: [\n$childrenCode\n${pad}  ],\n${pad})';

    case CanvasWidgetType.column:
      final maa = 'MainAxisAlignment.${p['mainAxisAlignment']}';
      final childrenCode = node.children.isEmpty
          ? '${pad}    const SizedBox(),'
          : node.children.map((c) => '${_nodeCode(c, indent: indent + 4)},').join('\n');
      return '${pad}Column(\n${pad}  mainAxisAlignment: $maa,\n${pad}  children: [\n$childrenCode\n${pad}  ],\n${pad})';

    case CanvasWidgetType.elevatedButton:
      return '''${pad}ElevatedButton(
${pad}  onPressed: () {},
${pad}  style: ElevatedButton.styleFrom(
${pad}    backgroundColor: ${hexColor(p['color'])},
${pad}    foregroundColor: ${hexColor(p['textColor'])},
${pad}    shape: RoundedRectangleBorder(
${pad}      borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}    ),
${pad}  ),
${pad}  child: const Text('${p['label']}'),
${pad})''';

    case CanvasWidgetType.outlinedButton:
      return '''${pad}OutlinedButton(
${pad}  onPressed: () {},
${pad}  style: OutlinedButton.styleFrom(
${pad}    foregroundColor: ${hexColor(p['color'])},
${pad}    side: BorderSide(color: ${hexColor(p['color'])}),
${pad}    shape: RoundedRectangleBorder(
${pad}      borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}    ),
${pad}  ),
${pad}  child: const Text('${p['label']}'),
${pad})''';

    case CanvasWidgetType.textButton:
      return '''${pad}TextButton(
${pad}  onPressed: () {},
${pad}  style: TextButton.styleFrom(
${pad}    foregroundColor: ${hexColor(p['color'])},
${pad}  ),
${pad}  child: const Text('${p['label']}'),
${pad})''';

    case CanvasWidgetType.textField:
      return '''${pad}TextField(
${pad}  decoration: InputDecoration(
${pad}    labelText: '${p['labelText']}',
${pad}    hintText: '${p['hintText']}',
${pad}    border: OutlineInputBorder(
${pad}      borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}    ),
${pad}  ),
${pad})''';

    case CanvasWidgetType.switchWidget:
      return '${pad}Switch(value: ${p['value']}, activeColor: ${hexColor(p['activeColor'])}, onChanged: (_) {})';

    case CanvasWidgetType.checkboxWidget:
      return '''${pad}Row(
${pad}  mainAxisSize: MainAxisSize.min,
${pad}  children: [
${pad}    Checkbox(value: ${p['value']}, activeColor: ${hexColor(p['activeColor'])}, onChanged: (_) {}),
${pad}    const Text('${p['label']}'),
${pad}  ],
${pad})''';

    case CanvasWidgetType.card:
      final inner = node.children.isEmpty
          ? '${pad}    const Text(\'Card content\')'
          : _nodeCode(node.children.first, indent: indent + 4);
      return '''${pad}Card(
${pad}  elevation: ${p['elevation']},
${pad}  color: ${hexColor(p['color'])},
${pad}  shape: RoundedRectangleBorder(
${pad}    borderRadius: BorderRadius.circular(${p['borderRadius']}),
${pad}  ),
${pad}  child: Padding(
${pad}    padding: const EdgeInsets.all(${p['paddingAll']}),
${pad}    child:
$inner,
${pad}  ),
${pad})''';

    case CanvasWidgetType.listTile:
      return '''${pad}ListTile(
${pad}  leading: Icon(Icons.${p['icon']}, color: ${hexColor(p['iconColor'])}),
${pad}  title: const Text('${p['title']}'),
${pad}  subtitle: const Text('${p['subtitle']}'),
${pad}  onTap: () {},
${pad})''';

    case CanvasWidgetType.chip:
      return '''${pad}Chip(
${pad}  label: const Text('${p['label']}'),
${pad}  backgroundColor: ${hexColor(p['color'])},
${pad}  labelStyle: const TextStyle(color: ${hexColor(p['textColor'])}),
${pad})''';

    case CanvasWidgetType.floatingActionButton:
      return '''${pad}FloatingActionButton(
${pad}  onPressed: () {},
${pad}  backgroundColor: ${hexColor(p['color'])},
${pad}  tooltip: '${p['tooltip']}',
${pad}  child: const Icon(Icons.${p['icon']}),
${pad})''';
  }
}
