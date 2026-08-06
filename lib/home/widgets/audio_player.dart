import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../models/file_collection.dart';

class AudioPlayerWidget extends StatefulWidget {
  final double height;
  final FileElement? fileElement;
  final AudioPlayer audioPlayer;
  final Duration? duration;
  final Function() onTapPrevuesButton;
  final Function() onTapNextButton;
  const AudioPlayerWidget({
    super.key,
    required this.onTapNextButton,
    required this.onTapPrevuesButton,
    required this.duration,
    required this.audioPlayer,
    required this.fileElement,
    required this.height,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  double height = 0;
  String durationToString(Duration? d) {
    Duration duration = Duration.zero;
    if (d != null) {
      duration = d;
    }
    String hour = duration.toString().split(':')[0].length < 2
        ? '0${duration.toString().split(':')[0]}'
        : duration.toString().split(':')[0];
    String minutes = duration.toString().split(':')[1].length < 2
        ? '0${duration.toString().split(':')[1]}'
        : duration.toString().split(':')[1];
    String seconds = duration.toString().split(':')[2].length < 2
        ? '0${duration.toString().split(':')[2]}'
        : duration.toString().split(':')[2];
    if (duration.inHours > 0) {
      return '$hour:$minutes';
    } else {
      return '$minutes:${seconds.split('.')[0]}';
    }
  }

  @override
  void initState() {
    height = widget.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        if (height != 50) {
          height = 50;
          setState(() {});
        }
      },
      onTapInside: (event) {
        if (height != widget.height) {
          height = widget.height;
          setState(() {});
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: height.h,
        width: 323.w,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(blurRadius: 7.1, color: Color(0x19000000))
            ],
            color: AppColors.greyBrownColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.sp),
                topRight: Radius.circular(16.sp))),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Text(
                widget.fileElement?.name ?? '',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              SizedBox(height: 12.h),
              StreamBuilder(
                stream: widget.audioPlayer.positionStream,
                builder:
                    (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                  double value = 0;
                  if (snapshot.hasData) {
                    value = snapshot.data!.inSeconds + 0.0;
                    if (value == widget.duration!.inSeconds) {
                      widget.audioPlayer.seek(const Duration(seconds: 0));
                      widget.audioPlayer.stop();
                    }
                  }
                  return Slider(
                    value: value,
                    onChanged: (value) async {
                      await widget.audioPlayer.seek(Duration(
                        seconds: int.parse(value.toString().split('.').first),
                      ));
                    },
                    thumbColor: Colors.white,
                    max: widget.duration == null
                        ? 0.0
                        : widget.duration!.inSeconds + 0.0,
                    min: 0,
                    inactiveColor: const Color(0xffffffff),
                    activeColor: AppColors.darkBrownColor,
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder(
                      stream: widget.audioPlayer.positionStream,
                      builder: (context, snapshot) {
                        return Text(
                          durationToString(widget.audioPlayer.position),
                          style: TextStyle(
                            color: const Color(0xffffffff),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Almarai',
                          ),
                        );
                      },
                    ),
                    Text(
                      durationToString(widget.duration),
                      style: TextStyle(
                        color: const Color(0xffffffff),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context
                              .read<HomeBloc>()
                              .add(OpenMusicPlayer(fileElement: null));
                          widget.audioPlayer.stop();
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: const Color(0xffffffff),
                          size: 25.sp,
                        )),
                    SizedBox(width: 20.w),
                    IconButton(
                        onPressed: () {
                          widget.onTapPrevuesButton();
                        },
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 25.sp,
                        )),
                    SizedBox(width: 40.w),
                    IconButton(
                        onPressed: () {
                          if (widget.audioPlayer.playerState.playing) {
                            widget.audioPlayer.pause();
                          } else {
                            widget.audioPlayer.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          widget.audioPlayer.playerState.playing
                              ? Icons.play_circle_outline
                              : Icons.pause_circle_outline,
                          color: Colors.white,
                          size: 25.sp,
                        )),
                    SizedBox(width: 40.w),
                    IconButton(
                        onPressed: () {
                          widget.onTapNextButton();
                        },
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 25.sp,
                        )),
                    SizedBox(width: 0.w),
                    // IconButton(
                    //     onPressed: () async {
                    //       double speed = widget.audioPlayer.speed;
                    //       speed = speed == 0.5
                    //           ? 1
                    //           : speed == 1
                    //               ? 1.5
                    //               : speed == 1.5
                    //                   ? 2
                    //                   : 0.5;
                    //       widget.audioPlayer.setSpeed(speed);
                    //     },
                    //     icon: Icon(
                    //       Icons.replay,
                    //       color: const Color(0xffffffff),
                    //       size: 25.sp,
                    //     ))
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: Row(
                  children: [
                    const Spacer(),
                    StreamBuilder<double>(
                        stream: widget.audioPlayer.speedStream,
                        builder: (context, snapshot) {
                          double speed = 1;
                          if (snapshot.hasData) {
                            speed = snapshot.data!;
                          }
                          return InkWell(
                            onTap: () {
                              double speed = widget.audioPlayer.speed;
                              speed = speed == 0.5
                                  ? 1
                                  : speed == 1
                                      ? 1.5
                                      : speed == 1.5
                                          ? 2
                                          : 0.5;
                              widget.audioPlayer.setSpeed(speed);
                            },
                            child: Text(
                              '${speed}x',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Almarai',
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffffffff),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
