import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'json_model_screen.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class JsonModelState {
  const JsonModelState({
    this.rawJson = '',
    this.className = 'MyModel',
    this.useFreezed = false,
    this.useJsonSerializable = false,
    this.useCopyWith = true,
    this.useEquality = true,
    this.nullSafety = true,
    this.generatedCode = '',
    this.error = '',
  });

  final String rawJson;
  final String className;
  final bool useFreezed;
  final bool useJsonSerializable;
  final bool useCopyWith;
  final bool useEquality;
  final bool nullSafety;
  final String generatedCode;
  final String error;

  JsonModelState copyWith({
    String? rawJson,
    String? className,
    bool? useFreezed,
    bool? useJsonSerializable,
    bool? useCopyWith,
    bool? useEquality,
    bool? nullSafety,
    String? generatedCode,
    String? error,
  }) {
    return JsonModelState(
      rawJson: rawJson ?? this.rawJson,
      className: className ?? this.className,
      useFreezed: useFreezed ?? this.useFreezed,
      useJsonSerializable: useJsonSerializable ?? this.useJsonSerializable,
      useCopyWith: useCopyWith ?? this.useCopyWith,
      useEquality: useEquality ?? this.useEquality,
      nullSafety: nullSafety ?? this.nullSafety,
      generatedCode: generatedCode ?? this.generatedCode,
      error: error ?? this.error,
    );
  }
}

@riverpod
class JsonModelNotifier extends _$JsonModelNotifier {
  @override
  JsonModelState build() => const JsonModelState();

  void update(JsonModelState Function(JsonModelState) updater) {
    state = updater(state);
  }

  void generate() {
    if (state.rawJson.trim().isEmpty) {
      state = state.copyWith(error: 'Please paste some JSON first.', generatedCode: '');
      return;
    }
    try {
      final decoded = jsonDecode(state.rawJson);
      if (decoded is! Map<String, dynamic>) {
        state = state.copyWith(error: 'Root JSON must be an object { }', generatedCode: '');
        return;
      }
      final code = _buildClass(state.className, decoded);
      state = state.copyWith(generatedCode: code, error: '');
    } catch (e) {
      state = state.copyWith(error: 'Invalid JSON: $e', generatedCode: '');
    }
  }

