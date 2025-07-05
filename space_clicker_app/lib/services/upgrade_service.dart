class UpgradeService {
  double noctiliumDroneSpeedMultiplier = 1.0;
  double verdaniteDroneSpeedMultiplier = 1.0;
  double ignitiumDroneSpeedMultiplier = 1.0;

  double ferralyteDrillSpeedMultiplier = 1.0;
  double crimsiteDrillSpeedMultiplier = 1.0;
  double amarenthiteDrillSpeedMultiplier = 1.0;

  void reduceDroneCollectionTime(String droneType) {
    switch (droneType.toLowerCase()) {
      case 'noctilium':
        noctiliumDroneSpeedMultiplier *= 0.9; // Reduce collection time by 10%
        break;
      case 'verdanite':
        verdaniteDroneSpeedMultiplier *= 0.9;
        break;
      case 'ignitium':
        ignitiumDroneSpeedMultiplier *= 0.9;
        break;
      default:
        throw ArgumentError("Unknown drone type: $droneType");
    }
  }

  void reduceCollectionTime(String type) {
    switch (type.toLowerCase()) {
      case 'ferralyte':
        ferralyteDrillSpeedMultiplier *= 0.9; // Reduce collection time by 10%
        break;
      case 'crimsite':
        crimsiteDrillSpeedMultiplier *= 0.9;
        break;
      case 'amarenthite':
        amarenthiteDrillSpeedMultiplier *= 0.9;
        break;
      default:
        throw ArgumentError("Unknown type: $type");
    }
  }

  void dispose() {
    // Release resources if necessary
  }
}