import 'dart:async';

class BonusService {
  double bonusMultiplier = 1.0;
  Timer? bonusTimer;

  void activateBonus(Function onBonusEnd) {
    if (bonusTimer != null && bonusTimer!.isActive) return;

    bonusMultiplier = 2.0;
    bonusTimer = Timer(Duration(seconds: 10), () {
      bonusMultiplier = 1.0;
      onBonusEnd();
    });
  }

  void dispose() {
    bonusTimer?.cancel();
  }
}