import 'dart:convert';
import 'package:http/http.dart' as http;

class PubPackageInfo {
  final String name;
  final String version;
  final String description;
  final String? dartSdkConstraint;
  final String? repository;
  final String? homepage;
  final String? documentation;

  PubPackageInfo({
    required this.name,
    required this.version,
    required this.description,
    this.dartSdkConstraint,
    this.repository,
    this.homepage,
    this.documentation,
  });

  factory PubPackageInfo.fromJson(Map<String, dynamic> json) {
    final latest = json['latest'];
    final pubspec = latest['pubspec'];
    final env = pubspec['environment'] as Map<String, dynamic>?;

    return PubPackageInfo(
      name: json['name'] as String,
      version: latest['version'] as String,
      description: (pubspec['description'] as String?) ?? '',
      dartSdkConstraint: env?['sdk'] as String?,
      repository: pubspec['repository'] as String?,
      homepage: pubspec['homepage'] as String?,
      documentation: pubspec['documentation'] as String?,
    );
  }
}

class PubPackageMetrics {
  final int points;
  final int maxPoints;
  final int likes;
  final List<String> tags;

  PubPackageMetrics({
    this.points = 0,
    this.maxPoints = 0,
    this.likes = 0,
    this.tags = const [],
  });

  factory PubPackageMetrics.fromJson(Map<String, dynamic> json) {
    var scoreJson = json['score'] as Map<String, dynamic>?;
    if (scoreJson == null) return PubPackageMetrics();
    
    // tags is a list of strings
    final tagsList = (scoreJson['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return PubPackageMetrics(
      points: scoreJson['grantedPoints'] as int? ?? 0,
      maxPoints: scoreJson['maxPoints'] as int? ?? 0,
      likes: scoreJson['likeCount'] as int? ?? 0,
      tags: tagsList,
    );
  }

  bool get supportsWeb => tags.contains('platform:web');
  bool get supportsIos => tags.contains('platform:ios');
  bool get supportsAndroid => tags.contains('platform:android');
  bool get supportsMacOs => tags.contains('platform:macos');
  bool get supportsWindows => tags.contains('platform:windows');
  bool get supportsLinux => tags.contains('platform:linux');
}

class PubRepository {
  static const _baseUrl = 'https://pub.dev/api';

  Future<PubPackageInfo?> getPackageInfo(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/packages/$name'));
      if (response.statusCode == 200) {
        return PubPackageInfo.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Logic for error handling
    }
    return null;
  }

  Future<List<String>> searchPackages(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List packages = data['packages'] ?? [];
        return packages.map((p) => p['package'] as String).toList();
      }
    } catch (_) {
      // Logic for error handling
    }
    return [];
  }

  Future<PubPackageMetrics?> getPackageMetrics(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/packages/$name/metrics'));
      if (response.statusCode == 200) {
        return PubPackageMetrics.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Return empty metrics if fetch fails
    }
    return null;
  }

  Future<List<String>> getFlutterFavorites() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=is:flutter-favorite'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List packages = data['packages'] ?? [];
        return packages.map((p) => p['package'] as String).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<String>> getTopPackages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=&sort=like'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List packages = data['packages'] ?? [];
        return packages.map((p) => p['package'] as String).toList();
      }
    } catch (_) {}
    return [];
  }
}
