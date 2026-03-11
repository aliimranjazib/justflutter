import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data — curated Material icons by category
// ─────────────────────────────────────────────────────────────────────────────

class IconEntry {
  const IconEntry(this.name, this.data, this.category);
  final String name;
  final IconData data;
  final String category;
}

const _icons = <IconEntry>[
  // ── Navigation ────────────────────────────────────────────────────────────
  IconEntry('Icons.home', Icons.home, 'Navigation'),
  IconEntry('Icons.home_outlined', Icons.home_outlined, 'Navigation'),
  IconEntry('Icons.arrow_back', Icons.arrow_back, 'Navigation'),
  IconEntry('Icons.arrow_forward', Icons.arrow_forward, 'Navigation'),
  IconEntry('Icons.arrow_upward', Icons.arrow_upward, 'Navigation'),
  IconEntry('Icons.arrow_downward', Icons.arrow_downward, 'Navigation'),
  IconEntry('Icons.chevron_left', Icons.chevron_left, 'Navigation'),
  IconEntry('Icons.chevron_right', Icons.chevron_right, 'Navigation'),
  IconEntry('Icons.menu', Icons.menu, 'Navigation'),
  IconEntry('Icons.close', Icons.close, 'Navigation'),
  IconEntry('Icons.more_vert', Icons.more_vert, 'Navigation'),
  IconEntry('Icons.more_horiz', Icons.more_horiz, 'Navigation'),
  IconEntry('Icons.expand_more', Icons.expand_more, 'Navigation'),
  IconEntry('Icons.expand_less', Icons.expand_less, 'Navigation'),

  // ── Action ────────────────────────────────────────────────────────────────
  IconEntry('Icons.add', Icons.add, 'Action'),
  IconEntry('Icons.add_circle', Icons.add_circle, 'Action'),
  IconEntry('Icons.add_circle_outline', Icons.add_circle_outline, 'Action'),
  IconEntry('Icons.remove', Icons.remove, 'Action'),
  IconEntry('Icons.edit', Icons.edit, 'Action'),
  IconEntry('Icons.edit_outlined', Icons.edit_outlined, 'Action'),
  IconEntry('Icons.delete', Icons.delete, 'Action'),
  IconEntry('Icons.delete_outline', Icons.delete_outline, 'Action'),
  IconEntry('Icons.delete_forever', Icons.delete_forever, 'Action'),
  IconEntry('Icons.save', Icons.save, 'Action'),
  IconEntry('Icons.save_alt', Icons.save_alt, 'Action'),
  IconEntry('Icons.copy', Icons.copy, 'Action'),
  IconEntry('Icons.content_paste', Icons.content_paste, 'Action'),
  IconEntry('Icons.cut', Icons.cut, 'Action'),
  IconEntry('Icons.share', Icons.share, 'Action'),
  IconEntry('Icons.send', Icons.send, 'Action'),
  IconEntry('Icons.download', Icons.download, 'Action'),
  IconEntry('Icons.upload', Icons.upload, 'Action'),
  IconEntry('Icons.refresh', Icons.refresh, 'Action'),
  IconEntry('Icons.filter_list', Icons.filter_list, 'Action'),
  IconEntry('Icons.sort', Icons.sort, 'Action'),
  IconEntry('Icons.search', Icons.search, 'Action'),
  IconEntry('Icons.tune', Icons.tune, 'Action'),
  IconEntry('Icons.settings', Icons.settings, 'Action'),
  IconEntry('Icons.settings_outlined', Icons.settings_outlined, 'Action'),

  // ── Status & Alerts ───────────────────────────────────────────────────────
  IconEntry('Icons.check', Icons.check, 'Status'),
  IconEntry('Icons.check_circle', Icons.check_circle, 'Status'),
  IconEntry('Icons.check_circle_outline', Icons.check_circle_outline, 'Status'),
  IconEntry('Icons.error', Icons.error, 'Status'),
  IconEntry('Icons.error_outline', Icons.error_outline, 'Status'),
  IconEntry('Icons.warning', Icons.warning, 'Status'),
  IconEntry('Icons.warning_amber', Icons.warning_amber, 'Status'),
  IconEntry('Icons.info', Icons.info, 'Status'),
  IconEntry('Icons.info_outline', Icons.info_outline, 'Status'),
  IconEntry('Icons.help', Icons.help, 'Status'),
  IconEntry('Icons.help_outline', Icons.help_outline, 'Status'),
  IconEntry('Icons.notifications', Icons.notifications, 'Status'),
  IconEntry('Icons.notifications_none', Icons.notifications_none, 'Status'),
  IconEntry('Icons.notifications_off', Icons.notifications_off, 'Status'),
  IconEntry('Icons.done_all', Icons.done_all, 'Status'),
  IconEntry('Icons.pending', Icons.pending, 'Status'),
  IconEntry('Icons.schedule', Icons.schedule, 'Status'),

  // ── Media ─────────────────────────────────────────────────────────────────
  IconEntry('Icons.play_arrow', Icons.play_arrow, 'Media'),
  IconEntry('Icons.pause', Icons.pause, 'Media'),
  IconEntry('Icons.stop', Icons.stop, 'Media'),
  IconEntry('Icons.skip_next', Icons.skip_next, 'Media'),
  IconEntry('Icons.skip_previous', Icons.skip_previous, 'Media'),
  IconEntry('Icons.fast_forward', Icons.fast_forward, 'Media'),
  IconEntry('Icons.fast_rewind', Icons.fast_rewind, 'Media'),
  IconEntry('Icons.volume_up', Icons.volume_up, 'Media'),
  IconEntry('Icons.volume_off', Icons.volume_off, 'Media'),
  IconEntry('Icons.mic', Icons.mic, 'Media'),
  IconEntry('Icons.mic_off', Icons.mic_off, 'Media'),
  IconEntry('Icons.videocam', Icons.videocam, 'Media'),
  IconEntry('Icons.photo_camera', Icons.photo_camera, 'Media'),
  IconEntry('Icons.image', Icons.image, 'Media'),
  IconEntry('Icons.photo_library', Icons.photo_library, 'Media'),
  IconEntry('Icons.music_note', Icons.music_note, 'Media'),

  // ── Communication ─────────────────────────────────────────────────────────
  IconEntry('Icons.phone', Icons.phone, 'Communication'),
  IconEntry('Icons.phone_outlined', Icons.phone_outlined, 'Communication'),
  IconEntry('Icons.email', Icons.email, 'Communication'),
  IconEntry('Icons.email_outlined', Icons.email_outlined, 'Communication'),
  IconEntry('Icons.mail', Icons.mail, 'Communication'),
  IconEntry('Icons.chat', Icons.chat, 'Communication'),
  IconEntry('Icons.chat_bubble', Icons.chat_bubble, 'Communication'),
  IconEntry('Icons.chat_bubble_outline', Icons.chat_bubble_outline, 'Communication'),
  IconEntry('Icons.message', Icons.message, 'Communication'),
  IconEntry('Icons.forum', Icons.forum, 'Communication'),
  IconEntry('Icons.video_call', Icons.video_call, 'Communication'),
  IconEntry('Icons.contacts', Icons.contacts, 'Communication'),

  // ── Files & Folders ───────────────────────────────────────────────────────
  IconEntry('Icons.folder', Icons.folder, 'Files'),
  IconEntry('Icons.folder_open', Icons.folder_open, 'Files'),
  IconEntry('Icons.file_copy', Icons.file_copy, 'Files'),
  IconEntry('Icons.attach_file', Icons.attach_file, 'Files'),
  IconEntry('Icons.attachment', Icons.attachment, 'Files'),
  IconEntry('Icons.insert_drive_file', Icons.insert_drive_file, 'Files'),
  IconEntry('Icons.description', Icons.description, 'Files'),
  IconEntry('Icons.article', Icons.article, 'Files'),
  IconEntry('Icons.picture_as_pdf', Icons.picture_as_pdf, 'Files'),
  IconEntry('Icons.cloud_upload', Icons.cloud_upload, 'Files'),
  IconEntry('Icons.cloud_download', Icons.cloud_download, 'Files'),
  IconEntry('Icons.backup', Icons.backup, 'Files'),

  // ── People & Social ───────────────────────────────────────────────────────
  IconEntry('Icons.person', Icons.person, 'People'),
  IconEntry('Icons.person_outline', Icons.person_outline, 'People'),
  IconEntry('Icons.person_add', Icons.person_add, 'People'),
  IconEntry('Icons.group', Icons.group, 'People'),
  IconEntry('Icons.group_add', Icons.group_add, 'People'),
  IconEntry('Icons.account_circle', Icons.account_circle, 'People'),
  IconEntry('Icons.face', Icons.face, 'People'),
  IconEntry('Icons.star', Icons.star, 'People'),
  IconEntry('Icons.star_border', Icons.star_border, 'People'),
  IconEntry('Icons.favorite', Icons.favorite, 'People'),
  IconEntry('Icons.favorite_border', Icons.favorite_border, 'People'),
  IconEntry('Icons.thumb_up', Icons.thumb_up, 'People'),
  IconEntry('Icons.thumb_down', Icons.thumb_down, 'People'),

  // ── Maps & Location ───────────────────────────────────────────────────────
  IconEntry('Icons.location_on', Icons.location_on, 'Location'),
  IconEntry('Icons.location_off', Icons.location_off, 'Location'),
  IconEntry('Icons.map', Icons.map, 'Location'),
  IconEntry('Icons.navigation', Icons.navigation, 'Location'),
  IconEntry('Icons.directions', Icons.directions, 'Location'),
  IconEntry('Icons.my_location', Icons.my_location, 'Location'),
  IconEntry('Icons.explore', Icons.explore, 'Location'),
  IconEntry('Icons.place', Icons.place, 'Location'),

  // ── Commerce ──────────────────────────────────────────────────────────────
  IconEntry('Icons.shopping_cart', Icons.shopping_cart, 'Commerce'),
  IconEntry('Icons.shopping_bag', Icons.shopping_bag, 'Commerce'),
  IconEntry('Icons.store', Icons.store, 'Commerce'),
  IconEntry('Icons.sell', Icons.sell, 'Commerce'),
  IconEntry('Icons.local_offer', Icons.local_offer, 'Commerce'),
  IconEntry('Icons.payment', Icons.payment, 'Commerce'),
  IconEntry('Icons.credit_card', Icons.credit_card, 'Commerce'),
  IconEntry('Icons.receipt', Icons.receipt, 'Commerce'),
  IconEntry('Icons.monetization_on', Icons.monetization_on, 'Commerce'),

  // ── Device & Tech ─────────────────────────────────────────────────────────
  IconEntry('Icons.phonelink', Icons.phonelink, 'Device'),
  IconEntry('Icons.computer', Icons.computer, 'Device'),
  IconEntry('Icons.tablet', Icons.tablet, 'Device'),
  IconEntry('Icons.watch', Icons.watch, 'Device'),
  IconEntry('Icons.keyboard', Icons.keyboard, 'Device'),
  IconEntry('Icons.mouse', Icons.mouse, 'Device'),
  IconEntry('Icons.wifi', Icons.wifi, 'Device'),
  IconEntry('Icons.bluetooth', Icons.bluetooth, 'Device'),
  IconEntry('Icons.battery_full', Icons.battery_full, 'Device'),
  IconEntry('Icons.signal_cellular_alt', Icons.signal_cellular_alt, 'Device'),

  // ── Security ──────────────────────────────────────────────────────────────
  IconEntry('Icons.lock', Icons.lock, 'Security'),
  IconEntry('Icons.lock_open', Icons.lock_open, 'Security'),
  IconEntry('Icons.shield', Icons.shield, 'Security'),
  IconEntry('Icons.security', Icons.security, 'Security'),
  IconEntry('Icons.vpn_lock', Icons.vpn_lock, 'Security'),
  IconEntry('Icons.visibility', Icons.visibility, 'Security'),
  IconEntry('Icons.visibility_off', Icons.visibility_off, 'Security'),
  IconEntry('Icons.fingerprint', Icons.fingerprint, 'Security'),
  IconEntry('Icons.verified_user', Icons.verified_user, 'Security'),
];

