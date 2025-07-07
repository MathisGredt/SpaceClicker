import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/end_background.png',
            fit: BoxFit.cover,
          ),
          // Semi-transparent overlay for better text readability (optional)
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Centered terminal style message
          Center(
            child: Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 64),
                  SizedBox(height: 24),
                  Text(
                    ">> FÉLICITATIONS <<\n\n"
"Le réacteur temporel est activé.\n"
"Le temps est stabilisé.\n"
"Merci pour votre aide, mission accomplie.",

                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.greenAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 6,
                          color: Colors.green.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}