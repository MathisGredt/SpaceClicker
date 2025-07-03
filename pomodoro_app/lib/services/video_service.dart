import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  VideoPlayerController? _videoController;

  factory VideoService() {
    return _instance;
  }

  VideoService._internal();

  Future<VideoPlayerController?> initializeVideo(String assetPath) async {
    try {
      if (_videoController != null) {
        return _videoController; // Reuse existing controller
      }

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final bytes = await rootBundle.load(assetPath);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/background.mp4');
        await file.writeAsBytes(bytes.buffer.asUint8List());

        _videoController = VideoPlayerController.file(file);
      } else {
        _videoController = VideoPlayerController.asset(assetPath);
      }

      await _videoController!.initialize();
      _videoController!
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      return _videoController;
    } catch (error) {
      print("❌ Error initializing video: $error");
      return null;
    }
  }

  void disposeVideo() {
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
  }
}