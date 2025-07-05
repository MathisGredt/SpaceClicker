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
      onApply: () {
        GameService.instance.upgradeService.reduceDrillInterval('amarenthite');
        GameService.instance.startAmarenthiteDrillAutoCollect(() {});
      },
    ),
  ];

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
              trailing: Text(
                "${upgrade.cost} ${index == 0 ? 'Noctilium' : index == 1 ? 'Verdanite' : index == 2 ? 'Ignitium' : 'Ressources'}",
                style: TextStyle(color: Colors.green),
              ),
              onTap: () {
                final resource = GameService.instance.resourceNotifier.value;
                if (resource != null) {
                  if (index == 0 && resource.noctilium >= upgrade.cost) {
                    resource.noctilium -= upgrade.cost;
                    upgrade.onApply();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Amélioration achetée : ${upgrade.title}")),
                    );
                  } else if (index == 1 && resource.verdanite >= upgrade.cost) {
                    resource.verdanite -= upgrade.cost;
                    upgrade.onApply();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Amélioration achetée : ${upgrade.title}")),
                    );
                  } else if (index == 2 && resource.ignitium >= upgrade.cost) {
                    resource.ignitium -= upgrade.cost;
                    upgrade.onApply();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Amélioration achetée : ${upgrade.title}")),
                    );
                  } else if (index >= 3 && resource.noctilium >= upgrade.cost) {
                    resource.noctilium -= upgrade.cost;
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
}