import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';
import '../domain/canvas_node.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Drag and Drop Payloads
// ─────────────────────────────────────────────────────────────────────────────

sealed class DragPayload {}

class NewWidgetPayload extends DragPayload {
  NewWidgetPayload(this.type);
  final CanvasWidgetType type;
}

class MoveWidgetPayload extends DragPayload {
  MoveWidgetPayload(this.id);
  final String id;
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple in-memory state
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasState extends ChangeNotifier {
  final List<CanvasNode> nodes = [];
  String? selectedId;

  CanvasNode? get selected =>
      selectedId == null ? null : _findNode(nodes, selectedId!);

  String _uid() => Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');

  void addNode(CanvasWidgetType type, {int? atIndex}) {
    final node = CanvasNode(id: _uid(), type: type);
    if (atIndex != null && atIndex <= nodes.length) {
      nodes.insert(atIndex, node);
    } else {
      nodes.add(node);
    }
    selectedId = node.id;
    notifyListeners();
  }

  void moveNode(String id, int toIndex) {
    int fromIndex = nodes.indexWhere((n) => n.id == id);
    if (fromIndex == -1) {
      // Check children recursively if needed, but for now we only support top-level reorder
      return;
    }
    
    final node = nodes.removeAt(fromIndex);
    // If we removed a node before the target index, the target index shifts down
    int correctedIndex = toIndex;
    if (fromIndex < toIndex) correctedIndex--;
    
    nodes.insert(correctedIndex.clamp(0, nodes.length), node);
    selectedId = id;
    notifyListeners();
  }

  void removeSelected() {
    if (selectedId == null) return;
    _removeById(nodes, selectedId!);
    selectedId = null;
    notifyListeners();
  }

  void selectNode(String id) {
    selectedId = id;
    notifyListeners();
  }

  void deselectAll() {
    selectedId = null;
    notifyListeners();
  }

  void updateProp(String key, dynamic value) {
    final node = selected;
    if (node == null) return;
    node.props[key] = value;
    notifyListeners();
  }

  void moveUp() {
    if (selectedId == null) return;
    final i = nodes.indexWhere((n) => n.id == selectedId);
    if (i <= 0) return;
    final tmp = nodes[i];
    nodes[i] = nodes[i - 1];
    nodes[i - 1] = tmp;
    notifyListeners();
  }

  void moveDown() {
    if (selectedId == null) return;
    final i = nodes.indexWhere((n) => n.id == selectedId);
    if (i < 0 || i >= nodes.length - 1) return;
    final tmp = nodes[i];
    nodes[i] = nodes[i + 1];
    nodes[i + 1] = tmp;
    notifyListeners();
  }

  void clearAll() {
    nodes.clear();
    selectedId = null;
    notifyListeners();
  }

  void addChildToSelected(CanvasWidgetType type) {
    final node = selected;
    if (node == null) return;
    node.children.add(CanvasNode(id: _uid(), type: type));
    notifyListeners();
  }

  // ── helpers ─────────────────────────────────────────────────────────────────
  static CanvasNode? _findNode(List<CanvasNode> list, String id) {
    for (final n in list) {
      if (n.id == id) return n;
      final child = _findNode(n.children, id);
      if (child != null) return child;
    }
    return null;
  }

  static bool _removeById(List<CanvasNode> list, String id) {
    final i = list.indexWhere((n) => n.id == id);
    if (i >= 0) {
      list.removeAt(i);
      return true;
    }
    for (final n in list) {
      if (_removeById(n.children, id)) return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class UiBuilderScreen extends StatefulWidget {
  const UiBuilderScreen({super.key});

  @override
  State<UiBuilderScreen> createState() => _UiBuilderScreenState();
}

class _UiBuilderScreenState extends State<UiBuilderScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFF6366F1);

  final _state = _CanvasState();
  late final TabController _rightTabCtrl;

  @override
  void initState() {
    super.initState();
    _rightTabCtrl = TabController(length: 2, vsync: this);
    _state.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _rightTabCtrl.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 1000;

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: isWide
          ? Row(children: [
              SizedBox(width: 220, child: _PalettePanel(state: _state)),
              Container(width: 1, color: _border),
              Expanded(child: _CanvasArea(state: _state)),
              Container(width: 1, color: _border),
              SizedBox(width: 300, child: _RightPanel(state: _state, tabCtrl: _rightTabCtrl)),
            ])
          : Column(children: [
              SizedBox(height: 200, child: _PalettePanel(state: _state, horizontal: true)),
              Container(height: 1, color: _border),
              Expanded(child: _CanvasArea(state: _state)),
            ]),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.drag_indicator, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text('UI Builder',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text('${_state.nodes.length} widgets',
                style: GoogleFonts.inter(fontSize: 11, color: _accent)),
          ),
        ],
      ),
      actions: [
        if (_state.nodes.isNotEmpty) ...[
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 16,
                color: Colors.red.withValues(alpha: 0.7)),
            tooltip: 'Clear canvas',
            onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                backgroundColor: _surface,
                title: Text('Clear canvas?',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
                  ElevatedButton(
                      onPressed: () { _state.clearAll(); Navigator.pop(context); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Clear', style: GoogleFonts.inter())),
                ],
              ));
            },
          ),
        ],
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _border, height: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left: Widget Palette
// ─────────────────────────────────────────────────────────────────────────────

