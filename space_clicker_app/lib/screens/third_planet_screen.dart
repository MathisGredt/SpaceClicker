import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../services/video_service.dart';
import '../widgets/resource_display.dart';
import '../services/game_service.dart';
import '../widgets/retro_terminal_left.dart';
import '../widgets/retro_terminal_right.dart';
import '../models/resource_model.dart';
import 'second_planet_screen.dart';
import '../services/audio_service.dart';

class ThirdPlanetScreen extends StatefulWidget {
  @override
  _ThirdPlanetScreenState createState() => _ThirdPlanetScreenState();
}

class _ThirdPlanetScreenState extends State<ThirdPlanetScreen> with TickerProviderStateMixin {
  late VideoService videoService;
  // Utilisation du singleton GameService
  final GameService gameService = GameService.instance;

  bool isClicked = false;
  bool isFading = false;
  bool fadeOut = true;
  late DatabaseService dbService;
  late BonusService bonusService;
  List<String> history = [];
  List<Widget> fallingWidgets = [];

  @override
  void initState() {
    super.initState();
    videoService = VideoService();
    dbService = DatabaseService();
    bonusService = BonusService();
    _initAndLoad();

    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() => fadeOut = false);
    });
  }

  Future<void> _initAndLoad() async {
    // Pas besoin de recharger ou init GameService ici, il est singleton et déjà lancé
    await dbService.initDb();
    await dbService.loadData();
    if (mounted) setState(() {});
  }

  void _collectIgnitium(TapDownDetails details) {
    final resource = gameService.resourceNotifier.value;
    if (resource == null) return;

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      isClicked = true;
      gameService.collectIgnitium();

      fallingWidgets.add(_createFallingWidget(
        "+1",
        'assets/images/ignitium.png',
        localPosition,
      ));
    });

    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) setState(() => isClicked = false);
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() {
        if (fallingWidgets.isNotEmpty) {
          fallingWidgets.removeAt(0);
        }
      });
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

  Widget _createFallingWidget(String text, String iconPath, Offset position) {
    final controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    final verticalAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -60.0).chain(CurveTween(curve: Curves.easeOut)), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: -60.0, end: 100.0).chain(CurveTween(curve: Curves.easeIn)), weight: 0.7),
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
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Nebulys",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: ValueListenableBuilder<Resource?>(
              valueListenable: gameService.resourceNotifier,
              builder: (context, resource, child) => RetroTerminalLeft(resource: resource),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: RetroTerminalRight(
              history: history,
              onCommand: (cmd) {
                setState(() {
                  gameService.handleCommand(cmd, context);
                });
              },
            ),
          ),

          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTapDown: _collectIgnitium,
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
          ...fallingWidgets,
        ],
      ),
    );
  }
}