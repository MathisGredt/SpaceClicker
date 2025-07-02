import 'package:flutter/material.dart';

class ResourceDisplay extends StatelessWidget {
  final int energy;
  final int drones;

  const ResourceDisplay({
    Key? key,
    required this.energy,
    required this.drones,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Énergie : $energy", style: TextStyle(fontSize: 24)),
        SizedBox(height: 10),
        Text("Drones miniers (auto collect) : $drones"),
      ],
    );
  }
}