import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/widget_picker_panel.dart';
import 'widgets/property_editor_panel.dart';
import 'widgets/live_preview_panel.dart';
import 'widgets/code_generator_panel.dart';

class WidgetGeneratorScreen extends StatelessWidget {
  const WidgetGeneratorScreen({super.key});

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
          'Widget Generator',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info, color: Colors.white30, size: 18),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
          const SizedBox(width: 260, child: WidgetPickerPanel()),
          const SizedBox(width: 320, child: PropertyEditorPanel()),
          Expanded(
            child: Column(
              children: [
                const Expanded(flex: 3, child: LivePreviewPanel()),
                const Expanded(flex: 2, child: CodeGeneratorPanel()),
              ],
            ),
          ),
        ],
      );
    } else if (isTablet) {
      return Row(
        children: [
          const SizedBox(width: 240, child: WidgetPickerPanel()),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Expanded(child: PropertyEditorPanel()),
                      const Expanded(child: LivePreviewPanel()),
                    ],
                  ),
                ),
                const SizedBox(height: 240, child: CodeGeneratorPanel()),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile - Just use a vertical layout for now or TABS as planned
      return const DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Pick'),
                Tab(text: 'Edit'),
                Tab(text: 'Preview'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  WidgetPickerPanel(),
                  PropertyEditorPanel(),
                  Column(
                    children: [
                      Expanded(child: LivePreviewPanel()),
                      Expanded(child: CodeGeneratorPanel()),
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
