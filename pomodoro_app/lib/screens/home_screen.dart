import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/bonus_service.dart';
import '../widgets/resource_display.dart';
import '../widgets/drone_upgrade.dart';
import '../models/resource_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isClicked = false;
  late DatabaseService dbService;
  late BonusService bonusService;
  Resource resource = Resource(drones: 0, totalCollected: 0, noctilium: 0, ferralyte: 0);
  List<String> history = [];
  Timer? autoCollectTimer;
  List<Widget> fallingWidgets = [];

  @override
  void initState() {
    super.initState();
    dbService = DatabaseService();
    bonusService = BonusService();
    dbService.initDb().then((_) {
      dbService.loadData().then((data) {
        if (data != null) {
          setState(() {
            resource = data;
          });
        }
        _startAutoCollect();
      });
    });
  }

  void _startAutoCollect() {
    autoCollectTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (resource.drones > 0) {
        final collected = (resource.drones * 2 * bonusService.bonusMultiplier).round();
        setState(() {
          resource.noctilium += collected;
          resource.totalCollected += collected;
          history.add("Drones ont collecté $collected Noctilium");
        });
        dbService.saveData(resource);
      }
    });
  }

  void _collectNoctilium(TapDownDetails details) {
    // Convert global position to local position
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

    // Add falling text and icon from the converted position
    setState(() {
      resource.noctilium++;
      resource.totalCollected++;
      history.add("Clique +1 Noctilium");

      fallingWidgets.add(_createFallingWidget(
        "+1",
        'assets/images/noctilium.png',
        localPosition,
      ));
    });

    dbService.saveData(resource);

    // Remove falling widget after animation
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (fallingWidgets.isNotEmpty) {
          fallingWidgets.removeAt(0);
        }
      });
    });
  }


  void _buyDrone() {
    const cost = 50; // Cost of a drone
    if (resource.noctilium >= cost) {
      setState(() {
        resource.noctilium -= cost;
        resource.drones++;
        history.add("Drone acheté !");
      });
      dbService.saveData(resource);
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
      vsync: this, // <-- Important : _HomeScreenState doit étendre TickerProviderStateMixin
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

    // Supprimer le widget après l'animation
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
    dbService.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ResourceDisplay(
            drones: resource.drones,
            noctilium: resource.noctilium,
            ferralyte: resource.ferralyte,
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTapDown: _collectNoctilium, // Capture tap position
                      child: AnimatedScale(
                        scale: isClicked ? 1.2 : 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/images/first_planet.png',
                          width: 300, // Increased size
                          height: 300, // Increased size
                        ),
                      ),
                    ),
                  ),
                ),
                ...fallingWidgets, // Add falling widgets to the stack
              ],
            ),
          ),
          SizedBox(height: 20),
          DroneUpgrade(noctilium: resource.noctilium, onBuyDrone: _buyDrone),
          SizedBox(height: 20),
          Container(
            height: 150, // Reduced height
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12)),
            child: ListView(
              children: history.reversed
                  .map((e) => Text(
                e,
                style: TextStyle(color: Colors.white70),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
