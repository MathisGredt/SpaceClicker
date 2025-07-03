class Resource {
  int drones;
  int totalCollected;
  int noctilium;
  int ferralyte;
  int verdanite; // ✅ Ajout de la ressource Verdanite
  int ignitium;  // ✅ Ajout de la ressource Ignitium
  double bonus;

  Resource({
    required this.drones,
    required this.totalCollected,
    this.noctilium = 0,
    this.ferralyte = 0,
    this.verdanite = 0, // ✅ Initialisation par défaut
    this.ignitium = 0,  // ✅ Initialisation par défaut
    this.bonus = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'drones': drones,
      'totalCollected': totalCollected,
      'noctilium': noctilium,
      'ferralyte': ferralyte,
      'verdanite': verdanite, // ✅ Ajout au mapping
      'ignitium': ignitium,   // ✅ Ajout au mapping
      'bonus': bonus,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      drones: map['drones'] as int,
      totalCollected: map['totalCollected'] as int,
      noctilium: map['noctilium'] as int? ?? 0,
      ferralyte: map['ferralyte'] as int? ?? 0,
      verdanite: map['verdanite'] as int? ?? 0, // ✅ Lecture sécurisée
      ignitium: map['ignitium'] as int? ?? 0,   // ✅ Lecture sécurisée
      bonus: (map['bonus'] ?? 1.0).toDouble(),
    );
  }
}