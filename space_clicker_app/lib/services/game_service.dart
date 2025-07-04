import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/resource_model.dart';
import 'database_service.dart';
import 'bonus_service.dart';
import '../screens/upgrade_screen.dart';

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

  Timer? noctiliumAutoCollectTimer;
  Timer? verdaniteAutoCollectTimer;
  Timer? ignitiumAutoCollectTimer;

  Future<void> init() async {
    await dbService.initDb();
    resource = await dbService.loadData();
  }

  void dispose() {
    noctiliumAutoCollectTimer?.cancel();
    verdaniteAutoCollectTimer?.cancel();
    ignitiumAutoCollectTimer?.cancel();
    bonusService.dispose();
    if (resource != null) dbService.saveData(resource!);
    dbService.closeDb();
  }

  void collectAllResources() {
    collectNoctilium();
    collectVerdanite();
    collectIgnitium();
  }

  void startNoctiliumAutoCollect(VoidCallback onUpdate) {
    noctiliumAutoCollectTimer?.cancel();
    noctiliumAutoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.noctiliumDrones > 0) {
        final collected = (resource!.noctiliumDrones * 2 * bonusService.bonusMultiplier).round();
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

  void startVerdaniteAutoCollect(VoidCallback onUpdate) {
    verdaniteAutoCollectTimer?.cancel();
    verdaniteAutoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.verdaniteDrones > 0) {
        final collected = (resource!.verdaniteDrones * 2 * bonusService.bonusMultiplier).round();
        resource!.verdanite += collected;
        resource!.totalCollected += collected;
        dbService.saveData(resource!);
        onUpdate();
      }
    });
  }

  void collectVerdanite() {
    if (resource == null) return;
    resource!.verdanite++;
    resource!.totalCollected++;
    dbService.saveData(resource!);
  }

  void startIgnitiumAutoCollect(VoidCallback onUpdate) {
    ignitiumAutoCollectTimer?.cancel();
    ignitiumAutoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.ignitiumDrones > 0) {
        final collected = (resource!.ignitiumDrones * 2 * bonusService.bonusMultiplier).round();
        resource!.ignitium += collected;
        resource!.totalCollected += collected;
        dbService.saveData(resource!);
        onUpdate();
      }
    });
  }

  void collectIgnitium() {
    if (resource == null) return;
    resource!.ignitium++;
    resource!.totalCollected++;
    dbService.saveData(resource!);
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _attemptBuyDrone(String droneType, BuildContext context) {
    const cost = 50; // Coût fixe pour chaque drone
    if (resource == null) return;

    switch (droneType) {
      case 'noctilium':
        if (resource!.noctilium >= cost) {
          resource!.noctilium -= cost;
          resource!.noctiliumDrones++;
          _showMessage(context, "Drone de Noctilium acheté !");
        } else {
          _showMessage(context, "Pas assez de Noctilium pour acheter ce drone.");
        }
        break;

      case 'verdanite':
        if (resource!.verdanite >= cost) {
          resource!.verdanite -= cost;
          resource!.verdaniteDrones++;
          _showMessage(context, "Drone de Verdanite acheté !");
        } else {
          _showMessage(context, "Pas assez de Verdanite pour acheter ce drone.");
        }
        break;

      case 'ignitium':
        if (resource!.ignitium >= cost) {
          resource!.ignitium -= cost;
          resource!.ignitiumDrones++;
          _showMessage(context, "Drone d'Ignitium acheté !");
        } else {
          _showMessage(context, "Pas assez d'Ignitium pour acheter ce drone.");
        }
        break;

      default:
        _showMessage(context, "Type de drone inconnu.");
    }
    dbService.saveData(resource!); // Sauvegarde des données
  }

  void handleCommand(String input, BuildContext context) {
    switch (input) {
      case '/upgrade':
        history.add('Commande exécutée : $input');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpgradeScreen()),
        );
        break;
      case '/buy':
        history.add('Commande exécutée : $input');
        // Logique pour la commande /buy
        break;
      default:
        history.add('Commande inconnue : $input');
    }
  }

  List<String> getHistory() => List.unmodifiable(history);
}
