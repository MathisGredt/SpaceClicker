import 'dart:async';
import 'package:flutter/material.dart';
import '../models/resource_model.dart';
import 'database_service.dart';
import 'upgrade_service.dart';
import '../screens/upgrade_screen.dart';

// ==== COMMAND HELP CONSTANTS ====

const String usageGeneral = '''
Commandes disponibles :
  /upgrade      -> Ouvre la page d'amélioration
  /buy          -> Acheter un objet (drone, etc)
  /store        -> Affiche la liste des objets achetables
  /clear        -> Vide le terminal
Pour l'aide sur une commande : <commande> help (ex: /buy help)
''';

const String usageBuy = '''
Utilisation: /buy <itemtype> <objet> [quantité]
Exemple: /buy drone noctilium 5
Pour l'aide sur un objet : /buy help
Objets disponibles : drone, drill
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
  final UpgradeService upgradeService = UpgradeService();

  final ValueNotifier<Resource?> resourceNotifier = ValueNotifier<Resource?>(null);

  List<String> history = [];

  Timer? noctiliumDroneTimer;
  Timer? verdaniteDroneTimer;
  Timer? ignitiumDroneTimer;
  Timer? ferralyteDrillTimer;
  Timer? crimsiteDrillTimer;
  Timer? amarenthiteDrillTimer;

  Future<void> init() async {
    await dbService.initDb();
    resourceNotifier.value = await dbService.loadData();
    history.add('Aide générale:');
    history.add(usageGeneral);
  }

  void dispose() {
    noctiliumDroneTimer?.cancel();
    verdaniteDroneTimer?.cancel();
    ignitiumDroneTimer?.cancel();
    ferralyteDrillTimer?.cancel();
    crimsiteDrillTimer?.cancel();
    amarenthiteDrillTimer?.cancel();
    upgradeService.dispose();
    if (resourceNotifier.value != null) dbService.saveData(resourceNotifier.value!);
    dbService.closeDb();
  }

  void collectAllResources() {
    collectNoctilium();
    collectVerdanite();
    collectIgnitium();
  }

  void stopAllDrillAutoCollect() {
    ferralyteDrillTimer?.cancel();
    crimsiteDrillTimer?.cancel();
    amarenthiteDrillTimer?.cancel();
  }

  void startNoctiliumAutoCollect(VoidCallback onUpdate) {
    noctiliumDroneTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.noctiliumDroneInterval);
    noctiliumDroneTimer = Timer.periodic(interval, (timer) {
      if (resource.noctiliumDrones > 0 && resource.noctilium < 1000) { // Vérifie le stockage max
        resource.noctilium += resource.noctiliumDrones;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void startFerralyteDrillAutoCollect(VoidCallback onUpdate) {
    ferralyteDrillTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.ferralyteDrillInterval);
    ferralyteDrillTimer = Timer.periodic(interval, (timer) {
      if (resource.ferralyteDrills > 0 && resource.ferralyte < 1000) { // Vérifie le stockage max
        resource.ferralyte += resource.ferralyteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectNoctilium() {
    final r = resourceNotifier.value;
    if (r == null || r.noctilium >= 1000) return; // Vérifie le stockage max
    r.noctilium++;
    r.totalCollected++;
    dbService.saveData(r);
    resourceNotifier.notifyListeners();
  }

  void startVerdaniteAutoCollect(VoidCallback onUpdate) {
    verdaniteDroneTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.verdaniteDroneInterval);
    verdaniteDroneTimer = Timer.periodic(interval, (timer) {
      if (resource.verdaniteDrones > 0 && resource.verdanite < 1000) { // Vérifie le stockage max
        resource.verdanite += resource.verdaniteDrones;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void startCrimsiteDrillAutoCollect(VoidCallback onUpdate) {
    crimsiteDrillTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.crimsiteDrillInterval);
    crimsiteDrillTimer = Timer.periodic(interval, (timer) {
      if (resource.crimsiteDrills > 0 && resource.crimsite < 1000) { // Vérifie le stockage max
        resource.crimsite += resource.crimsiteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectVerdanite() {
    final r = resourceNotifier.value;
    if (r == null || r.verdanite >= 1000) return; // Vérifie le stockage max
    r.verdanite++;
    r.totalCollected++;
    dbService.saveData(r);
    resourceNotifier.notifyListeners();
  }

  void startIgnitiumAutoCollect(VoidCallback onUpdate) {
    ignitiumDroneTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.ignitiumDroneInterval);
    ignitiumDroneTimer = Timer.periodic(interval, (timer) {
      if (resource.ignitiumDrones > 0 && resource.verdanite < 1000) {
        resource.ignitium += resource.ignitiumDrones;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void startAmarenthiteDrillAutoCollect(VoidCallback onUpdate) {
    amarenthiteDrillTimer?.cancel();
    final resource = resourceNotifier.value;
    if (resource == null) return;
    final interval = Duration(seconds: resource.amarenthiteDrillInterval);
    amarenthiteDrillTimer = Timer.periodic(interval, (timer) {
      if (resource.amarenthiteDrills > 0 && resource.amarenthite < 1000) { // Vérifie le stockage max
        resource.amarenthite += resource.amarenthiteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners();
        onUpdate();
      }
    });
  }

  void collectIgnitium() {
    final r = resourceNotifier.value;
    if (r == null || r.verdanite >= 1000) return;
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
      case 'noctilium':
        return 50 + 50 * r.noctiliumDrones;
      case 'verdanite':
        return 50 + 50 * r.verdaniteDrones;
      case 'ignitium':
        return 50 + 50 * r.ignitiumDrones;
      default:
        return 999999; // Impossible
    }
  }

  void attemptBuyDrill(String drillType, BuildContext context) {
    const cost = 100; // Coût fixe pour les forreuses
    final r = resourceNotifier.value;
    if (r == null) return;

    switch (drillType.toLowerCase()) {
      case 'ferralyte':
        if (r.noctilium >= cost) {
          r.noctilium -= cost;
          r.ferralyteDrills++;
          _showMessage(context, "Forreuse de Ferralyte achetée !");
          dbService.saveData(r);
          startFerralyteDrillAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Noctilium !");
        }
        break;

      case 'crimsite':
        if (r.verdanite >= cost) {
          r.verdanite -= cost;
          r.crimsiteDrills++;
          _showMessage(context, "Forreuse de Crimsite achetée !");
          dbService.saveData(r);
          startCrimsiteDrillAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Verdanite !");
        }
        break;

      case 'amarenthite':
        if (r.ignitium >= cost) {
          r.ignitium -= cost;
          r.amarenthiteDrills++;
          _showMessage(context, "Forreuse d'Amarenthite achetée !");
          dbService.saveData(r);
          startAmarenthiteDrillAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez d'Ignitium !");
        }
        break;

      default:
        _showMessage(context, "Type de forreuse inconnu !");
    }
  }

  /// Achat d'un drone, type: 'noctilium', 'verdanite', 'ignitium'
  void attemptBuyDrone(String droneType, BuildContext context) {
    final r = resourceNotifier.value;
    if (r == null) return;

    int cost = getCurrentDronePrice(droneType, r);

    switch (droneType.toLowerCase()) {
      case 'noctilium':
        if (r.noctilium >= cost) {
          r.noctilium -= cost;
          r.noctiliumDrones++;
          _showMessage(context, "Drone de Noctilium acheté pour $cost !");
          dbService.saveData(r);
          startNoctiliumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Noctilium pour acheter ce drone (coût: $cost).");
        }
        break;
      case 'verdanite':
        if (r.verdanite >= cost) {
          r.verdanite -= cost;
          r.verdaniteDrones++;
          _showMessage(context, "Drone de Verdanite acheté pour $cost !");
          dbService.saveData(r);
          startVerdaniteAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez de Verdanite pour acheter ce drone (coût: $cost).");
        }
        break;
      case 'ignitium':
        if (r.ignitium >= cost) {
          r.ignitium -= cost;
          r.ignitiumDrones++;
          _showMessage(context, "Drone d'Ignitium acheté pour $cost !");
          dbService.saveData(r);
          startIgnitiumAutoCollect(() {});
          resourceNotifier.notifyListeners();
        } else {
          _showMessage(context, "Pas assez d'Ignitium pour acheter ce drone (coût: $cost).");
        }
        break;
      default:
        _showMessage(context, "Type de drone inconnu.");
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
      history.add('- drone (noctilium, verdanite, ignitium)');
      history.add('- drill (ferralyte, amarenthite, crimsite)');
      history.add('Utilisez /buy <itemtype> <objet> [quantité]');
      resourceNotifier.notifyListeners();
      return;
    }

    // /buy [objet] [quantité]
    if (lower.startsWith('/buy')) {
      final parts = trimmedInput.split(RegExp(r'\s+'));
      if (parts.length == 3) {
        final type = parts[1].toLowerCase();
        final resource = parts[2].toLowerCase();

        if (type == 'drone' && ['noctilium', 'verdanite', 'ignitium'].contains(resource)) {
          history.add('Commande exécutée : $input');
          attemptBuyDrone(resource, context);
        } else if (type == 'drill' && ['crimsite', 'amarenthite', 'ferralyte'].contains(resource)) {
          history.add('Commande exécutée : $input');
          attemptBuyDrill(resource, context);
        } else {
          history.add('Commande incorrecte : $input');
          _showMessage(context, "Commande /buy invalide. Usage : /buy <drone|drill> <minerai>");
        }
      } else {
        history.add('Commande incorrecte : $input');
        _showMessage(context, "Commande /buy invalide. Usage : /buy <drone|drill> <minerai>");
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

    // /steal <ResourceType> <quantité>
    if (lower.startsWith('/steal')) {
      final parts = trimmedInput.split(RegExp(r'\s+'));
      if (parts.length == 3) {
        final type = parts[1].toLowerCase();
        final qty = int.tryParse(parts[2]);
        final r = resourceNotifier.value;
        if (qty != null && qty > 0 && r != null) {
          bool ok = false;
          switch (type) {
            case 'noctilium':
              r.noctilium += qty;
              ok = true;
              break;
            case 'verdanite':
              r.verdanite += qty;
              ok = true;
              break;
            case 'ignitium':
              r.ignitium += qty;
              ok = true;
              break;
            case 'ferralyte':
              r.ferralyte += qty;
              ok = true;
              break;
            case 'amarenthite':
              r.amarenthite += qty;
              ok = true;
              break;
            case 'crimsite':
              r.crimsite += qty;
              ok = true;
              break;
            default:
            // ressource inconnue
              break;
          }
          if (ok) {
            dbService.saveData(r);
            resourceNotifier.notifyListeners();
            history.add("Vous avez volé $qty $type !");
          } else {
            history.add("Type de ressource inconnu : $type");
          }
        } else {
          history.add("Usage: /steal <ResourceType> <quantité> (ex: /steal noctilium 400)");
        }
      } else {
        history.add("Usage: /steal <ResourceType> <quantité> (ex: /steal noctilium 400)");
      }
      resourceNotifier.notifyListeners();
      return;
    }

    history.add('Commande inconnue : $input');
    resourceNotifier.notifyListeners();
  }

  List<String> getHistory() => List.unmodifiable(history);
}