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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
    Future.delayed(Duration(milliseconds: 500), () {
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
          history.add("Drones ont collecté $collected noctilium");
        });
        dbService.saveData(resource!);
      }
    });
  }

  void _collectNoctilium(TapDownDetails details) {
    if (resource == null) return;

    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      isClicked = true;
    });

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isClicked = false;
      });
    });

    setState(() {
      resource!.noctilium++;
      resource!.totalCollected++;

      fallingWidgets.add(_createFallingWidget(
        "+1",
        'assets/images/noctilium.png',
        localPosition,
      ));
    });

    dbService.saveData(resource!);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (fallingWidgets.isNotEmpty) {
          fallingWidgets.removeAt(0);
        }
      });
    });
  }

  void _buyDrone() {
    const cost = 50;
    if (resource != null && resource!.noctilium >= cost) {
      setState(() {
        resource!.noctilium -= cost;
        resource!.drones++;
        history.add("Drone acheté !");
      });
      dbService.saveData(resource!);
    } else {
      _showMessage("Pas assez de Noctilium pour acheter un drone");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
            top: MediaQuery.of(context).size.height / 2 - 150 + 150, // Adjusted position
            child: IconButton(
              icon: Icon(Icons.arrow_forward, size: 40, color: Colors.white),
              onPressed: _navigateToSecondPlanet,
            ),
          ),
          DroneUpgrade(
            noctilium: resource?.noctilium ?? 0,
            onBuyDrone: _buyDrone,
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
}