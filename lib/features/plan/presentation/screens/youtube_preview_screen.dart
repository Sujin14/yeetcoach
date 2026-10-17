import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePreviewScreen extends StatefulWidget {
  final String url;
  const YoutubePreviewScreen({super.key, required this.url});

  @override
  State<YoutubePreviewScreen> createState() => _YoutubePreviewScreenState();
}

class _YoutubePreviewScreenState extends State<YoutubePreviewScreen> {
  // Created once; building it in build() leaked a web player per rebuild.
  late final String? _videoId = YoutubePlayerController.convertUrlToId(widget.url);
  late final YoutubePlayerController? _controller = _videoId == null
      ? null
      : YoutubePlayerController.fromVideoId(
          videoId: _videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
          ),
        );

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Video Preview',
          style: TextStyle(color: Colors.white, fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: controller == null
            ? const Text(
                'Invalid video URL',
                style: TextStyle(color: Colors.white, fontSize: 14),
              )
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: controller),
              ),
      ),
    );
  }
}
