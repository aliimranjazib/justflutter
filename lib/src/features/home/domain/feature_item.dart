import 'package:flutter/widgets.dart';

class FeatureItem {
  const FeatureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final bool isNew;
}
