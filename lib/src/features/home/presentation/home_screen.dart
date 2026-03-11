import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/home_repository.dart';
import '../domain/feature_item.dart';
import '../domain/home_category.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Color palette: deep navy + vibrant per-tool accents
// ─────────────────────────────────────────────────────────────────────────────

const _bg = Color(0xFF090E1A);
const _navBg = Color(0xFF0D1322);
const _border = Color(0xFF1C2338);
const _textPrimary = Color(0xFFF0F4FF);
const _textMuted = Color(0xFF6B7A99);

// Per-tool gradient swatches (index matched to allFeatures order in repo)
const _swatches = [
  [Color(0xFF6366F1), Color(0xFF8B5CF6)], // UI Builder – indigo-violet
  [Color(0xFF0EA5E9), Color(0xFF6366F1)], // Theme Builder – sky-indigo
  [Color(0xFF10B981), Color(0xFF0EA5E9)], // Widget Generator – emerald-sky
  [Color(0xFFF59E0B), Color(0xFFF97316)], // JSON Model – amber-orange
  [Color(0xFFEC4899), Color(0xFFF43F5E)], // Color Palette – pink-rose
  [Color(0xFF22D3EE), Color(0xFF6366F1)], // Snippets – cyan-indigo
  [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Icon Browser – violet-pink
  [Color(0xFF10B981), Color(0xFFF59E0B)], // Pubspec Manager – green-amber
  [Color(0xFF6366F1), Color(0xFF22D3EE)], // Blog – indigo-cyan
  [Color(0xFFF97316), Color(0xFFEC4899)], // Audit – orange-pink
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _query = '';
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(homeRepositoryProvider);
    final cats = repo.getCategories();
    final allFeatures = <FeatureItem>[];
    for (final cat in cats) {
      allFeatures.addAll(cat.items);
    }

    final filtered = allFeatures.where((item) {
      if (_query.isEmpty) return true;
      return item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.description.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final cols = isWide ? 3 : 2;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Nav bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _navBg,
            elevation: 0,
            title: Row(
              children: [
                // Animated gradient logo mark
                AnimatedBuilder(
                  animation: _shimmer,
                  builder: (_, __) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        stops: [
                          (_shimmer.value - 0.3).clamp(0.0, 1.0),
                          _shimmer.value.clamp(0.0, 1.0),
                          (_shimmer.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(LucideIcons.zap, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Text('JustFlutter',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary)),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('PRO',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0)),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: _border),
            ),
          ),

          // ── Hero gradient banner ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHero(allFeatures.length)),

          // ── Search + stats bar ────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              onChanged: (v) => setState(() => _query = v),
              totalCount: allFeatures.length,
            ),
          ),

          // ── Tool grid ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.4 : 1.05,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final item = filtered[i];
                  final swatchIdx = allFeatures.indexOf(item) % _swatches.length;
                  return _ToolCard(
                    item: item,
                    colors: _swatches[swatchIdx],
                    onTap: () => ctx.goNamed(item.route),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D1322),
            const Color(0xFF0D1827),
            _bg,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: Color(0xFF6366F1), shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text('$count tools ready to use',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF818CF8),
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 20),

          // Headline with gradient span
          RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: _textPrimary),
              children: [
                const TextSpan(text: 'Your '),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ).createShader(r),
                    child: Text('Flutter Toolkit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        )),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Everything you need to design, build\nand ship faster — all in one place.',
            style: GoogleFonts.inter(
                fontSize: 15, color: _textMuted, height: 1.65),
          ),

          const SizedBox(height: 28),

          // Stat chips
          Wrap(spacing: 10, runSpacing: 10, children: [
            _StatChip(icon: LucideIcons.layers, label: '${cats.length} categories'),
            _StatChip(icon: LucideIcons.code2, label: '$count tools'),
            const _StatChip(icon: LucideIcons.zap, label: 'Instant code gen'),
          ]),
        ],
      ),
    );
  }

  List<HomeCategory> get cats {
    return ref.read(homeRepositoryProvider).getCategories();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar persistent header
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarDelegate({required this.onChanged, required this.totalCount});
  final ValueChanged<String> onChanged;
  final int totalCount;

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 68,
      color: _bg,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: _navBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: TextField(
          onChanged: onChanged,
          style: GoogleFonts.inter(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search $totalCount tools…',
            hintStyle: GoogleFonts.inter(color: _textMuted, fontSize: 14),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(LucideIcons.search, color: _textMuted, size: 17),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate old) => old.totalCount != totalCount;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tool Card
// ─────────────────────────────────────────────────────────────────────────────

class _ToolCard extends StatefulWidget {
  const _ToolCard({
    required this.item,
    required this.colors,
    required this.onTap,
  });
  final FeatureItem item;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scale = Tween(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c1 = widget.colors[0];
    final c2 = widget.colors[1];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: _navBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Stack(
              children: [
                // Gradient corner accent
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20)),
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.0,
                        colors: [c1.withValues(alpha: 0.18), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon bubble
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [c1, c2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: c1.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(widget.item.icon,
                            color: Colors.white, size: 20),
                      ),

                      const Spacer(),

                      // NEW badge
                      if (widget.item.isNew) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: c1.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'NEW',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: c1,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Title
                      Text(
                        widget.item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Description
                      Text(
                        widget.item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _textMuted,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Open arrow
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (r) => LinearGradient(
                              colors: [c1, c2],
                            ).createShader(r),
                            child: Text(
                              'Open tool',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.arrowRight, size: 11, color: c1),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _navBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: _textMuted),
        const SizedBox(width: 7),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: _textMuted, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
