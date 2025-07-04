class Resource {
  int noctiliumDrones;
  int verdaniteDrones;
  int ignitiumDrones;
  int totalCollected;
  int noctilium;
  int ferralyte;
  int verdanite;
  int ignitium;
  int amarenthite; // ✅ Ajout de la ressource Amarenthite
  int crimsite;    // ✅ Ajout de la ressource Crimsite
  double bonus;

  Resource({
    required this.noctiliumDrones,
    required this.verdaniteDrones,
    required this.ignitiumDrones,
    required this.totalCollected,
    this.noctilium = 0,
    this.ferralyte = 0,
    this.verdanite = 0,
    this.ignitium = 0,
    this.amarenthite = 0, // ✅ Initialisation par défaut
    this.crimsite = 0,    // ✅ Initialisation par défaut
    this.bonus = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'noctiliumDrones': noctiliumDrones,
      'verdaniteDrones': verdaniteDrones,
      'ignitiumDrones': ignitiumDrones,
      'totalCollected': totalCollected,
      'noctilium': noctilium,
      'ferralyte': ferralyte,
      'verdanite': verdanite,
      'ignitium': ignitium,
      'amarenthite': amarenthite, // ✅ Ajout au mapping
      'crimsite': crimsite,       // ✅ Ajout au mapping
      'bonus': bonus,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      noctiliumDrones: map['noctiliumDrones'] as int? ?? 0,
      verdaniteDrones: map['verdaniteDrones'] as int? ?? 0,
      ignitiumDrones: map['ignitiumDrones'] as int? ?? 0,
      totalCollected: map['totalCollected'] as int,
      noctilium: map['noctilium'] as int? ?? 0,
      ferralyte: map['ferralyte'] as int? ?? 0,
      verdanite: map['verdanite'] as int? ?? 0,
      ignitium: map['ignitium'] as int? ?? 0,
      amarenthite: map['amarenthite'] as int? ?? 0, // ✅ Lecture sécurisée
      crimsite: map['crimsite'] as int? ?? 0,       // ✅ Lecture sécurisée
      bonus: (map['bonus'] ?? 1.0).toDouble(),
    );
  }
}