import 'package:flutter/widgets.dart';
import 'feature_item.dart';

class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<FeatureItem> items;
}
