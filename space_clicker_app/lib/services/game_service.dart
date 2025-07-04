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
  Timer? ferralyteDrillTimer;
  Timer? crimsiteDrillTimer;
  Timer? amarenthiteDrillTimer;

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

  void stopAllDrillAutoCollect() {
    ferralyteDrillTimer?.cancel();
    crimsiteDrillTimer?.cancel();
    amarenthiteDrillTimer?.cancel();
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

  void startFerralyteDrillAutoCollect(VoidCallback onUpdate) {
    ferralyteDrillTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final resource = resourceNotifier.value;
      if (resource != null) {
        resource.ferralyte += resource.ferralyteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners(); // Notifie les changements
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

  void startCrimsiteDrillAutoCollect(VoidCallback onUpdate) {
    crimsiteDrillTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final resource = resourceNotifier.value;
      if (resource != null) {
        resource.crimsite += resource.crimsiteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners(); // Notifie les changements
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

  void startAmarenthiteDrillAutoCollect(VoidCallback onUpdate) {
    amarenthiteDrillTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final resource = resourceNotifier.value;
      if (resource != null) {
        resource.amarenthite += resource.amarenthiteDrills;
        dbService.saveData(resource);
        resourceNotifier.notifyListeners(); // Notifie les changements
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

  void attemptBuyDrill(String drillType, BuildContext context) {
    const cost = 100;
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
    final trimmedInput = input.trim();
    if (trimmedInput.startsWith('/buy')) {
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