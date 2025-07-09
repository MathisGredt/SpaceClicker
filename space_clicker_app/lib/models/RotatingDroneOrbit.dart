import 'dart:math';
import 'package:flutter/material.dart';

class RotatingDroneOrbit extends StatefulWidget {
  final double orbitRadiusX; // Rayon horizontal
  final double orbitRadiusY; // Rayon vertical
  final String assetPath;
  final double angleOffset; // Décalage angulaire

  const RotatingDroneOrbit({
    Key? key,
    required this.orbitRadiusX,
    required this.orbitRadiusY,
    required this.assetPath,
    required this.angleOffset, // Ajout du décalage angulaire
  }) : super(key: key);

  @override
  _RotatingDroneOrbitState createState() => _RotatingDroneOrbitState();
}

class _RotatingDroneOrbitState extends State<RotatingDroneOrbit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15), // Durée de rotation
      vsync: this,
    )..repeat(); // Répète l'animation indéfiniment
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Angle en radians (0 à 2π) avec décalage angulaire
        final angle = 2 * pi * _controller.value + widget.angleOffset;

        // Calcul de l'ellipse
        final x = widget.orbitRadiusX * cos(angle);
        final y = widget.orbitRadiusY * sin(angle);

        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x - 32, // Ajustement pour la taille
          top: MediaQuery.of(context).size.height / 2 + y - 32, // Ajustement pour la taille
          child: Image.asset(
            widget.assetPath,
            width: 64, // Taille augmentée
            height: 64, // Taille augmentée
          ),
        );
      },
    );
  }
}