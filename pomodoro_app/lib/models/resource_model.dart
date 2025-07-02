class Resource {
  int drones;
  int totalCollected;
  int noctilium;
  int ferralyte;

  Resource({
    required this.drones,
    required this.totalCollected,
    this.noctilium = 0,
    this.ferralyte = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'drones': drones,
      'totalCollected': totalCollected,
      'noctilium': noctilium,
      'ferralyte': ferralyte,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      drones: map['drones'] as int,
      totalCollected: map['totalCollected'] as int,
      noctilium: map['noctilium'] as int,
      ferralyte: map['ferralyte'] as int,
    );
  }
}