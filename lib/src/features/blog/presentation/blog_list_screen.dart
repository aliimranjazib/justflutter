import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../data/blog_repository.dart';
import '../domain/blog_post.dart';
import '../../../routing/app_router.dart';

class BlogListScreen extends ConsumerWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogPosts = ref.watch(blogRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'FLUTTER BLOG',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B82F6),
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.goNamed(AppRoute.home.name),
        ),
      ),
      body: blogPosts.when(
        data: (posts) => posts.isEmpty
            ? _buildEmptyState()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Daily Insights',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Generated blogs on the latest Flutter trends',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _BlogPostCard(post: post);
                        },
                      ),
                    ),
                  ],
                ),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.white24),
          const SizedBox(height: 24),
          Text(
            'No blog posts yet.',
            style: GoogleFonts.outfit(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Run the AI script to generate your first post!',
            style: GoogleFonts.inter(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _BlogPostCard extends ConsumerWidget {
  final BlogPost post;
  const _BlogPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: () async {
          final repo = ref.read(blogRepositoryProvider.notifier);
          final content = await repo.fetchPostContent(post.filename ?? '');
          if (context.mounted) {
            context.goNamed(
              AppRoute.post.name,
              extra: {'post': post, 'content': content},
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'FLUTTER',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${post.date.day}/${post.date.month}/${post.date.year}',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                post.title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                post.excerpt,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Read More',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
