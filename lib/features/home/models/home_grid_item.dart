import 'package:flutter/material.dart';

/// One tile in the home screen grid (Live, Movies, Series, etc.).
class HomeGridItem {
  final String label;
  final IconData icon;
  final String route;

  const HomeGridItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