final _iconCategories = [
  'All',
  ..._icons.map((i) => i.category).toSet().toList()..sort(),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class IconBrowserScreen extends StatefulWidget {
  const IconBrowserScreen({super.key});

  @override
  State<IconBrowserScreen> createState() => _IconBrowserScreenState();
}

class _IconBrowserScreenState extends State<IconBrowserScreen> {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF111111);
  static const _border = Color(0xFF1F1F1F);
  static const _accent = Color(0xFFF59E0B);

  String _query = '';
  String _category = 'All';
  int _selectedIconSize = 24;
  IconEntry? _copied;

  List<IconEntry> get _filtered => _icons.where((e) {
        final matchCat = _category == 'All' || e.category == _category;
        final q = _query.toLowerCase();
        final matchQ = q.isEmpty || e.name.toLowerCase().contains(q);
        return matchCat && matchQ;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
              child: const Icon(Icons.grid_view, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text('Icon Browser',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${filtered.length} / ${_icons.length}',
                  style: GoogleFonts.inter(fontSize: 11, color: _accent)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Column(
        children: [
          // ── Toolbar ───────────────────────────────────────────────────────
          Container(
            color: _surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search icons by name…',
                    hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.white38),
                            onPressed: () => setState(() => _query = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: _bg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _accent)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Category chips
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _iconCategories.map((cat) {
                            final active = _category == cat;
                            return GestureDetector(
                              onTap: () => setState(() => _category = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: active
                                      ? _accent.withValues(alpha: 0.15)
                                      : Colors.white.withValues(alpha: 0.04),
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
                    ),
                    // Size selector
                    const SizedBox(width: 12),
                    Text('Size:', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedIconSize,
                      dropdownColor: _surface,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      underline: const SizedBox(),
                      items: [16, 24, 32, 48].map((s) =>
                          DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                      onChanged: (v) => setState(() => _selectedIconSize = v!),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: _border),
          // ── Grid ──────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.white12),
                        const SizedBox(height: 12),
                        Text('No icons found for "$_query"',
                            style: GoogleFonts.inter(color: Colors.white24)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final entry = filtered[i];
                      final isCopied = _copied?.name == entry.name;
                      return GestureDetector(
                        onTap: () => _copyIcon(entry),
                        child: Tooltip(
                          message: '${entry.name}\nTap to copy',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isCopied
                                  ? _accent.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isCopied
                                      ? _accent.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(entry.data,
                                    size: _selectedIconSize.toDouble(),
                                    color: isCopied ? _accent : Colors.white70),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    entry.name.replaceFirst('Icons.', ''),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.robotoMono(
                                        fontSize: 8,
                                        color: isCopied ? _accent : Colors.white38,
                                        height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _copyIcon(IconEntry entry) {
    final code = 'Icon(${entry.name}, size: $_selectedIconSize)';
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = entry);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied: $code', style: GoogleFonts.robotoMono(fontSize: 12)),
      backgroundColor: _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = null);
    });
  }
}
