import 'package:flutter/material.dart';
import '../models/resource_model.dart';

class RetroTerminalLeft extends StatelessWidget {
  final Resource? resource;

  const RetroTerminalLeft({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.greenAccent),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'Courier',
          fontSize: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("=== TERMINAL RESSOURCES ===\n"),
            Text("Noctilium : ${resource?.noctilium ?? 0}"),
            Text("Ferralyte : ${resource?.ferralyte ?? 0}"),
            Text("Drones    : ${resource?.drones ?? 0}"),
            const SizedBox(height: 20),
            Text("Bonus x${resource != null ? resource!.bonus.toStringAsFixed(2) : '1.00'}"),
          ],
        ),
      ),
    );
  }
}
