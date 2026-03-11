import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain
// ─────────────────────────────────────────────────────────────────────────────

class PubDependency {
  PubDependency({
    required this.name,
    required this.version,
    this.isDev = false,
    this.url,
    this.description = '',
  });

  final String name;
  String version;
  final bool isDev;
  final String? url;
  String description;
}

// ─────────────────────────────────────────────────────────────────────────────
// Popular packages reference list
// ─────────────────────────────────────────────────────────────────────────────

class PopularPackage {
  const PopularPackage({
    required this.name,
    required this.latestVersion,
    required this.description,
    required this.category,
  });
  final String name;
  final String latestVersion;
  final String description;
  final String category;
}

const _popularPackages = <PopularPackage>[
  // State
  PopularPackage(name: 'flutter_riverpod', latestVersion: '^2.6.1', description: 'Reactive state management', category: 'State'),
  PopularPackage(name: 'riverpod_annotation', latestVersion: '^2.6.1', description: 'Annotations for Riverpod code gen', category: 'State'),
  PopularPackage(name: 'flutter_bloc', latestVersion: '^9.0.0', description: 'BLoC/Cubit state management', category: 'State'),
  PopularPackage(name: 'provider', latestVersion: '^6.1.2', description: 'Simple state management', category: 'State'),
  PopularPackage(name: 'get', latestVersion: '^4.6.6', description: 'GetX — state, routing, DI', category: 'State'),
  // Navigation
  PopularPackage(name: 'go_router', latestVersion: '^14.6.3', description: 'Declarative URL-based routing', category: 'Navigation'),
  PopularPackage(name: 'auto_route', latestVersion: '^9.3.2', description: 'Code-gen routing', category: 'Navigation'),
  // Networking
  PopularPackage(name: 'dio', latestVersion: '^5.8.0+1', description: 'Advanced HTTP client', category: 'Networking'),
  PopularPackage(name: 'http', latestVersion: '^1.3.0', description: 'Official Dart HTTP package', category: 'Networking'),
  PopularPackage(name: 'retrofit', latestVersion: '^4.4.1', description: 'Type-safe REST client', category: 'Networking'),
  // Serialization
  PopularPackage(name: 'json_serializable', latestVersion: '^6.9.4', description: 'JSON code generation', category: 'Dev'),
  PopularPackage(name: 'freezed', latestVersion: '^2.5.8', description: 'Immutable model code gen', category: 'Dev'),
  PopularPackage(name: 'freezed_annotation', latestVersion: '^2.4.4', description: 'Freezed annotations', category: 'Dev'),
  PopularPackage(name: 'json_annotation', latestVersion: '^4.9.0', description: 'JSON annotations', category: 'Dev'),
  // Storage
  PopularPackage(name: 'shared_preferences', latestVersion: '^2.5.3', description: 'Persistent key-value storage', category: 'Storage'),
  PopularPackage(name: 'hive_flutter', latestVersion: '^1.1.0', description: 'Fast NoSQL box database', category: 'Storage'),
  PopularPackage(name: 'sqflite', latestVersion: '^2.4.2', description: 'SQLite for Flutter', category: 'Storage'),
  PopularPackage(name: 'isar', latestVersion: '^4.0.0', description: 'High-performance NoSQL DB', category: 'Storage'),
  // UI
  PopularPackage(name: 'google_fonts', latestVersion: '^6.2.1', description: '1000+ Google Fonts', category: 'UI'),
  PopularPackage(name: 'flutter_svg', latestVersion: '^2.0.17', description: 'SVG rendering', category: 'UI'),
  PopularPackage(name: 'cached_network_image', latestVersion: '^3.4.1', description: 'Cached network images', category: 'UI'),
  PopularPackage(name: 'lottie', latestVersion: '^3.3.1', description: 'Airbnb Lottie animations', category: 'UI'),
  PopularPackage(name: 'shimmer', latestVersion: '^3.0.0', description: 'Shimmer loading effect', category: 'UI'),
  PopularPackage(name: 'flutter_animate', latestVersion: '^4.5.2', description: 'Easy widget animations', category: 'UI'),
  PopularPackage(name: 'lucide_icons', latestVersion: '^0.0.5', description: 'Lucide icon set for Flutter', category: 'UI'),
  // Firebase
  PopularPackage(name: 'firebase_core', latestVersion: '^3.13.0', description: 'Firebase core', category: 'Firebase'),
  PopularPackage(name: 'firebase_auth', latestVersion: '^5.5.1', description: 'Firebase Authentication', category: 'Firebase'),
  PopularPackage(name: 'cloud_firestore', latestVersion: '^5.6.6', description: 'Firestore database', category: 'Firebase'),
  PopularPackage(name: 'firebase_storage', latestVersion: '^12.4.4', description: 'Firebase Cloud Storage', category: 'Firebase'),
  // Dev tools
  PopularPackage(name: 'build_runner', latestVersion: '^2.4.14', description: 'Code generation runner', category: 'Dev'),
  PopularPackage(name: 'riverpod_generator', latestVersion: '^2.6.5', description: 'Riverpod code generator', category: 'Dev'),
  PopularPackage(name: 'flutter_lints', latestVersion: '^5.0.0', description: 'Recommended lint rules', category: 'Dev'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PubspecManagerScreen extends StatefulWidget {
  const PubspecManagerScreen({super.key});

  @override
  State<PubspecManagerScreen> createState() => _PubspecManagerScreenState();
}

class _PubspecManagerScreenState extends State<PubspecManagerScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFF06B6D4);

  late final TabController _tabCtrl;

  final List<PubDependency> _deps = [];
  final List<PubDependency> _devDeps = [];

  String _search = '';
  String _catalogCat = 'All';

  final _nameCtrl = TextEditingController();
  final _versionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadDefaults();
  }

  void _loadDefaults() {
    _deps.addAll([
      PubDependency(name: 'flutter_riverpod', version: '^2.6.1', description: 'Reactive state management'),
      PubDependency(name: 'go_router', version: '^14.6.3', description: 'Declarative routing'),
      PubDependency(name: 'google_fonts', version: '^6.2.1', description: '1000+ Google Fonts'),
    ]);
    _devDeps.addAll([
      PubDependency(name: 'build_runner', version: '^2.4.14', isDev: true, description: 'Code generation runner'),
      PubDependency(name: 'flutter_lints', version: '^5.0.0', isDev: true, description: 'Lint rules'),
    ]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _versionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(LucideIcons.package, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Text('Pubspec Manager',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _copyYaml,
            icon: const Icon(LucideIcons.copy, size: 14),
            label: Text('Copy YAML', style: GoogleFonts.inter(fontSize: 12)),
            style: TextButton.styleFrom(foregroundColor: _accent),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white38,
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'dependencies (${_deps.length})'),
            Tab(text: 'dev_dependencies (${_devDeps.length})'),
            const Tab(text: 'Package Catalog'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildDepsList(_deps, isDev: false),
          _buildDepsList(_devDeps, isDev: true),
          _buildCatalog(),
        ],
      ),
    );
  }

  // ── Dependencies list tab ──────────────────────────────────────────────────
  Widget _buildDepsList(List<PubDependency> list, {required bool isDev}) {
    return Column(
      children: [
        // Add package bar
        Container(
          color: _surface,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameCtrl,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                  decoration: _inputDec('Package name', LucideIcons.package),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _versionCtrl,
                  style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
                  decoration: _inputDec('Version (e.g. ^1.0.0)', LucideIcons.tag),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _addPackage(list, isDev: isDev),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _border),
        if (list.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.packageOpen, size: 48, color: Colors.white12),
                  const SizedBox(height: 12),
                  Text('No ${isDev ? 'dev_' : ''}dependencies yet',
                      style: GoogleFonts.inter(color: Colors.white24)),
                  const SizedBox(height: 8),
                  Text('Use the form above or browse the Package Catalog',
                      style: GoogleFonts.inter(color: Colors.white12, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => Container(height: 1, color: _border),
              itemBuilder: (_, i) => _buildDepTile(list, i),
            ),
          ),
      ],
    );
  }

  Widget _buildDepTile(List<PubDependency> list, int i) {
    final dep = list[i];
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(LucideIcons.package, size: 16, color: _accent),
      ),
      title: Text(dep.name,
          style: GoogleFonts.robotoMono(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: dep.description.isNotEmpty
          ? Text(dep.description,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Version badge (editable)
          GestureDetector(
            onTap: () => _editVersion(list, i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(dep.version,
                  style: GoogleFonts.robotoMono(fontSize: 12, color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 10),
          // Copy
          IconButton(
            icon: const Icon(LucideIcons.copy, size: 14, color: Colors.white38),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '${dep.name}: ${dep.version}'));
              _snack('Copied ${dep.name}');
            },
            tooltip: 'Copy',
          ),
          // Remove
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 14,
                color: Colors.red.withValues(alpha: 0.7)),
            onPressed: () => setState(() => list.removeAt(i)),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  // ── Package catalog ────────────────────────────────────────────────────────
  Widget _buildCatalog() {
    final cats = ['All', ..._popularPackages.map((p) => p.category).toSet().toList()..sort()];
    final filtered = _popularPackages.where((p) {
      final matchCat = _catalogCat == 'All' || p.category == _catalogCat;
      final q = _search.toLowerCase();
      final matchQ = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchCat && matchQ;
    }).toList();

    return Column(
      children: [
        // Search + categories
        Container(
          color: _surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                decoration: _inputDec('Search packages…', Icons.search),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: cats.map((cat) {
                    final active = _catalogCat == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _catalogCat = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: active ? _accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: active ? _accent.withValues(alpha: 0.6) : Colors.white12),
                        ),
                        child: Text(cat,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: active ? _accent : Colors.white54,
                                fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: _border),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Container(height: 1, color: _border),
            itemBuilder: (_, i) {
              final pkg = filtered[i];
              final alreadyAdded = _deps.any((d) => d.name == pkg.name) ||
                  _devDeps.any((d) => d.name == pkg.name);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _categoryColor(pkg.category).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.package, size: 16, color: _categoryColor(pkg.category)),
                ),
                title: Row(
                  children: [
                    Text(pkg.name,
                        style: GoogleFonts.robotoMono(
                            fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor(pkg.category).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(pkg.category,
                          style: GoogleFonts.inter(
                              fontSize: 9, color: _categoryColor(pkg.category))),
                    ),
                  ],
                ),
                subtitle: Text(pkg.description,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(pkg.latestVersion,
                          style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.white54)),
                    ),
                    const SizedBox(width: 8),
                    alreadyAdded
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 12, color: Colors.green),
                                const SizedBox(width: 4),
                                Text('Added',
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.green)),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _deps.add(PubDependency(
                                  name: pkg.name,
                                  version: pkg.latestVersion,
                                  description: pkg.description,
                                ));
                              });
                              _snack('Added ${pkg.name}');
                              _tabCtrl.animateTo(0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent.withValues(alpha: 0.15),
                              foregroundColor: _accent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(color: _accent.withValues(alpha: 0.4))),
                            ),
                            child: Text('+ Add', style: GoogleFonts.inter(fontSize: 12)),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _addPackage(List<PubDependency> list, {required bool isDev}) {
    final name = _nameCtrl.text.trim();
    final version = _versionCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      list.add(PubDependency(
        name: name,
        version: version.isEmpty ? 'any' : version,
        isDev: isDev,
      ));
    });
    _nameCtrl.clear();
    _versionCtrl.clear();
    _snack('Added $name');
  }

  void _editVersion(List<PubDependency> list, int i) {
    final ctrl = TextEditingController(text: list[i].version);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Edit version — ${list[i].name}',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 13),
          decoration: _inputDec('e.g. ^2.0.0', LucideIcons.tag),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              setState(() => list[i].version = ctrl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white),
            child: Text('Save', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  String _generateYaml() {
    final buf = StringBuffer();
    buf.writeln('dependencies:');
    buf.writeln('  flutter:');
    buf.writeln('    sdk: flutter');
    for (final d in _deps) {
      buf.writeln('  ${d.name}: ${d.version}');
    }
    buf.writeln();
    buf.writeln('dev_dependencies:');
    buf.writeln('  flutter_test:');
    buf.writeln('    sdk: flutter');
    for (final d in _devDeps) {
      buf.writeln('  ${d.name}: ${d.version}');
    }
    return buf.toString();
  }

  void _copyYaml() {
    Clipboard.setData(ClipboardData(text: _generateYaml()));
    _snack('pubspec.yaml snippet copied!');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter()),
      backgroundColor: _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }

  Color _categoryColor(String cat) {
    return switch (cat) {
      'State' => const Color(0xFF8B5CF6),
      'Navigation' => const Color(0xFF06B6D4),
      'Networking' => const Color(0xFF10B981),
      'Storage' => const Color(0xFFF59E0B),
      'UI' => const Color(0xFFEC4899),
      'Firebase' => const Color(0xFFEF4444),
      'Dev' => const Color(0xFF6366F1),
      _ => const Color(0xFF64748B),
    };
  }

  InputDecoration _inputDec(String hint, dynamic icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 12),
      prefixIcon: Icon(icon is IconData ? icon : null, size: 16, color: Colors.white38),
      filled: true,
      fillColor: _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accent)),
    );
  }
}
