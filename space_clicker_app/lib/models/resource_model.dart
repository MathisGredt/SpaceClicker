class Resource {
  int drones;
  int totalCollected;
  int noctilium;
  int ferralyte;
  double bonus; // ✅ Ajout du champ bonus

  Resource({
    required this.drones,
    required this.totalCollected,
    this.noctilium = 0,
    this.ferralyte = 0,
    this.bonus = 1.0, // ✅ Valeur par défaut
  });

  Map<String, dynamic> toMap() {
    return {
      'drones': drones,
      'totalCollected': totalCollected,
      'noctilium': noctilium,
      'ferralyte': ferralyte,
      'bonus': bonus, // ✅ Ajout au mapping
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      drones: map['drones'] as int,
      totalCollected: map['totalCollected'] as int,
      noctilium: map['noctilium'] as int? ?? 0,
      ferralyte: map['ferralyte'] as int? ?? 0,
      bonus: (map['bonus'] ?? 1.0).toDouble(), // ✅ Lecture sécurisée
    );
  }
}
