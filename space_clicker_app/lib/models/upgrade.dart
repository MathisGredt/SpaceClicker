import 'dart:ui';

class Upgrade {
  final String title;
  final String description;
  final String imagePath;
  final int cost;
  final VoidCallback onApply;

  Upgrade({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.cost,
    required this.onApply,
  });
}