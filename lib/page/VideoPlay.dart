import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlay extends StatefulWidget {
  final videoPath;

  const VideoPlay({Key key, @required this.videoPath}) : super(key: key);
  @override
  _VideoPlayState createState() => _VideoPlayState(videoPath);
}

class _VideoPlayState extends State<VideoPlay> {
  final videoPath;
  VideoPlayerController _controller;

  _VideoPlayState(this.videoPath);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(videoPath))
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller.value.size?.width ?? 0,
              height: _controller.value.size?.height ?? 0,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
