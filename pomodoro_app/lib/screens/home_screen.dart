import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/drone_upgrade.dart';
import '../models/resource_model.dart';
import 'second_planet_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isClicked = false;
  late DatabaseService dbService;
  late BonusService bonusService;
  Resource? resource;
  List<String> history = [];
  Timer? autoCollectTimer;
  List<Widget> fallingWidgets = [];
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService();
    bonusService = BonusService();
    _initAndLoad();
    _loadAndPlayVideo();
  }

  Future<void> _loadAndPlayVideo() async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final bytes = await rootBundle.load('assets/videos/background.mp4');
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/background_temp.mp4');
        await file.writeAsBytes(bytes.buffer.asUint8List());

        _videoController = VideoPlayerController.file(file);
      } else {
        _videoController = VideoPlayerController.asset('assets/videos/background.mp4');
      }

      await _videoController!.initialize();
      _videoController!
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      setState(() {});
      print("✅ Vidéo initialisée avec succès");
    } catch (error) {
      print("❌ Erreur de chargement vidéo : $error");
    }
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

  @override
  void dispose() {
    autoCollectTimer?.cancel();
    bonusService.dispose();
    if (resource != null) {
      dbService.saveData(resource!);
    }
    dbService.closeDb();
    _videoController?.dispose(); // Dispose the video controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_videoController?.value.isInitialized ?? false)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
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
              onPressed: () {
                _videoController?.dispose();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPlanetScreen()),
                );
              },
            ),
          ),
          DroneUpgrade(
            noctilium: resource?.noctilium ?? 0,
            onBuyDrone: _buyDrone,
          ),
          ...fallingWidgets,
        ],
      ),
    );
  }
}
