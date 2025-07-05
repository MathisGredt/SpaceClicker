import 'dart:math';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _clickPlayer; // Instance dédiée aux sons de clic
  final List<String> _tracks = [
    'assets/sounds/moonlit_whispers.mp3',
    'assets/sounds/starlit_horizons.mp3',
    'assets/sounds/whisper_of_the_stars.mp3',
    'assets/sounds/whispers_in_the_wind.mp3',
  ];

  int? _currentTrackIndex;
  final Random _random = Random();

  AudioService._internal() {
    _musicPlayer = AudioPlayer();
    _clickPlayer = AudioPlayer(); // Initialisation de l'instance pour les clics
    _init();
  }

  Future<void> _init() async {
    _musicPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playRandomTrack();
      }
    });

    await _playRandomTrack();
  }

  Future<void> _playRandomTrack() async {
    if (_tracks.isEmpty) return; // Vérifie que la liste des pistes n'est pas vide

    int nextTrackIndex;
    if (_tracks.length == 1) {
      nextTrackIndex = 0; // Si une seule piste, joue cette piste
    } else {
      do {
        nextTrackIndex = _random.nextInt(_tracks.length);
      } while (nextTrackIndex == _currentTrackIndex);
    }

    _currentTrackIndex = nextTrackIndex;
    final track = _tracks[_currentTrackIndex!];

    try {
      await _musicPlayer.setAsset(track);
      await _musicPlayer.setVolume(0.1);
      await _musicPlayer.play();
    } catch (e) {
      print('❌ Error playing track: $e');
    }
  }

  Future<void> playClickSound(String soundPath) async {
    try {
      await _clickPlayer.setAsset(soundPath);
      await _clickPlayer.setVolume(0.2);
      await _clickPlayer.play();
    } catch (e) {
      print('❌ Error playing click sound: $e');
    }
  }

  void pauseMusic() => _musicPlayer.pause();
  void resumeMusic() => _musicPlayer.play();
  void stopMusic() => _musicPlayer.stop();

  bool get isMusicPlaying => _musicPlayer.playing;
}