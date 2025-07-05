class UpgradeService {
  int noctiliumDroneInterval = 5; // Intervalle par défaut en secondes
  int verdaniteDroneInterval = 5;
  int ignitiumDroneInterval = 5;

  int ferralyteDrillInterval = 5;
  int crimsiteDrillInterval = 5;
  int amarenthiteDrillInterval = 5;

  void reduceDroneInterval(String droneType) {
    switch (droneType.toLowerCase()) {
      case 'noctilium':
        if (noctiliumDroneInterval > 1) noctiliumDroneInterval--;
        break;
      case 'verdanite':
        if (verdaniteDroneInterval > 1) verdaniteDroneInterval--;
        break;
      case 'ignitium':
        if (ignitiumDroneInterval > 1) ignitiumDroneInterval--;
        break;
      default:
        throw ArgumentError("Unknown drone type: $droneType");
    }
  }

  void reduceDrillInterval(String drillType) {
    switch (drillType.toLowerCase()) {
      case 'ferralyte':
        if (ferralyteDrillInterval > 1) ferralyteDrillInterval--;
        break;
      case 'crimsite':
        if (crimsiteDrillInterval > 1) crimsiteDrillInterval--;
        break;
      case 'amarenthite':
        if (amarenthiteDrillInterval > 1) amarenthiteDrillInterval--;
        break;
      default:
        throw ArgumentError("Unknown drill type: $drillType");
    }
  }

  void dispose() {
    // Dispose resources if needed
  }
}