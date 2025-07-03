import 'package:flutter/material.dart';

class ResourceDisplay extends StatelessWidget {
  final int drones;
  final int noctilium;
  final int ferralyte;
  final int verdanite;
  final int ignitium;

  const ResourceDisplay({
    Key? key,
    required this.drones,
    required this.noctilium,
    required this.ferralyte,
    required this.verdanite,
    required this.ignitium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/noctilium.png',
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 8),
                Text("Noctilium: $noctilium", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Image.asset(
                  'assets/images/ferralyte.png',
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 8),
                Text("Ferralyte: $ferralyte", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Image.asset(
                  'assets/images/verdanite.png',
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 8),
                Text("Verdanite: $verdanite", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Image.asset(
                  'assets/images/ignitium.png',
                  width: 32,
                  height: 32,
                ),
                SizedBox(width: 8),
                Text("Ignitium: $ignitium", style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            Text("Drones: $drones", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}