class Resource {
  int energy;
  int drones;
  int totalCollected;

  Resource({
    required this.energy,
    required this.drones,
    required this.totalCollected,
  });

  Map<String, dynamic> toMap() {
    return {
      'energy': energy,
      'drones': drones,
      'totalCollected': totalCollected,
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      energy: map['energy'] as int,
      drones: map['drones'] as int,
      totalCollected: map['totalCollected'] as int,
    );
  }
}