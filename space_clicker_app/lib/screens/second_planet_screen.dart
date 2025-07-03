import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/video_service.dart';
import '../services/game_service.dart';
import '../widgets/drone_upgrade.dart';
import '../widgets/retro_terminal_left.dart';
import '../widgets/retro_terminal_right.dart';
import '../models/resource_model.dart';
import 'home_screen.dart';
import 'third_planet_screen.dart';

class SecondPlanetScreen extends StatefulWidget {
  @override
  _SecondPlanetScreenState createState() => _SecondPlanetScreenState();
}

class _SecondPlanetScreenState extends State<SecondPlanetScreen> with TickerProviderStateMixin {
  late VideoService videoService;

  // Singleton GameService utilisé ici
  final GameService gameService = GameService.instance;

  bool isClicked = false;
  List<Widget> fallingWidgets = [];

  Resource? get resource => gameService.resource;
  List<String> get history => gameService.getHistory();

  @override
  void initState() {
    super.initState();
    videoService = VideoService();

    gameService.init().then((_) {
      // Démarre la collecte automatique avec callback setState
      gameService.startAutoCollect(() {
        if (mounted) setState(() {});
      });
      setState(() {});
    });
  }

  void _collectNoctilium(TapDownDetails details) {
    if (resource == null) return;

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      isClicked = true;
      gameService.collectNoctilium();

      fallingWidgets.add(_createFallingWidget(
        "+1",
        'assets/images/noctilium.png',
        localPosition,
      ));
    });

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isClicked = false;
      });
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (fallingWidgets.isNotEmpty) fallingWidgets.removeAt(0);
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
                onTapDown: _collectNoctilium,
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
            top: MediaQuery.of(context).size.height / 2,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 40, color: Colors.white),
              onPressed: () {
                videoService.disposeVideo();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
          ),

          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
              onPressed: () {
                videoService.disposeVideo();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPlanetScreen()),
                );
              },
            ),
          ),

          DroneUpgrade(
            noctilium: resource?.noctilium ?? 0,
            onBuyDrone: _attemptBuyDrone,
          ),

          ...fallingWidgets,
        ],
      ),
    );
  }
}
