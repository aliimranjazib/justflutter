import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/home_repository.dart';
import '../domain/feature_item.dart';
import '../domain/home_category.dart';

// ---------------------------------------------------------------------------
// A single, self-contained revamp. No sidebar needed.
// Design inspiration: Linear, Vercel, Raycast — clean, content-first, typographic.
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ---- Design tokens -------------------------------------------------------
  static const Color _bg = Color(0xFF0A0A0A);
  static const Color _surface = Color(0xFF111111);
  static const Color _border = Color(0xFF1F1F1F);
  static const Color _textPrimary = Color(0xFFEDEDED);
  static const Color _textMuted = Color(0xFF666666);
  static const Color _textSubtle = Color(0xFF444444);
  static const Color _accent = Color(0xFF5865F2); // indigo accent
  static const Color _accentMuted = Color(0xFF1A1D40);
  static const Color _green = Color(0xFF22C55E);
  static const Color _greenMuted = Color(0xFF0D2818);

  // ---- State ---------------------------------------------------------------
  String _searchQuery = '';
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(homeRepositoryProvider);
    final categories = repo.getCategories();
    final featured = repo.getFeaturedFeature();
    final isWide = MediaQuery.of(context).size.width > 900;

    // Filter items based on search
    final filtered = _searchQuery.isEmpty
        ? categories
        : categories
            .map((cat) => HomeCategory(
                  id: cat.id,
                  title: cat.title,
                  icon: cat.icon,
                  items: cat.items
                      .where((item) =>
                          item.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          item.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                      .toList(),
                ))
            .where((cat) => cat.items.isNotEmpty)
            .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
          child: CustomScrollView(
            slivers: [
              // ── Top bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildTopBar(context),
              ),

              // ── Hero / greeting ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHero(featured),
              ),

              // ── Search bar ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),

              // ── Divider ──────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Divider(color: _border, thickness: 1, height: 1),
                ),
              ),

              // ── Category sections ─────────────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildCategorySection(context, filtered[index]),
                  childCount: filtered.length,
                ),
              ),

              // ── Footer ───────────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  LucideIcons.zap,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'JustFlutter Hub',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Version chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _border),
            ),
            child: Text(
              'v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────
  Widget _buildHero(FeatureItem? featured) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date label
          Text(
            _getGreetingDate(),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _textSubtle,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Headline
          Text(
            'Developer Hub',
            style: GoogleFonts.inter(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'All your Flutter tools and resources in one place.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: _textMuted,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),

          // Featured action
          if (featured != null) ...[
            const SizedBox(height: 32),
            _buildFeaturedAction(featured),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturedAction(FeatureItem featured) {
    return Consumer(builder: (context, ref, _) {
      return GestureDetector(
        onTap: () => context.goNamed(featured.route),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _accentMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromRGBO(88, 101, 242, 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  color: _accent,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  'Featured: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color.fromRGBO(88, 101, 242, 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  featured.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  LucideIcons.arrowRight,
                  color: const Color.fromRGBO(88, 101, 242, 0.8),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _textPrimary,
          ),
          cursorColor: _accent,
          decoration: InputDecoration(
            hintText: 'Search tools…',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: _textSubtle,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(LucideIcons.search, color: _textSubtle, size: 16),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Category section ──────────────────────────────────────────────────────
  Widget _buildCategorySection(
      BuildContext context, HomeCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 12),
          child: Row(
            children: [
              Icon(category.icon, size: 15, color: _textSubtle),
              const SizedBox(width: 8),
              Text(
                category.title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textSubtle,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${category.items.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color.fromRGBO(68, 68, 68, 0.6),
                ),
              ),
            ],
          ),
        ),
        // Feature items as list rows
        ...List.generate(
          category.items.length,
          (i) => _buildFeatureRow(context, category.items[i], i),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Divider(color: _border, thickness: 1, height: 1),
        ),
      ],
    );
  }

  // ── Feature row ───────────────────────────────────────────────────────────
  Widget _buildFeatureRow(
      BuildContext context, FeatureItem item, int index) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => context.goNamed(item.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: isHovered ? _surface : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: _border),
                ),
                child: Icon(item.icon, size: 16, color: _textMuted),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (item.isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _greenMuted,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color.fromRGBO(34, 197, 94, 0.3)),
                            ),
                            child: Text(
                              'New',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _green,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              AnimatedOpacity(
                opacity: isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: const Icon(
                  LucideIcons.arrowRight,
                  size: 14,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
      child: Row(
        children: [
          Text(
            '© 2026 JustFlutter Hub',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textSubtle,
            ),
          ),
          const Spacer(),
          Text(
            'Built with Flutter',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _textSubtle,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _getGreetingDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
      'Saturday', 'Sunday'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
