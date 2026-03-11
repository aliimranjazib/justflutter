import 'package:lucide_icons/lucide_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../routing/app_router.dart';
import '../domain/feature_item.dart';
import '../domain/home_category.dart';

part 'home_repository.g.dart';

class HomeRepository {
  List<HomeCategory> getCategories() {
    return [
      HomeCategory(
        id: 'uilab',
        title: '🧪 UI Lab',
        icon: LucideIcons.layers,
        items: [
          FeatureItem(
            id: 'ui_builder',
            title: 'Drag & Drop UI Builder',
            description:
                'Drag widgets onto a canvas, see a real Flutter preview, and get the generated Dart code instantly.',
            icon: LucideIcons.layoutTemplate,
            route: AppRoute.uiBuilder.name,
            isNew: true,
          ),
        ],
      ),
      HomeCategory(
        id: 'devtools',
        title: 'Developer Tools',
        icon: LucideIcons.code2,
        items: [
          FeatureItem(
            id: 'theme_builder',
            title: 'Theme Builder',
            description:
                'Design complete Flutter ThemeData with live preview and code generation.',
            icon: LucideIcons.palette,
            route: AppRoute.themeBuilder.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'widget_generator',
            title: 'Widget Generator',
            description:
                'Visually configure Flutter widgets and generate ready-to-use code.',
            icon: LucideIcons.layoutTemplate,
            route: AppRoute.widgetGenerator.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'json_model',
            title: 'JSON → Model Generator',
            description:
                'Paste JSON and get a fully-typed Dart model class with fromJson, toJson, copyWith, and more.',
            icon: LucideIcons.braces,
            route: AppRoute.jsonModel.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'color_palette',
            title: 'Color Palette Generator',
            description:
                'Generate harmonious color palettes, Material 3 tones, and WCAG contrast checks from any seed color.',
            icon: LucideIcons.pipette,
            route: AppRoute.colorPalette.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'snippets',
            title: 'Flutter Snippets Library',
            description:
                'Searchable collection of 40+ battle-tested Flutter code patterns, ready to copy.',
            icon: LucideIcons.code2,
            route: AppRoute.snippets.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'icon_browser',
            title: 'Icon Browser',
            description:
                'Browse and search 150+ Material Icons by category. Tap any icon to copy its widget code.',
            icon: LucideIcons.grid,
            route: AppRoute.iconBrowser.name,
            isNew: true,
          ),
          FeatureItem(
            id: 'pubspec_manager',
            title: 'Pubspec Manager',
            description:
                'Visually manage dependencies, browse 30+ popular packages, and export clean YAML.',
            icon: LucideIcons.package,
            route: AppRoute.pubspecManager.name,
            isNew: true,
          ),
        ],
      ),
      HomeCategory(
        id: 'content',
        title: 'Content Tools',
        icon: LucideIcons.fileText,
        items: [
          FeatureItem(
            id: 'blog',
            title: 'AI Daily Blog',
            description:
                'Generate automated blog posts for Flutter topics daily.',
            icon: LucideIcons.newspaper,
            route: AppRoute.blog.name,
            isNew: true,
          ),
        ],
      ),
      HomeCategory(
        id: 'system',
        title: 'System Management',
        icon: LucideIcons.settings,
        items: [
          FeatureItem(
            id: 'audit',
            title: 'Audit System',
            description:
                'Audit your application for accessibility and performance.',
            icon: LucideIcons.shieldCheck,
            route: AppRoute.audit.name,
          ),
        ],
      ),
    ];
  }

  FeatureItem? getFeaturedFeature() {
    return FeatureItem(
      id: 'blog_featured',
      title: 'Generate Today\'s Blog',
      description:
          'Your AI assistant is ready to write about the latest Flutter trends.',
      icon: LucideIcons.sparkles,
      route: AppRoute.blog.name,
    );
  }
}

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository();
}
