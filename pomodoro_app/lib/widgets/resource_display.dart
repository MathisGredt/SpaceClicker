import 'package:flutter/material.dart';

class ResourceDisplay extends StatelessWidget {
  final int drones;
  final int noctilium;
  final int ferralyte;

  const ResourceDisplay({
    Key? key,
    required this.drones,
    required this.noctilium,
    required this.ferralyte,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/noctilium.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text("Noctilium : $noctilium", style: TextStyle(fontSize: 18)),
          ],
        ),
        Row(
          children: [
            Image.asset(
              'assets/images/ferralyte.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 8),
            Text("Ferralyte : $ferralyte", style: TextStyle(fontSize: 18)),
          ],
        ),
        Text("Drones : $drones", style: TextStyle(fontSize: 18)),
      ],
    );
  }
}