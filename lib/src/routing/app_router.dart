import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/audit/presentation/audit_screen.dart';
import '../features/blog/presentation/blog_list_screen.dart';
import '../features/blog/presentation/blog_post_screen.dart';
import '../features/blog/domain/blog_post.dart';

part 'app_router.g.dart';

enum AppRoute { home, audit, blog, post }

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
        ],
      ),
    ],
  );
}
