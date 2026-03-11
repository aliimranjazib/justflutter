import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/audit/presentation/audit_screen.dart';
import '../features/blog/presentation/blog_list_screen.dart';
import '../features/blog/presentation/blog_post_screen.dart';
import '../features/blog/domain/blog_post.dart';
import '../features/widget_generator/presentation/widget_generator_screen.dart';
import '../features/theme_builder/presentation/theme_generator_screen.dart';
import '../features/json_model/presentation/json_model_screen.dart';
import '../features/color_palette/presentation/color_palette_screen.dart';

part 'app_router.g.dart';

enum AppRoute { home, audit, blog, post, widgetGenerator, themeBuilder, jsonModel, colorPalette }

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'audit',
            name: AppRoute.audit.name,
            builder: (context, state) => const AuditScreen(),
          ),
          GoRoute(
            path: 'blog',
            name: AppRoute.blog.name,
            builder: (context, state) => const BlogListScreen(),
            routes: [
              GoRoute(
                path: 'post',
                name: AppRoute.post.name,
                builder: (context, state) {
                  final extras = state.extra as Map<String, dynamic>;
                  return BlogPostScreen(
                    post: extras['post'] as BlogPost,
                    content: extras['content'] as String,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'widget-generator',
            name: AppRoute.widgetGenerator.name,
            builder: (context, state) => const WidgetGeneratorScreen(),
          ),
          GoRoute(
            path: 'theme-builder',
            name: AppRoute.themeBuilder.name,
            builder: (context, state) => const ThemeGeneratorScreen(),
          ),
          GoRoute(
            path: 'json-model',
            name: AppRoute.jsonModel.name,
            builder: (context, state) => const JsonModelScreen(),
          ),
          GoRoute(
            path: 'color-palette',
            name: AppRoute.colorPalette.name,
            builder: (context, state) => const ColorPaletteScreen(),
          ),
        ],
      ),
    ],
  );
}
