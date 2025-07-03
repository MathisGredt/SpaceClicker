import 'dart:math';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  late final AudioPlayer _player;
  final List<String> _tracks = [
    'assets/sounds/moonlit_whispers.mp3',
    'assets/sounds/starlit_horizons.mp3',
    'assets/sounds/whisper_of_the_stars.mp3',
    'assets/sounds/whispers_in_the_wind.mp3',
  ];

  int? _currentTrackIndex;
  final Random _random = Random();

  AudioService._internal() {
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playRandomTrack();
      }
    });

    _player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('🛑 Playback error: $e');
    });

    await _playRandomTrack();
  }

  Future<void> _playRandomTrack() async {
    int nextTrackIndex;
    do {
      nextTrackIndex = _random.nextInt(_tracks.length);
    } while (_tracks.length > 1 && nextTrackIndex == _currentTrackIndex);

    _currentTrackIndex = nextTrackIndex;
    final track = _tracks[_currentTrackIndex!];

    try {
      await _player.setAsset(track);
      await _player.setVolume(0.1);
      await _player.play();
    } catch (e) {
      print('❌ Error playing track: $e');
    }
  }

  void pause() => _player.pause();
  void resume() => _player.play();
  void stop() => _player.stop();

  bool get isPlaying => _player.playing;
}