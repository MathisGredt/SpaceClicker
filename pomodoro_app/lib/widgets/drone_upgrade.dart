import 'package:flutter/material.dart';

class DroneUpgrade extends StatelessWidget {
  final int energy;
  final Function onBuyDrone;

  const DroneUpgrade({
    Key? key,
    required this.energy,
    required this.onBuyDrone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: energy >= 50 ? () => onBuyDrone() : null,
      child: Text("Acheter un drone (50 énergie)"),
    );
  }
}