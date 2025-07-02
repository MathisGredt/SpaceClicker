import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Ajoute ces imports pour sqflite_common_ffi
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Cette ligne est CRUCIALE pour Windows/Linux/macOS
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exploration Spatiale Clicker',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}