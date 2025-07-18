import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/background_video.dart';
import '../services/database_service.dart';
import '../services/upgrade_service.dart';
import '../services/video_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/retro_terminal_left.dart';
import '../widgets/retro_terminal_right.dart';
import '../models/resource_model.dart';
import 'second_planet_screen.dart';
import '../services/audio_service.dart';
import '../services/game_service.dart';
import '../models/RotatingDroneOrbit.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late VideoService videoService;

  // Utilisation du singleton
  final GameService gameService = GameService.instance;

  List<Map<String, dynamic>> drones = [];

  bool isClicked = false;
  bool isFading = false;
  bool fadeOut = true;
  late DatabaseService dbService;
  late UpgradeService upgradeService;
  List<String> history = [];
  Timer? autoCollectTimer;
  List<Widget> fallingWidgets = [];

  @override
  void initState() {
    super.initState();
    videoService = VideoService();
    dbService = DatabaseService();
    upgradeService = UpgradeService();
    _initAndLoad();

    // Fade-out animation au chargement
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        fadeOut = false;
      });
    });
  }

  Future<void> _initAndLoad() async {
    await dbService.initDb();
    await dbService.insertInitialResourceIfNeeded(); // Ensure initial data is inserted
    await dbService.loadData();

    await gameService.init();
    gameService.collectAllResources();
    // Démarrer l’auto-collect pour chaque ressource
    gameService.startNoctiliumAutoCollect(() => setState(() {}));
    gameService.startVerdaniteAutoCollect(() => setState(() {}));
    gameService.startIgnitiumAutoCollect(() => setState(() {}));
    gameService.startFerralyteDrillAutoCollect(() => setState(() {}));
    gameService.startCrimsiteDrillAutoCollect(() => setState(() {}));
    gameService.startAmarenthiteDrillAutoCollect(() => setState(() {}));

    if (mounted) setState(() {});
  }

  void _collectNoctilium(TapDownDetails details) {
  final resource = gameService.resourceNotifier.value;
  if (resource == null) return;

  RenderBox box = context.findRenderObject() as RenderBox;
  Offset localPosition = box.globalToLocal(details.globalPosition);

  setState(() {
    isClicked = true;
    gameService.collectNoctilium();

    // Jouer le son au clic
    AudioService().playClickSound('assets/sounds/break.mp3');

    // Affichage entier si tu veux : "+${resource.noctiliumClickMult.round()}"
    fallingWidgets.add(_createFallingWidget(
      "+${resource.noctiliumClickMult}", // ou .toStringAsFixed(0) pour enlever les décimales
      'assets/images/noctilium.png',
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
    const requiredNoctilium = 500;
    final resource = gameService.resourceNotifier.value;

    if (resource != null) {
      if (!resource.hasPaidSecondPlanet) {
        if (resource.noctilium >= requiredNoctilium) {
          resource.noctilium -= requiredNoctilium;
          resource.hasPaidSecondPlanet = true;
          dbService.saveData(resource);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Vous avez besoin de $requiredNoctilium Noctilium pour accéder à la prochaine planète.")),
          );
          return;
        }
      }

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
      child: IgnorePointer(
      ignoring: true, // <--- empêche l'icône de bloquer les clics !
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
    final resource = gameService.resourceNotifier.value;

    // Liste des drones en orbite
    List<Widget> droneOrbits = [];
    if (resource != null) {
      for (int i = 0; i < resource.noctiliumDrones; i++) {
        final angleOffset = (2 * pi / resource.noctiliumDrones) * i; // Angle unique pour chaque drone
        droneOrbits.add(
          RotatingDroneOrbit(
            orbitRadiusX: 250,
            orbitRadiusY: 200,
            assetPath: 'assets/images/drone_noctilium.png',
            angleOffset: angleOffset,
          ),
        );
      }
    }

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
                "Theralis",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
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
              history: GameService.instance.history,
              onCommand: (cmd) {
                setState(() {
                  GameService.instance.handleCommand(cmd, context);
                });
              },
            ),
          ),

          ...droneOrbits,
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
            bottom: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
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