class _PalettePanel extends StatelessWidget {
  const _PalettePanel({required this.state, this.horizontal = false});
  final _CanvasState state;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PaletteEntry>>{};
    for (final e in kPalette) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }

    if (horizontal) {
      return Container(
        color: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: kPalette.map((e) => _PaletteTile(entry: e, state: state)).toList(),
        ),
      );
    }

    return Container(
      color: const Color(0xFF111111),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
            child: Text('WIDGETS',
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.3), letterSpacing: 1.1)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: Text(entry.key.toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.2), letterSpacing: 0.8)),
                    ),
                    ...entry.value.map((e) => _PaletteTile(entry: e, state: state)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.entry, required this.state});
  final PaletteEntry entry;
  final _CanvasState state;

  @override
  Widget build(BuildContext context) {
    return Draggable<DragPayload>(
      data: NewWidgetPayload(entry.type),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(entry.label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _tileContent()),
      child: GestureDetector(
        onTap: () => state.addNode(entry.type),
        child: _tileContent(),
      ),
    );
  }

  Widget _tileContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
        child: Row(
          children: [
            Icon(entry.icon, size: 15, color: Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 8),
            Text(entry.label,
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center: Canvas
// ─────────────────────────────────────────────────────────────────────────────

class _CanvasArea extends StatelessWidget {
  const _CanvasArea({required this.state});
  final _CanvasState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      child: Column(
        children: [
          // Top bar
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.phone_iphone, size: 14, color: Colors.white30),
                const SizedBox(width: 6),
                Text('Canvas Preview',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white30)),
                const Spacer(),
                Text('Drag widgets from the panel or tap to add',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white24)),
              ],
            ),
          ),
          // Canvas scroll area
          Expanded(
            child: GestureDetector(
              onTap: () => state.deselectAll(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    width: 390,
                    constraints: const BoxConstraints(minHeight: 600),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 40, spreadRadius: 4),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildDroppableCanvas(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDroppableCanvas(BuildContext context) {
    if (state.nodes.isEmpty) {
      return DragTarget<DragPayload>(
        onAcceptWithDetails: (d) {
          final payload = d.data;
          if (payload is NewWidgetPayload) {
            state.addNode(payload.type);
          }
        },
        builder: (_, candidateData, __) {
          final hover = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 600),
            decoration: BoxDecoration(
              color: hover ? const Color(0xFFF5F3FF) : Colors.white,
              border: hover
                  ? Border.all(color: const Color(0xFF6366F1), width: 3)
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drag_indicator,
                      size: 48,
                      color: hover ? const Color(0xFF6366F1) : Colors.black12),
                  const SizedBox(height: 12),
                  Text(
                    hover ? 'Drop here!' : 'Drag widgets here\nor tap them in the palette',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: hover ? const Color(0xFF6366F1) : Colors.black26,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drop zone at top
        _DropZone(state: state, index: 0),
        ...state.nodes.asMap().entries.expand((entry) => [
              _CanvasTile(node: entry.value, state: state),
              _DropZone(state: state, index: entry.key + 1),
            ]),
      ],
    );
  }
}

// Invisible drop zone between widgets
class _DropZone extends StatefulWidget {
  const _DropZone({required this.state, required this.index});
  final _CanvasState state;
  final int index;

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hover = true);
        return true;
      },
      onLeave: (_) => setState(() => _hover = false),
      onAcceptWithDetails: (d) {
        setState(() => _hover = false);
        final payload = d.data;
        if (payload is NewWidgetPayload) {
          widget.state.addNode(payload.type, atIndex: widget.index);
        } else if (payload is MoveWidgetPayload) {
          widget.state.moveNode(payload.id, widget.index);
        }
      },
      builder: (_, candidateData, __) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _hover ? 54 : 12,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hover
                ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _hover
                ? Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.5), width: 2)
                : null,
          ),
          child: _hover
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 8),
                      Text('Drop to place here',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF6366F1),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

