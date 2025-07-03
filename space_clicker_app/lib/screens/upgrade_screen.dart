import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/resource_model.dart';

class UpgradeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Améliorations"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildUpgradeItem(
            context,
            "Amélioration des drones",
            "Augmente la vitesse de collecte des drones.",
            'assets/images/drone_upgrade.png',
            100,
          ),
          _buildUpgradeItem(
            context,
            "Bonus de collecte",
            "Multiplie les ressources collectées par un facteur.",
            'assets/images/bonus_upgrade.png',
            200,
          ),
          _buildUpgradeItem(
            context,
            "Capacité de stockage",
            "Augmente la capacité maximale de stockage des ressources.",
            'assets/images/storage_upgrade.png',
            300,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeItem(
      BuildContext context,
      String title,
      String description,
      String imagePath,
      int cost,
      ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset(imagePath, width: 64, height: 64), // Taille augmentée
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Text("$cost Noctilium", style: TextStyle(color: Colors.green)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Amélioration achetée : $title")),
          );
        },
      ),
    );
  }
}