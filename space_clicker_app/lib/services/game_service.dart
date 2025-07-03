import 'dart:async';
import 'package:flutter/foundation.dart';  // <-- ajoute ça
import '../models/resource_model.dart';
import 'database_service.dart';
import 'bonus_service.dart';

class GameService {
  static final GameService _instance = GameService._internal();

  factory GameService() => _instance;

  GameService._internal();

  // Getter statique pour accéder à l'instance
  static GameService get instance => _instance;

  final DatabaseService dbService = DatabaseService();
  final BonusService bonusService = BonusService();

  Resource? resource;
  List<String> history = [];

  Timer? autoCollectTimer;

  Future<void> init() async {
    await dbService.initDb();
    resource = await dbService.loadData();
  }

  void dispose() {
    autoCollectTimer?.cancel();
    bonusService.dispose();
    if (resource != null) dbService.saveData(resource!);
    dbService.closeDb();
  }

  void startAutoCollect(VoidCallback onUpdate) {
    autoCollectTimer?.cancel();

    autoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.drones > 0) {
        final collected = (resource!.drones * 2 * bonusService.bonusMultiplier).round();
        resource!.noctilium += collected;
        resource!.totalCollected += collected;
        dbService.saveData(resource!);
        onUpdate();
      }
    });
  }

  void collectNoctilium() {
    if (resource == null) return;
    resource!.noctilium++;
    resource!.totalCollected++;
    dbService.saveData(resource!);
  }

  bool buyDrone() {
    const cost = 50;
    if (resource != null && resource!.noctilium >= cost) {
      resource!.noctilium -= cost;
      resource!.drones++;
      history.add("Drone acheté !");
      dbService.saveData(resource!);
      return true;
    } else {
      history.add("Pas assez de Noctilium pour acheter un drone");
      return false;
    }
  }

  void handleCommand(String input) {
    switch (input.toLowerCase()) {
      case 'help':
        history.add('Commandes disponibles : help, buy, move');
        break;
      case 'buy':
        buyDrone();
        break;
      default:
        history.add('Commande inconnue : $input');
    }
  }

  List<String> getHistory() => List.unmodifiable(history);
}
