import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/drone_upgrade.dart';
import '../models/resource_model.dart';

// Rest of your code remains unchanged

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseService dbService;
  late BonusService bonusService;
  Resource resource = Resource(energy: 0, drones: 0, totalCollected: 0);
  List<String> history = [];
  Timer? autoCollectTimer;

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService();
    bonusService = BonusService();
    dbService.initDb().then((_) {
      dbService.loadData().then((data) {
        if (data != null) {
          setState(() {
            resource = data;
          });
        }
        _startAutoCollect();
      });
    });
  }

  void _startAutoCollect() {
    autoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource.drones > 0) {
        final collected = (resource.drones * 2 * bonusService.bonusMultiplier).round();
        setState(() {
          resource.energy += collected;
          resource.totalCollected += collected;
          history.add("Drones ont collecté $collected énergie");
        });
        print("Energy: ${resource.energy}"); // Debug log
        dbService.saveData(resource);
      }
    });
  }

  void _collectEnergy() {
    final collected = (1 * bonusService.bonusMultiplier).round();
    setState(() {
      resource.energy += collected;
      resource.totalCollected += collected;
      history.add("Clique +$collected énergie");
    });
    dbService.saveData(resource);
  }

  void _buyDrone() {
    const cost = 50;
    if (resource.energy >= cost) {
      setState(() {
        resource.energy -= cost;
        resource.drones++;
        history.add("Drone acheté !");
      });
      dbService.saveData(resource);
    } else {
      _showMessage("Pas assez d'énergie pour acheter un drone");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _activateBonus() {
    bonusService.activateBonus(() {
      setState(() {
        history.add("Bonus terminé");
      });
    });
    setState(() {
      history.add("Bonus x2 activé pour 10s !");
    });
  }

  @override
  void dispose() {
    autoCollectTimer?.cancel();
    bonusService.dispose();
    dbService.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exploration Spatiale Clicker"),
        actions: [
          IconButton(
            icon: Icon(Icons.bolt),
            tooltip: "Activer bonus x2 (temporaire)",
            onPressed: _activateBonus,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ResourceDisplay(energy: resource.energy, drones: resource.drones),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _collectEnergy,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Cliquer sur la planète", style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            DroneUpgrade(energy: resource.energy, onBuyDrone: _buyDrone),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12)),
                child: ListView(
                  children: history.reversed
                      .map((e) => Text(
                    e,
                    style: TextStyle(color: Colors.white70),
                  ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}