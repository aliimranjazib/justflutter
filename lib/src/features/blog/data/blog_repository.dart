import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/blog_post.dart';

part 'blog_repository.g.dart';

@riverpod
class BlogRepository extends _$BlogRepository {
  @override
  FutureOr<List<BlogPost>> build() async {
    try {
      final String response = await rootBundle.loadString('assets/posts.json');
      final data = await json.decode(response) as List<dynamic>;
      
      return data.map((json) => BlogPost(
        id: json['id'],
        title: json['title'],
        excerpt: json['excerpt'],
        content: '', 
        date: DateTime.parse(json['date']),
        filename: json['filename'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String> fetchPostContent(String filename) async {
    try {
      return await rootBundle.loadString('assets/posts/$filename');
    } catch (e) {
      return 'Content not found.';
    }
  }
}