// Each widget tile on the canvas
class _CanvasTile extends StatelessWidget {
  const _CanvasTile({required this.node, required this.state});
  final CanvasNode node;
  final _CanvasState state;

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedId == node.id;

    return Draggable<DragPayload>(
      data: MoveWidgetPayload(node.id),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6366F1), width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2)
            ],
          ),
          child: Opacity(
            opacity: 0.8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.drag_handle, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 10),
                Text('Moving ${node.label}...',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
              child: Text('Moving ${node.label}',
                  style: const TextStyle(fontSize: 10))),
        ),
      ),
      child: GestureDetector(
        onTap: () => state.selectNode(node.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: const Color(0xFF6366F1), width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: _WidgetRenderer.render(node),
              ),
              // selection label
              if (isSelected)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4)),
                    ),
                    child: Text(node.label,
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget Renderer — renders CanvasNode as actual Flutter widget
// ─────────────────────────────────────────────────────────────────────────────

class _WidgetRenderer {
  static Widget render(CanvasNode node) {
    final p = node.props;

    Color c(String key) => Color(p[key] as int);

    switch (node.type) {
      case CanvasWidgetType.text:
        final fwStr = p['fontWeight'] as String;
        return Text(
          p['text'] as String,
          textAlign: switch (p['textAlign']) {
            'center' => TextAlign.center,
            'right' => TextAlign.right,
            _ => TextAlign.left
          },
          style: TextStyle(
            fontSize: (p['fontSize'] as num).toDouble(),
            fontWeight: fwStr == 'bold' ? FontWeight.bold : FontWeight.normal,
            color: c('color'),
          ),
        );

      case CanvasWidgetType.icon:
        return Icon(Icons.favorite, size: (p['size'] as num).toDouble(), color: c('color'));

      case CanvasWidgetType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble()),
          child: Image.network(
            p['url'] as String,
            width: (p['width'] as num).toDouble(),
            height: (p['height'] as num).toDouble(),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: (p['width'] as num).toDouble(),
              height: (p['height'] as num).toDouble(),
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );

      case CanvasWidgetType.divider:
        return Divider(
            thickness: (p['thickness'] as num).toDouble(),
            color: c('color'),
            indent: (p['indent'] as num).toDouble());

      case CanvasWidgetType.progressIndicator:
        return Center(
          child: SizedBox(
            width: (p['size'] as num).toDouble(),
            height: (p['size'] as num).toDouble(),
            child: CircularProgressIndicator(color: c('color'), strokeWidth: 3),
          ),
        );

      case CanvasWidgetType.container:
        return Container(
          width: (p['width'] as num).toDouble(),
          height: (p['height'] as num).toDouble(),
          padding: EdgeInsets.all((p['paddingAll'] as num).toDouble()),
          decoration: BoxDecoration(
            color: c('color'),
            borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble()),
          ),
          child: node.children.isEmpty ? null : render(node.children.first),
        );

      case CanvasWidgetType.sizedBox:
        return SizedBox(
            width: (p['width'] as num).toDouble(),
            height: (p['height'] as num).toDouble());

      case CanvasWidgetType.center:
        return Center(
            child: node.children.isEmpty
                ? const Text('(drop a widget inside)',
                    style: TextStyle(color: Colors.grey, fontSize: 11))
                : render(node.children.first));

      case CanvasWidgetType.padding:
        return Padding(
          padding: EdgeInsets.all((p['paddingAll'] as num).toDouble()),
          child: node.children.isEmpty
              ? const Text('(drop a widget inside)',
                  style: TextStyle(color: Colors.grey, fontSize: 11))
              : render(node.children.first),
        );

      case CanvasWidgetType.row:
        final maa = switch (p['mainAxisAlignment']) {
          'center' => MainAxisAlignment.center,
          'end' => MainAxisAlignment.end,
          'spaceBetween' => MainAxisAlignment.spaceBetween,
          'spaceAround' => MainAxisAlignment.spaceAround,
          _ => MainAxisAlignment.start
        };
        return Row(
          mainAxisAlignment: maa,
          children: node.children.isEmpty
              ? [const Text('(add children)', style: TextStyle(color: Colors.grey, fontSize: 11))]
              : node.children.map(render).toList(),
        );

      case CanvasWidgetType.column:
        final maa = switch (p['mainAxisAlignment']) {
          'center' => MainAxisAlignment.center,
          'end' => MainAxisAlignment.end,
          'spaceBetween' => MainAxisAlignment.spaceBetween,
          _ => MainAxisAlignment.start
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: maa,
          children: node.children.isEmpty
              ? [const Text('(add children)', style: TextStyle(color: Colors.grey, fontSize: 11))]
              : node.children.map(render).toList(),
        );

      case CanvasWidgetType.elevatedButton:
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: c('color'),
            foregroundColor: c('textColor'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble())),
          ),
          child: Text(p['label'] as String),
        );

      case CanvasWidgetType.outlinedButton:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: c('color'),
            side: BorderSide(color: c('color')),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble())),
          ),
          child: Text(p['label'] as String),
        );

      case CanvasWidgetType.textButton:
        return TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: c('color')),
          child: Text(p['label'] as String),
        );

      case CanvasWidgetType.textField:
        return TextField(
          decoration: InputDecoration(
            labelText: p['labelText'] as String,
            hintText: p['hintText'] as String,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble())),
            isDense: true,
            contentPadding: const EdgeInsets.all(10),
          ),
        );

      case CanvasWidgetType.switchWidget:
        return Switch(value: p['value'] as bool, activeColor: c('activeColor'), onChanged: (_) {});

      case CanvasWidgetType.checkboxWidget:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(value: p['value'] as bool, activeColor: c('activeColor'), onChanged: (_) {}),
            Text(p['label'] as String),
          ],
        );

      case CanvasWidgetType.card:
        return Card(
          elevation: (p['elevation'] as num).toDouble(),
          color: c('color'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((p['borderRadius'] as num).toDouble())),
          child: Padding(
            padding: EdgeInsets.all((p['paddingAll'] as num).toDouble()),
            child: node.children.isEmpty
                ? const Text('Card content', style: TextStyle(color: Colors.black87))
                : render(node.children.first),
          ),
        );

      case CanvasWidgetType.listTile:
        return ListTile(
          leading: Icon(Icons.inbox, color: c('iconColor')),
          title: Text(p['title'] as String),
          subtitle: Text(p['subtitle'] as String),
          onTap: () {},
        );

      case CanvasWidgetType.chip:
        return Chip(
          label: Text(p['label'] as String,
              style: TextStyle(color: c('textColor'), fontSize: 12)),
          backgroundColor: c('color'),
        );

      case CanvasWidgetType.floatingActionButton:
        return FloatingActionButton(
          onPressed: () {},
          backgroundColor: c('color'),
          mini: true,
          child: const Icon(Icons.add, color: Colors.white),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right: Properties + Code Panel
// ─────────────────────────────────────────────────────────────────────────────

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.state, required this.tabCtrl});
  final _CanvasState state;
  final TabController tabCtrl;

  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: Column(
        children: [
          TabBar(
            controller: tabCtrl,
            indicatorColor: _accent,
            labelColor: _accent,
            unselectedLabelColor: Colors.white38,
            labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Properties'), Tab(text: 'Code')],
          ),
          Container(height: 1, color: _border),
          Expanded(
            child: TabBarView(
              controller: tabCtrl,
              children: [
                _PropertiesTab(state: state),
                _CodeTab(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Properties tab ───────────────────────────────────────────────────────────

class _PropertiesTab extends StatelessWidget {
  const _PropertiesTab({required this.state});
  final _CanvasState state;

  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final node = state.selected;

    if (node == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_outlined, size: 40, color: Colors.white12),
            const SizedBox(height: 12),
            Text('Select a widget\nto edit its properties',
                style: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Widget label + up/down/delete
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(kPalette.firstWhere((e) => e.type == node.type).icon,
                  size: 16, color: _accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(node.label,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward, size: 14, color: Colors.white54),
                onPressed: state.moveUp,
                tooltip: 'Move up',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward, size: 14, color: Colors.white54),
                onPressed: state.moveDown,
                tooltip: 'Move down',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 14, color: Colors.red.withValues(alpha: 0.7)),
                onPressed: state.removeSelected,
                tooltip: 'Remove',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Dynamic property fields
        ..._buildProps(node, context),
        // Children section
        if (_isContainer(node.type)) ...[
          const SizedBox(height: 16),
          _propLabel('CHILD WIDGETS'),
          const SizedBox(height: 8),
          if (node.children.isEmpty)
            Text('No children. Tap + to add one.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12))
          else
            ...node.children.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Icon(kPalette.firstWhere((e) => e.type == c.type).icon,
                            size: 13, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(c.label,
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: 8),
          PopupMenuButton<CanvasWidgetType>(
            color: const Color(0xFF1A1A1A),
            tooltip: 'Add child widget',
            onSelected: state.addChildToSelected,
            itemBuilder: (_) => kPalette
                .map((e) => PopupMenuItem(
                      value: e.type,
                      child: Row(children: [
                        Icon(e.icon, size: 14, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(e.label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ]),
                    ))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: _accent.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 14, color: Color(0xFF6366F1)),
                  const SizedBox(width: 6),
                  Text('Add child widget',
                      style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF6366F1))),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _isContainer(CanvasWidgetType t) => [
        CanvasWidgetType.container,
        CanvasWidgetType.card,
        CanvasWidgetType.center,
        CanvasWidgetType.padding,
        CanvasWidgetType.row,
        CanvasWidgetType.column,
      ].contains(t);

  List<Widget> _buildProps(CanvasNode node, BuildContext context) {
    final widgets = <Widget>[];
    node.props.forEach((key, value) {
      if (value is String) {
        widgets.add(_StringProp(label: key, value: value, onChanged: (v) => node.props[key] = v));
      } else if (value is double || value is int) {
        widgets.add(_SliderProp(
          label: key,
          value: (value as num).toDouble(),
          min: _sliderMin(key),
          max: _sliderMax(key),
          onChanged: (v) => state.updateProp(key, v),
        ));
      } else if (value is bool) {
        widgets.add(_BoolProp(
          label: key,
          value: value,
          onChanged: (v) => state.updateProp(key, v),
        ));
      } else if (value is int && key.contains('color') || key == 'color' || key.endsWith('Color')) {
        widgets.add(_ColorPropRow(
          label: key,
          argb: value as int,
          onChanged: (v) => state.updateProp(key, v),
          context: context,
        ));
      }
    });
    return widgets;
  }

  double _sliderMin(String key) {
    if (key.contains('Radius') || key.contains('radius')) return 0;
    if (key.contains('size') || key == 'size') return 8;
    if (key.contains('elevation')) return 0;
    if (key.contains('thickness')) return 0.5;
    if (key.contains('fontSize')) return 8;
    return 0;
  }

  double _sliderMax(String key) {
    if (key.contains('Radius') || key.contains('radius')) return 50;
    if (key == 'width') return 390;
    if (key == 'height') return 400;
    if (key == 'size') return 64;
    if (key.contains('padding') || key.contains('indent')) return 64;
    if (key.contains('elevation')) return 20;
    if (key.contains('thickness')) return 10;
    if (key.contains('fontSize')) return 48;
    if (key.contains('spacing')) return 32;
    return 200;
  }

  Widget _propLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 1.1)),
      );
}

class _StringProp extends StatefulWidget {
  const _StringProp({required this.label, required this.value, required this.onChanged});
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_StringProp> createState() => _StringPropState();
}

class _StringPropState extends State<_StringProp> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_StringProp old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formatLabel(widget.label),
              style: GoogleFonts.inter(fontSize: 9, color: Colors.white30, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0A0A0A),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.white12)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.white12)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Color(0xFF6366F1))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderProp extends StatelessWidget {
  const _SliderProp({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final double value;
  final double min, max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatLabel(label),
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white30, letterSpacing: 0.8)),
              Text(value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                  style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white54)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
            ),
            child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _BoolProp extends StatelessWidget {
  const _BoolProp({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(_formatLabel(label),
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70))),
          Switch(value: value, activeColor: const Color(0xFF6366F1), onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ColorPropRow extends StatelessWidget {
  const _ColorPropRow({
    required this.label,
    required this.argb,
    required this.onChanged,
    required this.context,
  });
  final String label;
  final int argb;
  final ValueChanged<int> onChanged;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final color = Color(argb);
    final hex = '#${argb.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(_formatLabel(label),
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70))),
          GestureDetector(
            onTap: () => _pickColor(context, color),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(hex, style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context, Color current) {
    final colors = [
      0xFF6366F1, 0xFF8B5CF6, 0xFFEC4899, 0xFFEF4444,
      0xFFF59E0B, 0xFF10B981, 0xFF06B6D4, 0xFF3B82F6,
      0xFF000000, 0xFF212121, 0xFF424242, 0xFF757575,
      0xFFBDBDBD, 0xFFE0E0E0, 0xFFF5F5F5, 0xFFFFFFFF,
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Pick a color', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                onChanged(c);
                Navigator.pop(context);
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Color(c),
                  borderRadius: BorderRadius.circular(8),
                  border: c == current.value
                      ? Border.all(color: Colors.white, width: 2)
                      : Border.all(color: Colors.white24),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Code tab ─────────────────────────────────────────────────────────────────

class _CodeTab extends StatelessWidget {
  const _CodeTab({required this.state});
  final _CanvasState state;
  static const _accent = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    final code = generateCode(state.nodes);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GENERATED CODE',
                  style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.3), letterSpacing: 1.1)),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Copied!', style: GoogleFonts.inter()),
                    backgroundColor: _accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 1),
                  ));
                },
                icon: const Icon(Icons.copy, size: 13),
                label: Text('Copy', style: GoogleFonts.inter(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: _accent),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SelectableText(
              code,
              style: GoogleFonts.robotoMono(
                  fontSize: 11.5, color: const Color(0xFFCE9178), height: 1.65),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Utility ──────────────────────────────────────────────────────────────────

String _formatLabel(String key) {
  return key
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
      .trim()
      .toUpperCase();
}