  String _dartType(dynamic value, String key) {
    if (value == null) return 'dynamic';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is String) return 'String';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      final inner = _dartType(value.first, key);
      return 'List<$inner>';
    }
    if (value is Map) {
      return _toPascalCase(key);
    }
    return 'dynamic';
  }

  String _toPascalCase(String s) {
    if (s.isEmpty) return s;
    final parts = s.split(RegExp(r'[_\s-]'));
    return parts.map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }

  String _toCamelCase(String s) {
    final pascal = _toPascalCase(s);
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Recursively builds class definitions
  String _buildClass(String name, Map<String, dynamic> json) {
    final buffer = StringBuffer();
    final nestedClasses = <String>[];

    // Collect nested classes first
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        nestedClasses.add(_buildClass(_toPascalCase(key), value));
      } else if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        nestedClasses.add(_buildClass(_toPascalCase(key), value.first as Map<String, dynamic>));
      }
    });

    final s = state;
    final q = s.nullSafety ? '?' : '';

    if (s.useFreezed) {
      buffer.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
      buffer.writeln("part '${_toSnakeCase(name)}.freezed.dart';");
      if (s.useJsonSerializable) {
        buffer.writeln("part '${_toSnakeCase(name)}.g.dart';");
      }
      buffer.writeln();
      buffer.writeln('@freezed');
      buffer.writeln('class $name with _\$$name {');
      buffer.writeln('  const factory $name({');
      json.forEach((key, value) {
        final type = _dartType(value, key);
        final camel = _toCamelCase(key);
        final jsonKey = key != camel ? "    @JsonKey(name: '$key') " : '    ';
        buffer.writeln('${jsonKey}required $type$q $camel,');
      });
      buffer.writeln('  }) = _$name;');
      if (s.useJsonSerializable) {
        buffer.writeln();
        buffer.writeln('  factory $name.fromJson(Map<String, dynamic> json) =>');
        buffer.writeln('      _\$${name}FromJson(json);');
      }
      buffer.writeln('}');
    } else {
      // Standard class
      if (s.useJsonSerializable) {
        buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
        buffer.writeln("part '${_toSnakeCase(name)}.g.dart';");
        buffer.writeln();
        buffer.writeln('@JsonSerializable()');
      }
      buffer.writeln('class $name {');
      buffer.writeln('  const $name({');
      json.forEach((key, value) {
        final camel = _toCamelCase(key);
        buffer.writeln('    required this.$camel,');
      });
      buffer.writeln('  });\n');

      // Fields
      json.forEach((key, value) {
        final type = _dartType(value, key);
        final camel = _toCamelCase(key);
        if (key != camel && !s.useJsonSerializable) {
          // no-op; handled in fromJson
        } else if (key != camel && s.useJsonSerializable) {
          buffer.writeln("  @JsonKey(name: '$key')");
        }
        buffer.writeln('  final $type$q $camel;');
      });
      buffer.writeln();

      // fromJson
      if (s.useJsonSerializable) {
        buffer.writeln('  factory $name.fromJson(Map<String, dynamic> json) =>');
        buffer.writeln('      _\$${name}FromJson(json);');
        buffer.writeln();
        buffer.writeln('  Map<String, dynamic> toJson() => _\$${name}ToJson(this);');
      } else {
        buffer.writeln('  factory $name.fromJson(Map<String, dynamic> json) {');
        buffer.writeln('    return $name(');
        json.forEach((key, value) {
          final type = _dartType(value, key);
          final camel = _toCamelCase(key);
          if (value is Map) {
            buffer.writeln(
                "      $camel: $type.fromJson(json['$key'] as Map<String, dynamic>),");
          } else if (value is List && value.isNotEmpty && value.first is Map) {
            final inner = _toPascalCase(key);
            buffer.writeln(
                "      $camel: (json['$key'] as List).map((e) => $inner.fromJson(e as Map<String, dynamic>)).toList(),");
          } else if (value is int) {
            buffer.writeln("      $camel: (json['$key'] as num).toInt(),");
          } else if (value is double) {
            buffer.writeln("      $camel: (json['$key'] as num).toDouble(),");
          } else {
            buffer.writeln("      $camel: json['$key'] as $type$q,");
          }
        });
        buffer.writeln('    );');
        buffer.writeln('  }\n');

        // toJson
        buffer.writeln('  Map<String, dynamic> toJson() {');
        buffer.writeln('    return {');
        json.forEach((key, value) {
          final camel = _toCamelCase(key);
          if (value is Map || (value is List && value.isNotEmpty && value.first is Map)) {
            buffer.writeln("      '$key': $camel${value is List ? '.map((e) => e.toJson()).toList()' : '.toJson()'},");
          } else {
            buffer.writeln("      '$key': $camel,");
          }
        });
        buffer.writeln('    };');
        buffer.writeln('  }');
      }

      // copyWith
      if (s.useCopyWith && !s.useFreezed) {
        buffer.writeln();
        buffer.writeln('  $name copyWith({');
        json.forEach((key, value) {
          final type = _dartType(value, key);
          final camel = _toCamelCase(key);
          buffer.writeln('    $type$q $camel,');
        });
        buffer.writeln('  }) {');
        buffer.writeln('    return $name(');
        json.forEach((key, value) {
          final camel = _toCamelCase(key);
          buffer.writeln('      $camel: $camel ?? this.$camel,');
        });
        buffer.writeln('    );');
        buffer.writeln('  }');
      }

      // equality
      if (s.useEquality && !s.useFreezed) {
        buffer.writeln();
        buffer.writeln('  @override');
        buffer.writeln('  bool operator ==(Object other) {');
        buffer.writeln('    if (identical(this, other)) return true;');
        buffer.writeln('    return other is $name &&');
        final keys = json.keys.toList();
        for (int i = 0; i < keys.length; i++) {
          final camel = _toCamelCase(keys[i]);
          final comma = i < keys.length - 1 ? ' &&' : ';';
          buffer.writeln('        other.$camel == $camel$comma');
        }
        buffer.writeln('  }\n');
        buffer.writeln('  @override');
        buffer.writeln('  int get hashCode => Object.hash(');
        json.forEach((key, _) {
          final camel = _toCamelCase(key);
          buffer.writeln('    $camel,');
        });
        buffer.writeln('  );\n');
        buffer.writeln('  @override');
        buffer.writeln('  String toString() => \'$name(\${');
        final fieldStrings = json.keys.map((k) => '${_toCamelCase(k)}: \$${_toCamelCase(k)}').join(', ');
        buffer.writeln("    '$fieldStrings'");
        buffer.writeln("  })\';");
      }

      buffer.writeln('}');
    }

    // Nested classes
    for (final nc in nestedClasses) {
      buffer.writeln();
      buffer.write(nc);
    }

    return buffer.toString();
  }

  String _toSnakeCase(String s) {
    return s.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class JsonModelScreen extends ConsumerStatefulWidget {
  const JsonModelScreen({super.key});

  @override
  ConsumerState<JsonModelScreen> createState() => _JsonModelScreenState();
}

class _JsonModelScreenState extends ConsumerState<JsonModelScreen> {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFF6366F1);

  late final TextEditingController _jsonController;
  late final TextEditingController _classController;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController();
    _classController = TextEditingController(text: 'MyModel');
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _classController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jsonModelNotifierProvider);
    final notifier = ref.read(jsonModelNotifierProvider.notifier);
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(7)),
              child: const Icon(LucideIcons.braces, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Text('JSON → Model Generator',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: isWide
          ? Row(children: [
              SizedBox(width: 420, child: _buildInputPanel(state, notifier)),
              Container(width: 1, color: _border),
              Expanded(child: _buildOutputPanel(state, notifier)),
            ])
          : Column(children: [
              SizedBox(height: 400, child: _buildInputPanel(state, notifier)),
              Container(height: 1, color: _border),
              Expanded(child: _buildOutputPanel(state, notifier)),
            ]),
    );
  }

  Widget _buildInputPanel(JsonModelState state, JsonModelNotifier notifier) {
    return Container(
      color: _surface,
      child: Column(
        children: [
          // Options bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('CLASS NAME'),
                const SizedBox(height: 8),
                TextField(
                  controller: _classController,
                  onChanged: (v) => notifier.update((s) => s.copyWith(className: v.isEmpty ? 'MyModel' : v)),
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white12)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _accent)),
                  ),
                ),
                const SizedBox(height: 16),
                _label('OPTIONS'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ToggleChip(label: 'copyWith', value: state.useCopyWith,
                        onChange: (v) => notifier.update((s) => s.copyWith(useCopyWith: v))),
                    _ToggleChip(label: '==  hashCode', value: state.useEquality,
                        onChange: (v) => notifier.update((s) => s.copyWith(useEquality: v))),
                    _ToggleChip(label: 'json_serializable', value: state.useJsonSerializable,
                        onChange: (v) => notifier.update((s) => s.copyWith(useJsonSerializable: v, useFreezed: v ? false : state.useFreezed))),
                    _ToggleChip(label: 'Freezed', value: state.useFreezed,
                        onChange: (v) => notifier.update((s) => s.copyWith(useFreezed: v, useJsonSerializable: v ? false : state.useJsonSerializable))),
                  ],
                ),
              ],
            ),
          ),
          // JSON editor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('PASTE JSON'),
                Row(
                  children: [
                    _IconBtn(icon: LucideIcons.clipboard, tip: 'Paste from clipboard', onTap: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _jsonController.text = data!.text!;
                        notifier.update((s) => s.copyWith(rawJson: data.text!));
                      }
                    }),
                    const SizedBox(width: 8),
                    _IconBtn(icon: LucideIcons.trash2, tip: 'Clear', onTap: () {
                      _jsonController.clear();
                      notifier.update((s) => s.copyWith(rawJson: '', generatedCode: '', error: ''));
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _jsonController,
                  onChanged: (v) => notifier.update((s) => s.copyWith(rawJson: v)),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.robotoMono(color: const Color(0xFF9ECBFF), fontSize: 12, height: 1.6),
                  decoration: InputDecoration(
                    hintText: '{\n  "id": 1,\n  "name": "Flutter",\n  "isActive": true\n}',
                    hintStyle: GoogleFonts.robotoMono(color: Colors.white24, fontSize: 12, height: 1.6),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Generate button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: notifier.generate,
                icon: const Icon(LucideIcons.zap, size: 16),
                label: Text('Generate Dart Model', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel(JsonModelState state, JsonModelNotifier notifier) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('GENERATED DART CODE'),
                if (state.generatedCode.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.generatedCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to clipboard!', style: GoogleFonts.inter()),
                          backgroundColor: _accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.copy, size: 14),
                    label: Text('Copy', style: GoogleFonts.inter(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: _accent),
                  ),
              ],
            ),
          ),
          Expanded(
            child: state.error.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 40),
                          const SizedBox(height: 12),
                          Text(state.error,
                              style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 13),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  )
                : state.generatedCode.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.braces, size: 48, color: Colors.white12),
                            const SizedBox(height: 16),
                            Text('Paste JSON and click Generate',
                                style: GoogleFonts.inter(color: Colors.white24, fontSize: 14)),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SelectableText(
                          state.generatedCode,
                          style: GoogleFonts.robotoMono(
                              fontSize: 12.5, color: const Color(0xFFCE9178), height: 1.65),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.3), letterSpacing: 1.1));
}

// ─────────────────────────────────────────────────────────────────────────────
// Small shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({required this.label, required this.value, required this.onChange});
  final String label;
  final bool value;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6366F1);
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: value ? accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? accent.withValues(alpha: 0.6) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value ? LucideIcons.checkSquare : LucideIcons.square,
                size: 12, color: value ? accent : Colors.white38),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: value ? Colors.white : Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.tip, required this.onTap});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, size: 13, color: Colors.white38),
        ),
      ),
    );
  }
}
