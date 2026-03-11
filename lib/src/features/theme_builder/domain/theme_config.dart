import 'package:flutter/material.dart';

class ThemeConfig {
  const ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.brightness,
    this.backgroundColor,
    this.surfaceColor,
    this.accentColor,
    this.fontFamily = 'Inter',
    this.borderRadius = 12.0,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Brightness brightness;
  final Color? backgroundColor;
  final Color? surfaceColor;
  final Color? accentColor;
  final String fontFamily;
  final double borderRadius;

  ThemeConfig copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Brightness? brightness,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? accentColor,
    String? fontFamily,
    double? borderRadius,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      brightness: brightness ?? this.brightness,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

class ThemePreset {
  const ThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.brightness,
    this.background,
    this.surface,
    this.accent,
    this.fontFamily = 'Inter',
    this.borderRadius = 12.0,
    required this.description,
    required this.category,
    this.tag = '',
  });

  final String name;
  final Color primary;
  final Color secondary;
  final Brightness brightness;
  final Color? background;
  final Color? surface;
  final Color? accent;
  final String fontFamily;
  final double borderRadius;
  final String description;
  final String category; // 'dark' | 'light' | 'vivid' | 'earthy' | 'dev'
  final String tag;
}
