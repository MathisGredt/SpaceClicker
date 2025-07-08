import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/resource_model.dart';
import '../models/upgrade.dart';

class UpgradeScreen extends StatelessWidget {
  final List<Upgrade> upgrades = [
    Upgrade(
      title: "Amélioration Drone Noctilium",
      description: "Réduit le temps de collecte des drones Noctilium de 1 seconde.",
      imagePath: 'assets/images/drone_noctilium.png',
      cost: 400,
      costResource1: 'noctilium',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDroneInterval('noctilium');
        GameService.instance.startNoctiliumAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Drone Verdanite",
      description: "Réduit le temps de collecte des drones Verdanite de 1 seconde.",
      imagePath: 'assets/images/drone_verdanite.png',
      cost: 400,
      costResource1: 'verdanite',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDroneInterval('verdanite');
        GameService.instance.startVerdaniteAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Drone Ignitium",
      description: "Réduit le temps de collecte des drones Ignitium de 1 seconde.",
      imagePath: 'assets/images/drone_ignitium.png',
      cost: 400,
      costResource1: 'ignitium',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDroneInterval('ignitium');
        GameService.instance.startIgnitiumAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Drill Ferralyte",
      description: "Réduit le temps de collecte des drills Ferralyte de 1 seconde.",
      imagePath: 'assets/images/drill_ferralyte.png',
      cost: 600,
      costResource1: 'noctilium',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDrillInterval('ferralyte');
        GameService.instance.startFerralyteDrillAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Drill Crimsite",
      description: "Réduit le temps de collecte des drills Crimsite de 1 seconde.",
      imagePath: 'assets/images/drill_crimsite.png',
      cost: 600,
      costResource1: 'noctilium',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDrillInterval('crimsite');
        GameService.instance.startCrimsiteDrillAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Drill Amarenthite",
      description: "Réduit le temps de collecte des drills Amarenthite de 1 seconde.",
      imagePath: 'assets/images/drill_amarenthite.png',
      cost: 600,
      costResource1: 'noctilium',
      costResource2: null,
      cost2: 0,
      onApply: () {
        GameService.instance.upgradeService.reduceDrillInterval('amarenthite');
        GameService.instance.startAmarenthiteDrillAutoCollect(() {});
      },
    ),
    Upgrade(
      title: "Amélioration Click Noctilium",
      description: "Améliore le click pour récuperer plus de noctilium",
      imagePath: 'assets/images/noctilium.png',
      cost: 600, // Noctilium
      costResource1: 'noctilium',
      cost2: 400, // Verdanite
      costResource2: 'verdanite',
      onApply: () {
        GameService.instance.upgradeService.incrementNoctiliumMult();
      },
    ),
    Upgrade(
      title: "Amélioration Click Verdanite",
      description: "Améliore le click pour récuperer plus de verdanite",
      imagePath: 'assets/images/noctilium.png',
      cost: 600, // Verdanite
      costResource1: 'verdanite',
      cost2: 400, // Ignitium
      costResource2: 'ignitium',
      onApply: () {
        GameService.instance.upgradeService.incrementVerdaniteMult();
      },
    ),
    Upgrade(
      title: "Amélioration Click Ignitium",
      description: "Améliore le click pour récuperer plus de ignitium",
      imagePath: 'assets/images/noctilium.png',
      cost: 600, // Ignitium
      costResource1: 'ignitium',
      cost2: 400, // Amarenthite
      costResource2: 'amarenthite',
      onApply: () {
        GameService.instance.upgradeService.incrementIgnitiumMult();
      },
    ),
  ];

  String resourceLabel(String resource) {
    switch (resource) {
      case 'noctilium': return 'Noctilium';
      case 'verdanite': return 'Verdanite';
      case 'ignitium': return 'Ignitium';
      case 'amarenthite': return 'Amarenthite';
      default: return 'Ressources';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Améliorations"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: upgrades.length,
        itemBuilder: (context, index) {
          final upgrade = upgrades[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Image.asset(upgrade.imagePath, width: 64, height: 64),
              title: Text(upgrade.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(upgrade.description),
              trailing: upgrade.costResource2 != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${upgrade.cost} ${resourceLabel(upgrade.costResource1!)}",
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        Text(
                          "+ ${upgrade.cost2} ${resourceLabel(upgrade.costResource2!)}",
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    )
                  : Text(
                      "${upgrade.cost} ${resourceLabel(upgrade.costResource1!)}",
                      style: TextStyle(color: Colors.green),
                    ),
              onTap: () {
                final resource = GameService.instance.resourceNotifier.value;
                bool hasEnough1 = false;
                bool hasEnough2 = false;
                if (resource != null) {
                  // Vérification ressources principales
                  int value1 = getResourceValue(resource, upgrade.costResource1);
                  hasEnough1 = value1 >= upgrade.cost;
                  if (upgrade.costResource2 != null) {
                    int value2 = getResourceValue(resource, upgrade.costResource2);
                    hasEnough2 = value2 >= upgrade.cost2;
                  } else {
                    hasEnough2 = true;
                  }

                  if (hasEnough1 && hasEnough2) {
                    // Déduire les ressources
                    setResourceValue(resource, upgrade.costResource1, value1 - upgrade.cost);
                    if (upgrade.costResource2 != null) {
                      int value2 = getResourceValue(resource, upgrade.costResource2);
                      setResourceValue(resource, upgrade.costResource2, value2 - upgrade.cost2);
                    }
                    upgrade.onApply();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Amélioration achetée : ${upgrade.title}")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Pas assez de ressources pour cette amélioration.")),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  int getResourceValue(Resource resource, String? field) {
    switch (field) {
      case 'noctilium': return resource.noctilium;
      case 'verdanite': return resource.verdanite;
      case 'ignitium': return resource.ignitium;
      case 'amarenthite': return resource.amarenthite;
      default: return 0;
    }
  }

  void setResourceValue(Resource resource, String? field, int value) {
    switch (field) {
      case 'noctilium': resource.noctilium = value; break;
      case 'verdanite': resource.verdanite = value; break;
      case 'ignitium': resource.ignitium = value; break;
      case 'amarenthite': resource.amarenthite = value; break;
    }
  }
}