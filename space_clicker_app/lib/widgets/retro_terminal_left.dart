import 'package:flutter/material.dart';
import '../models/resource_model.dart';

class RetroTerminalLeft extends StatelessWidget {
  final Resource? resource;

  const RetroTerminalLeft({Key? key, required this.resource}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.greenAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "=== RESSOURCES ===",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          SizedBox(height: 10),
          _resourceRow("Noctilium", resource?.noctilium ?? 0),
          _resourceRow("Verdanite", resource?.verdanite ?? 0),
          _resourceRow("Ignitium", resource?.ignitium ?? 0),
          _resourceRow("Ferralyte", resource?.ferralyte ?? 0),
          _resourceRow("Amarenthite", resource?.amarenthite ?? 0),
          _resourceRow("Crimsite", resource?.crimsite ?? 0),
          SizedBox(height: 16),
          Text(
            "=== DRONES ===",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          SizedBox(height: 8),
          _droneRow("Noctilium", resource?.noctiliumDrones ?? 0),
          _droneRow("Verdanite", resource?.verdaniteDrones ?? 0),
          _droneRow("Ignitium", resource?.ignitiumDrones ?? 0),
          SizedBox(height: 20),
          Text(
            "=== DRILLS ===",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          SizedBox(height: 8),
          _drillRow("Ferralyte Drills", resource?.ferralyteDrills ?? 0),
          _drillRow("Amarenthite Drills", resource?.amarenthiteDrills ?? 0),
          _drillRow("Crimsite Drills", resource?.crimsiteDrills ?? 0),

        ],
      ),
    );
  }

  Widget _resourceRow(String name, int value) {
    return Text(
      "$name: $value",
      style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
    );
  }

  Widget _droneRow(String name, int drones) {
    return Text(
      "$name drones: $drones",
      style: TextStyle(color: Colors.yellowAccent, fontFamily: 'Courier', fontSize: 13),
    );
  }

  Widget _drillRow(String name, int drills) {
    return Text(
      "$name: $drills",
      style: TextStyle(color: Colors.yellowAccent, fontFamily: 'Courier', fontSize: 13),
    );
  }
}