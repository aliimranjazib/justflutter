import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/color_input_panel.dart';
import 'widgets/preset_gallery.dart';
import 'widgets/theme_preview_playground.dart';
import 'widgets/theme_code_panel.dart';

class ThemeGeneratorScreen extends StatelessWidget {
  const ThemeGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final isTablet = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Theme Builder',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withOpacity(0.05), height: 1),
        ),
      ),
      body: _buildLayout(context, isDesktop, isTablet),
    );
  }

  Widget _buildLayout(BuildContext context, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: [
          SizedBox(
            width: 320,
            child: Column(
              children: const [
                Expanded(
                  flex: 2,
                  child: ColorInputPanel(),
                ),
                Expanded(
                  flex: 3,
                  child: PresetGallery(),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 2,
            child: ThemePreviewPlayground(),
          ),
          const SizedBox(
            width: 380,
            child: ThemeCodePanel(),
          ),
        ],
      );
    } else if (isTablet) {
      return Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: const [
                Expanded(
                  flex: 2,
                  child: ColorInputPanel(),
                ),
                Expanded(
                  flex: 3,
                  child: PresetGallery(),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Expanded(child: ThemePreviewPlayground()),
                SizedBox(height: 300, child: ThemeCodePanel()),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile - Tabbed layout
      return const DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Colors'),
                Tab(text: 'Presets'),
                Tab(text: 'Preview'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(child: ColorInputPanel()),
                  PresetGallery(),
                  Column(
                    children: [
                      Expanded(child: ThemePreviewPlayground()),
                      Expanded(child: ThemeCodePanel()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
