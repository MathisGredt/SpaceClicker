class Resource {
  int noctiliumDrones;
  int verdaniteDrones;
  int ignitiumDrones;
  int amarenthiteDrills;
  int crimsiteDrills;
  int ferralyteDrills;
  int totalCollected;
  int noctilium;
  int ferralyte;
  int verdanite;
  int ignitium;
  int amarenthite;
  int crimsite;
  bool hasPaidSecondPlanet;
  bool hasPaidThirdPlanet;
  double bonus;

  int noctiliumDroneInterval;
  int verdaniteDroneInterval;
  int ignitiumDroneInterval;
  int ferralyteDrillInterval;
  int crimsiteDrillInterval;
  int amarenthiteDrillInterval;

  Resource({
    required this.noctiliumDrones,
    required this.verdaniteDrones,
    required this.ignitiumDrones,
    required this.amarenthiteDrills,
    required this.crimsiteDrills,
    required this.ferralyteDrills,
    required this.noctiliumDroneInterval,
    required this.verdaniteDroneInterval,
    required this.ignitiumDroneInterval,
    required this.ferralyteDrillInterval,
    required this.crimsiteDrillInterval,
    required this.amarenthiteDrillInterval,
    required this.totalCollected,
    this.hasPaidSecondPlanet = false,
    this.hasPaidThirdPlanet = false,
    this.noctilium = 0,
    this.ferralyte = 0,
    this.verdanite = 0,
    this.ignitium = 0,
    this.amarenthite = 0,
    this.crimsite = 0,
    this.bonus = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'noctiliumDrones': noctiliumDrones,
      'verdaniteDrones': verdaniteDrones,
      'ignitiumDrones': ignitiumDrones,
      'amarenthiteDrills': amarenthiteDrills,
      'crimsiteDrills': crimsiteDrills,
      'ferralyteDrills': ferralyteDrills,
      'totalCollected': totalCollected,
      'noctilium': noctilium,
      'ferralyte': ferralyte,
      'verdanite': verdanite,
      'ignitium': ignitium,
      'amarenthite': amarenthite,
      'crimsite': crimsite,
      'bonus': bonus,
      'noctiliumDroneInterval': noctiliumDroneInterval,
      'verdaniteDroneInterval': verdaniteDroneInterval,
      'ignitiumDroneInterval': ignitiumDroneInterval,
      'ferralyteDrillInterval': ferralyteDrillInterval,
      'crimsiteDrillInterval': crimsiteDrillInterval,
      'amarenthiteDrillInterval': amarenthiteDrillInterval,
      'hasPaidSecondPlanet': hasPaidSecondPlanet ? 1 : 0,
      'hasPaidThirdPlanet': hasPaidThirdPlanet ? 1 : 0,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      noctiliumDrones: map['noctiliumDrones'] as int? ?? 0,
      verdaniteDrones: map['verdaniteDrones'] as int? ?? 0,
      ignitiumDrones: map['ignitiumDrones'] as int? ?? 0,
      amarenthiteDrills: map['amarenthiteDrills'] as int? ?? 0,
      crimsiteDrills: map['crimsiteDrills'] as int? ?? 0,
      ferralyteDrills: map['ferralyteDrills'] as int? ?? 0,
      totalCollected: map['totalCollected'] as int,
      noctilium: map['noctilium'] as int? ?? 0,
      ferralyte: map['ferralyte'] as int? ?? 0,
      verdanite: map['verdanite'] as int? ?? 0,
      ignitium: map['ignitium'] as int? ?? 0,
      amarenthite: map['amarenthite'] as int? ?? 0,
      crimsite: map['crimsite'] as int? ?? 0,
      bonus: (map['bonus'] ?? 1.0).toDouble(),
      noctiliumDroneInterval: map['noctiliumDroneInterval'] as int? ?? 5,
      verdaniteDroneInterval: map['verdaniteDroneInterval'] as int? ?? 5,
      ignitiumDroneInterval: map['ignitiumDroneInterval'] as int? ?? 5,
      ferralyteDrillInterval: map['ferralyteDrillInterval'] as int? ?? 5,
      crimsiteDrillInterval: map['crimsiteDrillInterval'] as int? ?? 5,
      amarenthiteDrillInterval: map['amarenthiteDrillInterval'] as int? ?? 5,
      hasPaidSecondPlanet: map['hasPaidSecondPlanet'] == 1,
      hasPaidThirdPlanet: map['hasPaidThirdPlanet'] == 1,
    );
  }
}