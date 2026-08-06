import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/app_colors.dart';
import '../models/file_collection.dart';

class VideoPage extends StatefulWidget {
  final FileElement file;
  const VideoPage({
    super.key,
    required this.file,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  @override
  void initState() {
    videoPlayerController =
        VideoPlayerController.file(File(widget.file.localPath));
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    // chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: videoPlayerController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.brownColor,
            ),
          );
        } else {
          chewieController = ChewieController(
            allowMuting: true,
            videoPlayerController: videoPlayerController,
            autoPlay: true,
            looping: true,
          );
          final playerWidget = Chewie(
            controller: chewieController,
          );
          return playerWidget;
        }
      },
    );
  }
}
