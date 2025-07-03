import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../services/video_service.dart';
import '../services/game_service.dart';
import '../widgets/drone_upgrade.dart';
import '../widgets/retro_terminal_left.dart';
import '../widgets/retro_terminal_right.dart';
import '../models/resource_model.dart';
import 'home_screen.dart';
import 'third_planet_screen.dart';
import '../services/audio_service.dart';

class SecondPlanetScreen extends StatefulWidget {
  @override
  _SecondPlanetScreenState createState() => _SecondPlanetScreenState();
}

class _SecondPlanetScreenState extends State<SecondPlanetScreen> with TickerProviderStateMixin {
  late VideoService videoService;

  // Singleton GameService utilisé ici
  final GameService gameService = GameService.instance;

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

    gameService.init().then((_) {
      gameService.startAutoCollect(() {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {}); // To display loaded resources
    });
  }

  void _startAutoCollect() {
    autoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource != null && resource!.drones > 0) {
        final collected = (resource!.drones * 2 * bonusService.bonusMultiplier).round();
        setState(() {
          resource!.noctilium += collected;
          resource!.totalCollected += collected;
          history.add("Drones ont collecté $collected noctilium sur la planète 2");
        });
        dbService.saveData(resource!);
      }
    });
  }

  void _navigateToHomeScreen() {
    setState(() {
      isFading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      videoService.disposeVideo();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ).then((_) {
        setState(() {
          isFading = false;
        });
      });
    });
  }

  void _navigateToThirdPlanet() {
    setState(() {
      isFading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      videoService.disposeVideo();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ThirdPlanetScreen()),
      ).then((_) {
        setState(() {
          isFading = false;
        });
      });
    });
  }

  void _attemptBuyDrone() {
    final success = gameService.buyDrone();
    if (!success) {
      _showMessage("Pas assez de Noctilium pour acheter un drone sur la planète 2");
    }
    setState(() {});
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _handleCommand(String cmd) {
    setState(() {
      gameService.handleCommand(cmd);
    });
  }

  Widget _createFallingWidget(String text, String iconPath, Offset position) {
    final controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    final verticalAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -60.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 0.3),
      TweenSequenceItem(
          tween: Tween(begin: -60.0, end: 100.0).chain(CurveTween(curve: Curves.easeIn)),
          weight: 0.7),
    ]).animate(curve);

    final horizontalOffset = Random().nextBool() ? 30.0 : -30.0;
    final horizontalAnimation = Tween<double>(begin: 0, end: horizontalOffset).animate(curve);
    final opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(curve);

    controller.forward();

    final widget = AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          top: position.dy + verticalAnimation.value,
          left: position.dx + horizontalAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        setState(() {
          fallingWidgets.remove(widget);
        });
      }
    });

    return widget;
  }

  @override
  void dispose() {
    // Ne pas disposer gameService ici pour garder son état et timers actifs
    videoService.disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundVideo(assetPath: 'assets/videos/background.mp4'),

          Positioned(
            top: 40,
            left: 20,
            child: RetroTerminalLeft(resource: resource),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: RetroTerminalRight(
              history: history,
              onCommand: _handleCommand,
            ),
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
                    'assets/images/second_planet.png',
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
              onPressed: _navigateToHomeScreen,
            ),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 150 + 150,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
              onPressed: _navigateToThirdPlanet,
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
          ...fallingWidgets,
        ],
      ),
    );
  }
}