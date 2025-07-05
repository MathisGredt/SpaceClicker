import '../models/resource_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class UpgradeService {
  int noctiliumDroneInterval = 5;
  int verdaniteDroneInterval = 5;
  int ignitiumDroneInterval = 5;

  int ferralyteDrillInterval = 5;
  int crimsiteDrillInterval = 5;
  int amarenthiteDrillInterval = 5;

  final ValueNotifier<Resource?> resourceNotifier = ValueNotifier<Resource?>(null);
  late DatabaseService dbService;

  void reduceDroneInterval(String droneType) {
    final resource = resourceNotifier.value;
    if (resource == null) return;

    switch (droneType.toLowerCase()) {
      case 'noctilium':
        if (noctiliumDroneInterval > 1) {
          noctiliumDroneInterval--;
          resource.noctiliumDroneInterval = noctiliumDroneInterval;
          dbService.saveData(resource);
        }
        break;
      case 'verdanite':
        if (verdaniteDroneInterval > 1) {
          verdaniteDroneInterval--;
          resource.verdaniteDroneInterval = verdaniteDroneInterval;
          dbService.saveData(resource);
        }
        break;
      case 'ignitium':
        if (ignitiumDroneInterval > 1) {
          ignitiumDroneInterval--;
          resource.ignitiumDroneInterval = ignitiumDroneInterval;
          dbService.saveData(resource);
        }
        break;
      default:
        throw ArgumentError("Unknown drone type: $droneType");
    }
  }

  void reduceDrillInterval(String drillType) {
    final resource = resourceNotifier.value;
    if (resource == null) return;

    switch (drillType.toLowerCase()) {
      case 'ferralyte':
        if (ferralyteDrillInterval > 1) {
          ferralyteDrillInterval--;
          resource.ferralyteDrillInterval = ferralyteDrillInterval;
          dbService.saveData(resource);
        }
        break;
      case 'crimsite':
        if (crimsiteDrillInterval > 1) {
          crimsiteDrillInterval--;
          resource.crimsiteDrillInterval = crimsiteDrillInterval;
          dbService.saveData(resource);
        }
        break;
      case 'amarenthite':
        if (amarenthiteDrillInterval > 1) {
          amarenthiteDrillInterval--;
          resource.amarenthiteDrillInterval = amarenthiteDrillInterval;
          dbService.saveData(resource);
        }
        break;
      default:
        throw ArgumentError("Unknown drill type: $drillType");
    }
  }

  void dispose() {
    // Dispose resources if needed
  }
}