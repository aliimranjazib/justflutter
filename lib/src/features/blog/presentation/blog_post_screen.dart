import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/blog_post.dart';

class BlogPostScreen extends StatelessWidget {
  final BlogPost post;
  final String content;

  const BlogPostScreen({super.key, required this.post, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${post.date.day}/${post.date.month}/${post.date.year}',
              style: GoogleFonts.inter(
                color: const Color(0xFF3B82F6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              post.title,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.6,
                ),
                h1: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                h2: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                code: GoogleFonts.firaCode(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  color: const Color(0xFF3B82F6),
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
