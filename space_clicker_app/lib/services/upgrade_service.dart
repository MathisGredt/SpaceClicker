import '../models/resource_model.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'game_service.dart';

class UpgradeService {
  ValueNotifier<Resource?> get resourceNotifier => GameService.instance.resourceNotifier;
  DatabaseService get dbService => GameService.instance.dbService;

  void incrementNoctiliumMult(){
    final resource = resourceNotifier.value;
    if (resource != null) {
      resource.noctiliumClickMult++;
      dbService.saveData(resource);
    }
  }

  void incrementVerdaniteMult(){
    final resource = resourceNotifier.value;
    if (resource != null) {
      resource.verdaniteClickMult++;
      dbService.saveData(resource);
    }
  }

  void incrementIgnitiumMult(){
    final resource = resourceNotifier.value;
    if (resource != null) {
      resource.ignitiumClickMult++;
      dbService.saveData(resource);
    }
  }

  void reduceDroneInterval(String droneType) {
    final resource = resourceNotifier.value;
    if (resource == null) {
      return;
    }

    switch (droneType.toLowerCase()) {
      case 'noctilium':
        if (resource.noctiliumDroneInterval > 1) {
          resource.noctiliumDroneInterval--;
          dbService.saveData(resource);
        }
        break;
      case 'verdanite':
        if (resource.verdaniteDroneInterval > 1) {
          resource.verdaniteDroneInterval--;
          dbService.saveData(resource);
        }
        break;
      case 'ignitium':
        if (resource.ignitiumDroneInterval > 1) {
          resource.ignitiumDroneInterval--;
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
        if (resource.ferralyteDrillInterval > 1) {
          resource.ferralyteDrillInterval--;
          dbService.saveData(resource);
        }
        break;
      case 'crimsite':
        if (resource.crimsiteDrillInterval > 1) {
          resource.crimsiteDrillInterval--;
          dbService.saveData(resource);
        }
        break;
      case 'amarenthite':
        if (resource.amarenthiteDrillInterval > 1) {
          resource.amarenthiteDrillInterval--;
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