import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../services/video_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/drone_upgrade.dart';
import '../models/resource_model.dart';
import 'second_planet_screen.dart';
import '../services/audio_service.dart';

class ThirdPlanetScreen extends StatefulWidget {
  @override
  _ThirdPlanetScreenState createState() => _ThirdPlanetScreenState();
}

class _ThirdPlanetScreenState extends State<ThirdPlanetScreen> with TickerProviderStateMixin {
  late VideoService videoService;
  bool isClicked = false;
  bool isFading = false;
  bool fadeOut = true; // New state for fade-out
  late DatabaseService dbService;
  late BonusService bonusService;
  Resource? resource;
  List<String> history = [];
  Timer? autoCollectTimer;
  List<Widget> fallingWidgets = [];

  @override
  void initState() {
    super.initState();
    videoService = VideoService();
    dbService = DatabaseService();
    bonusService = BonusService();
    _initAndLoad();

    // Trigger fade-out animation on screen load
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        fadeOut = false;
      });
    });
  }

  Future<void> _initAndLoad() async {
    await dbService.initDb();
    final loaded = await dbService.loadData();
    setState(() {
      resource = loaded;
    });
    _startAutoCollect();
  }

  void _startAutoCollect() {
    autoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.drones > 0) {
        final collected = (resource!.drones * 2 * bonusService.bonusMultiplier).round();
        setState(() {
          resource!.noctilium += collected;
          resource!.totalCollected += collected;
          history.add("Drones ont collecté $collected noctilium sur la planète 3");
        });
        dbService.saveData(resource!);
      }
    });
  }

  void _navigateToSecondPlanet() {
    setState(() {
      isFading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      videoService.disposeVideo();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SecondPlanetScreen()),
      ).then((_) {
        setState(() {
          isFading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    autoCollectTimer?.cancel();
    bonusService.dispose();
    if (resource != null) {
      dbService.saveData(resource!);
    }
    dbService.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundVideo(assetPath: 'assets/videos/background.mp4'),
          ResourceDisplay(
            drones: resource?.drones ?? 0,
            noctilium: resource?.noctilium ?? 0,
            ferralyte: resource?.ferralyte ?? 0,
          ),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: (details) {},
                child: AnimatedScale(
                  scale: isClicked ? 1.2 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/images/third_planet.png',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 150 + 150,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 40, color: Colors.white),
              onPressed: _navigateToSecondPlanet,
            ),
          ),
          IgnorePointer(
            ignoring: !isFading && !fadeOut,
            child: AnimatedOpacity(
              opacity: isFading ? 1.0 : (fadeOut ? 1.0 : 0.0),
              duration: Duration(seconds: 1),
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}