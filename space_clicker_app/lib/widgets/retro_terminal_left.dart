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
          Text(
            "Noctilium: ${resource?.noctilium ?? 0}",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          Text(
            "Ferralyte: ${resource?.ferralyte ?? 0}",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          Text(
            "Verdanite: ${resource?.verdanite ?? 0}",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          Text(
            "Ignitium: ${resource?.ignitium ?? 0}",
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          Text(
            "Amarenthite: ${resource?.amarenthite ?? 0}", // ✅ Ajout Amarenthite
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
          Text(
            "Crimsite: ${resource?.crimsite ?? 0}",       // ✅ Ajout Crimsite
            style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier'),
          ),
        ],
      ),
    );
  }
}
