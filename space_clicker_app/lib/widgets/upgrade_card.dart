import 'package:flutter/material.dart';

class UpgradeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final int price;
  final VoidCallback onBuy;

  const UpgradeCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.onBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 120, height: 120), // Taille augmentée
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Text("Prix : $price Noctilium", style: TextStyle(color: Colors.green)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onBuy,
              child: Text("Acheter"),
            ),
          ],
        ),
      ),
    );
  }
}