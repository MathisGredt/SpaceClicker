import 'package:flutter/material.dart';

class DroneUpgrade extends StatelessWidget {
  final int noctilium;
  final Function onBuyDrone;

  const DroneUpgrade({
    Key? key,
    required this.noctilium,
    required this.onBuyDrone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: noctilium >= 50 ? () => onBuyDrone() : null,
      child: Text("Acheter un drone (50 Noctilium)"),
    );
  }
}