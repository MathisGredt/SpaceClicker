import 'dart:async';
import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import 'database_service.dart';
import 'bonus_service.dart';
import '../screens/upgrade_screen.dart';

// ==== COMMAND HELP CONSTANTS ====

const String usageGeneral = '''
Commandes disponibles :
  /upgrade      -> Ouvre la page d'amélioration
  /buy          -> Acheter un objet (drone, etc)
  /store        -> Affiche la liste des objets achetables
  /clear        -> Vide le terminal
Pour l'aide sur une commande : <commande> help (ex: /buy help)
/buy <objet> [quantité]  pour acheter plusieurs
''';

const String usageBuy = '''
Utilisation: /buy <objet> [quantité]
Exemple: /buy noctiliumdrone 5
Pour l'aide sur un objet : /buy help
Objets disponibles : noctiliumdrone, verdanitedrone, ignitiumdrone
''';

const String usageStore = '''
Utilisation: /store
Affiche la liste des objets achetables (pour l'instant: drones de ressources).
Exemple: /store
''';

const String usageUpgrade = '''
Utilisation: /upgrade
Ouvre la page d'amélioration.
''';

// ==== GAME SERVICE ====

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
    history.add('Aide générale:');
    history.add(usageGeneral);
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

  /// Renvoie le coût actuel d'achat d'un drone pour un type donné
  int getCurrentDronePrice(String droneType, Resource r) {
    switch (droneType) {
      case 'noctiliumdrone':
        return 50 + 50 * r.noctiliumDrones;
      case 'verdanitedrone':
        return 50 + 50 * r.verdaniteDrones;
      case 'ignitiumdrone':
        return 50 + 50 * r.ignitiumDrones;
      default:
        return 999999; // Impossible
    }
  }

  /// Achat d'un drone, type: 'noctiliumdrone', 'verdanitedrone', 'ignitiumdrone'
  void attemptBuyDrone(String droneType, BuildContext context) {
    final r = resourceNotifier.value;
    if (r == null) return;

    int cost = getCurrentDronePrice(droneType, r);

    switch (droneType.toLowerCase()) {
      case 'noctiliumdrone':
        if (r.noctilium >= cost) {
          r.noctilium -= cost;
          r.noctiliumDrones++;
          _showMessage(context, "Drone de Noctilium acheté pour $cost !");
          history.add("Drone de Noctilium acheté pour $cost !");
          dbService.saveData(r);
          startNoctiliumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Noctilium pour acheter ce drone (coût: $cost).");
          history.add("Pas assez de Noctilium pour acheter ce drone (coût: $cost).");
        }
        break;
      case 'verdanitedrone':
        if (r.verdanite >= cost) {
          r.verdanite -= cost;
          r.verdaniteDrones++;
          _showMessage(context, "Drone de Verdanite acheté pour $cost !");
          history.add("Drone de Verdanite acheté pour $cost !");
          dbService.saveData(r);
          startVerdaniteAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Verdanite pour acheter ce drone (coût: $cost).");
          history.add("Pas assez de Verdanite pour acheter ce drone (coût: $cost).");
        }
        break;
      case 'ignitiumdrone':
        if (r.ignitium >= cost) {
          r.ignitium -= cost;
          r.ignitiumDrones++;
          _showMessage(context, "Drone d'Ignitium acheté pour $cost !");
          history.add("Drone d'Ignitium acheté pour $cost !");
          dbService.saveData(r);
          startIgnitiumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez d'Ignitium pour acheter ce drone (coût: $cost).");
          history.add("Pas assez d'Ignitium pour acheter ce drone (coût: $cost).");
        }
        break;
      default:
        _showMessage(context, "Type de drone inconnu.");
        history.add("Type de drone inconnu.");
    }
  }

  void handleCommand(String input, BuildContext context) {
    final trimmedInput = input.trim();
    final lower = trimmedInput.toLowerCase();

    // Ajoute la commande tapée à l'historique, façon terminal
    history.add("> $input");

    // /clear — vide le terminal
    if (lower == '/clear') {
      history.clear();
      resourceNotifier.notifyListeners();
      return;
    }

    // Gestion aide globale
    if (lower == '/help' || lower == 'help') {
      history.add('Aide générale:');
      history.add(usageGeneral);
      resourceNotifier.notifyListeners();
      return;
    }

    // /buy help ou /store help
    if (lower.startsWith('/buy help')) {
      history.add(usageBuy);
      resourceNotifier.notifyListeners();
      return;
    }
    if (lower.startsWith('/store help')) {
      history.add(usageStore);
      resourceNotifier.notifyListeners();
      return;
    }
    if (lower.startsWith('/upgrade help')) {
      history.add(usageUpgrade);
      resourceNotifier.notifyListeners();
      return;
    }

    // /store — affiche la boutique
    if (lower == '/store') {
      final r = resourceNotifier.value;
      history.add('Objets disponibles à l\'achat:');
      history.add('- noctiliumdrone (${getCurrentDronePrice('noctiliumdrone', r!)} noctilium)');
      history.add('- verdanitedrone (${getCurrentDronePrice('verdanitedrone', r)} verdanite)');
      history.add('- ignitiumdrone (${getCurrentDronePrice('ignitiumdrone', r)} ignitium)');
      history.add('Utilisez /buy <objet> [quantité]');
      resourceNotifier.notifyListeners();
      return;
    }

    // /buy [objet] [quantité]
    if (lower.startsWith('/buy')) {
      final parts = trimmedInput.split(RegExp(r'\s+'));
      if (parts.length == 2 || parts.length == 3) {
        final droneType = parts[1].toLowerCase();
        final quantity = (parts.length == 3) ? int.tryParse(parts[2]) ?? 1 : 1;
        for (int i = 0; i < quantity; i++) {
          attemptBuyDrone(droneType, context);
        }
        history.add("Tentative d'achat de $quantity $droneType.");
        resourceNotifier.notifyListeners();
      } else {
        history.add(usageBuy);
        resourceNotifier.notifyListeners();
      }
      return;
    }

    // /upgrade — ouvre la page d'amélioration
    if (lower == '/upgrade') {
      history.add('Commande exécutée : $input');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UpgradeScreen()),
      );
      resourceNotifier.notifyListeners();
      return;
    }

    history.add('Commande inconnue : $input');
    resourceNotifier.notifyListeners();
  }

  List<String> getHistory() => List.unmodifiable(history);
}