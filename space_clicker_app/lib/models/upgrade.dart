import 'package:flutter/material.dart';

class Upgrade {
  final String title;
  final String description;
  final String imagePath;
  final int cost;
  final String? costResource1;
  final int cost2;
  final String? costResource2;
  final VoidCallback onApply;

  Upgrade({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.cost,
    this.costResource1,
    this.cost2 = 0,
    this.costResource2,
    required this.onApply,
  });
}