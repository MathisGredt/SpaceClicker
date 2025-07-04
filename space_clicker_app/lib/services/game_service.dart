import 'dart:async';
import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import 'database_service.dart';
import 'bonus_service.dart';
import '../screens/upgrade_screen.dart';

class GameService {
  static final GameService _instance = GameService._internal();

  factory GameService() => _instance;

  GameService._internal();

  static GameService get instance => _instance;

  final DatabaseService dbService = DatabaseService();
  final BonusService bonusService = BonusService();

  final ValueNotifier<Resource?> resourceNotifier = ValueNotifier<Resource?>(null);

  List<String> history = [];

  Timer? noctiliumAutoCollectTimer;
  Timer? verdaniteAutoCollectTimer;
  Timer? ignitiumAutoCollectTimer;

  Future<void> init() async {
    await dbService.initDb();
    resourceNotifier.value = await dbService.loadData();
  }

  void dispose() {
    noctiliumAutoCollectTimer?.cancel();
    verdaniteAutoCollectTimer?.cancel();
    ignitiumAutoCollectTimer?.cancel();
    bonusService.dispose();
    if (resourceNotifier.value != null) dbService.saveData(resourceNotifier.value!);
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
      final r = resourceNotifier.value;
      if (r != null && r.noctiliumDrones > 0) {
        final collected = (r.noctiliumDrones * 2 * bonusService.bonusMultiplier).round();
        r.noctilium += collected;
        r.totalCollected += collected;
        dbService.saveData(r);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectNoctilium() {
    final r = resourceNotifier.value;
    if (r == null) return;
    r.noctilium++;
    r.totalCollected++;
    dbService.saveData(r);
    resourceNotifier.notifyListeners();
  }

  void startVerdaniteAutoCollect(VoidCallback onUpdate) {
    verdaniteAutoCollectTimer?.cancel();
    verdaniteAutoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final r = resourceNotifier.value;
      if (r != null && r.verdaniteDrones > 0) {
        final collected = (r.verdaniteDrones * 2 * bonusService.bonusMultiplier).round();
        r.verdanite += collected;
        r.totalCollected += collected;
        dbService.saveData(r);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectVerdanite() {
    final r = resourceNotifier.value;
    if (r == null) return;
    r.verdanite++;
    r.totalCollected++;
    dbService.saveData(r);
    resourceNotifier.notifyListeners();
  }

  void startIgnitiumAutoCollect(VoidCallback onUpdate) {
    ignitiumAutoCollectTimer?.cancel();
    ignitiumAutoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      final r = resourceNotifier.value;
      if (r != null && r.ignitiumDrones > 0) {
        final collected = (r.ignitiumDrones * 2 * bonusService.bonusMultiplier).round();
        r.ignitium += collected;
        r.totalCollected += collected;
        dbService.saveData(r);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectIgnitium() {
    final r = resourceNotifier.value;
    if (r == null) return;
    r.ignitium++;
    r.totalCollected++;
    dbService.saveData(r);
    resourceNotifier.notifyListeners();
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Achat d'un drone, type: 'noctilium', 'verdanite', 'ignitium'
  void attemptBuyDrone(String droneType, BuildContext context) {
    const cost = 50;
    final r = resourceNotifier.value;
    if (r == null) return;

    switch (droneType.toLowerCase()) {
      case 'noctilium':
        if (r.noctilium >= cost) {
          r.noctilium -= cost;
          r.noctiliumDrones++;
          _showMessage(context, "Drone de Noctilium acheté !");
          dbService.saveData(r);
          startNoctiliumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Noctilium pour acheter ce drone.");
        }
        break;
      case 'verdanite':
        if (r.verdanite >= cost) {
          r.verdanite -= cost;
          r.verdaniteDrones++;
          _showMessage(context, "Drone de Verdanite acheté !");
          dbService.saveData(r);
          startVerdaniteAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Verdanite pour acheter ce drone.");
        }
        break;
      case 'ignitium':
        if (r.ignitium >= cost) {
          r.ignitium -= cost;
          r.ignitiumDrones++;
          _showMessage(context, "Drone d'Ignitium acheté !");
          dbService.saveData(r);
          startIgnitiumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez d'Ignitium pour acheter ce drone.");
        }
        break;
      default:
        _showMessage(context, "Type de drone inconnu.");
    }
  }

  void handleCommand(String input, BuildContext context) {
    // Ajout de la gestion de /buy <type>
    final trimmedInput = input.trim();
    if (trimmedInput.startsWith('/buy')) {
      final parts = trimmedInput.split(RegExp(r'\s+'));
      if (parts.length == 2) {
        final droneType = parts[1].toLowerCase();
        history.add('Commande exécutée : $input');
        attemptBuyDrone(droneType, context);
      } else {
        history.add('Commande incorrecte : $input');
        _showMessage(context, "Commande /buy invalide. Usage : /buy <noctilium|verdanite|ignitium>");
      }
      return;
    }

    // Commandes classiques
    switch (trimmedInput) {
      case '/upgrade':
        history.add('Commande exécutée : $input');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpgradeScreen()),
        );
        break;
      default:
        history.add('Commande inconnue : $input');
    }
  }

  List<String> getHistory() => List.unmodifiable(history);
}