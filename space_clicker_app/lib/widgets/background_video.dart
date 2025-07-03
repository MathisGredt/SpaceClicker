import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_service.dart';

class BackgroundVideo extends StatefulWidget {
  final String assetPath;

  const BackgroundVideo({Key? key, required this.assetPath}) : super(key: key);

  @override
  _BackgroundVideoState createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  final VideoService videoService = VideoService();
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _loadAndPlayVideo();
  }

  Future<void> _loadAndPlayVideo() async {
    _videoController = await videoService.initializeVideo(widget.assetPath);
    if (mounted && _videoController != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    videoService.disposeVideo();
    _videoController = null; // Ensure the controller is set to null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController?.value.isInitialized ?? false) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }
    return Container(color: Colors.black); // Placeholder while video loads
  }
}