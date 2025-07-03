import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../services/video_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/drone_upgrade.dart';
import '../widgets/retro_terminal_left.dart';
import '../widgets/retro_terminal_right.dart';
import '../models/resource_model.dart';
import 'second_planet_screen.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late VideoService videoService;

  // Utilisation du singleton
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

  Resource? get resource => gameService.resource;
  List<String> get history => gameService.getHistory();

  @override
  void initState() {
    super.initState();
    videoService = VideoService();
    dbService = DatabaseService();
    bonusService = BonusService();
    _initAndLoad();

    // Trigger fade-out animation on screen load
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        fadeOut = false;
      });
    });
  }

    // Init idempotente dans GameService
    gameService.init().then((_) {
      gameService.startAutoCollect(() {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {}); // Pour afficher les ressources chargées
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
        if (fallingWidgets.isNotEmpty) {
          fallingWidgets.removeAt(0);
        }
      });
    });
  }

  void _attemptBuyDrone() {
    final success = gameService.buyDrone();
    if (!success) {
      _showMessage("Pas assez de Noctilium pour acheter un drone");
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

  void _navigateToSecondPlanet() {
    setState(() {
      isFading = true;
    });

    Future.delayed(Duration(seconds: 1), () { // Increased delay to 1 second
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
    // Ne pas disposer gameService pour garder timer actif
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
                    'assets/images/first_planet.png',
                    width: 300,
                    height: 300,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
              onPressed: _navigateToSecondPlanet,
            ),
          ),

          DroneUpgrade(
            noctilium: resource?.noctilium ?? 0,
            onBuyDrone: _attemptBuyDrone,
          ),

          ...fallingWidgets,
          IgnorePointer(
            ignoring: !isFading && !fadeOut, // Adjusted to handle both fade states
            child: AnimatedOpacity(
              opacity: isFading ? 1.0 : (fadeOut ? 1.0 : 0.0), // Handles fade-in and fade-out
              duration: Duration(seconds: 1), // Increased duration to 1 second
              child: Container(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
