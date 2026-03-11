class BlogPost {
  final String id;
  final String title;
  final String excerpt;
  final String content;
  final DateTime date;
  final String? coverImage;
  final String? filename;

  BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    this.coverImage,
    this.filename,
  });
}
