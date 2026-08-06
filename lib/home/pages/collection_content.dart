import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toast/toast.dart';

import '../../core/app_colors.dart';
import '../../core/mnb_icons.dart';
import '../bloc/home_bloc.dart';
import '../methods/home_page_methods.dart';
import '../models/file_collection.dart';
import '../widgets/audio_player.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/widgets.dart';
import 'pdf_screen.dart';

class CollectionContent extends StatefulWidget {
  final List content;
  final FileCollectionModel selectedCollection;
  final String pageTitle;
  const CollectionContent({
    super.key,
    required this.pageTitle,
    required this.selectedCollection,
    required this.content,
  });

  @override
  State<CollectionContent> createState() => _CollectionContentState();
}

class _CollectionContentState extends State<CollectionContent> {
  late FileCollectionModel selectedCollection;
  late DownloadManager downloadManager;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    selectedCollection = widget.selectedCollection;
    downloadManager = DownloadManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (Navigator.of(context).canPop()) {
          audioPlayer.stop();
          if (widget.pageTitle == 'الدروس العلمية') {
            var files = await getFiles('كورسات');
            Navigator.of(context).pop(files);
          } else {
            var files = await getFiles(widget.pageTitle);
            Navigator.of(context).pop(files);
          }
        }
      },
      child: BlocProvider(
        create: (context) => HomeBloc(),
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: AppColors.brownBackgroundColor,
              body: Column(
                children: [
                  DataPagesAppBar(
                    onBackButtonPressed: () async {
                      if (widget.pageTitle == 'الدروس العلمية') {
                        var files = await getFiles('كورسات');
                        Navigator.of(context).pop(files);
                      } else {
                        var files = await getFiles(widget.pageTitle);
                        Navigator.of(context).pop(files);
                      }
                    },
                    title: widget.pageTitle,
                  ),
                  SizedBox(
                    height: 607.h,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 30.h,
                                  bottom: 50.h,
                                ),
                                child: SizedBox(
                                  height: 530.h,
                                  child: ListView.builder(
                                    itemCount:
                                        selectedCollection.collections.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 20.h),
                                        child: Center(
                                          child: ExtendedMenu(
                                            fromPage: widget.pageTitle,
                                            onSelectItem:
                                                (
                                                  FileElement? fileElement,
                                                ) async {
                                                  try {
                                                    if (widget.pageTitle ==
                                                        'صوتيات') {
                                                      context
                                                          .read<HomeBloc>()
                                                          .add(
                                                            OpenMusicPlayer(
                                                              fileElement:
                                                                  fileElement,
                                                            ),
                                                          );
                                                      await audioPlayer
                                                          .setSpeed(1);
                                                    } else {
                                                      if (fileElement != null) {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  context,
                                                                ) => PDFScreen(
                                                                  file:
                                                                      fileElement,
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  } catch (e) {
                                                    ToastContext().init(
                                                      context,
                                                    );
                                                    Toast.show(
                                                      'حدث خطأ غير متوقع ',
                                                      duration:
                                                          Toast.lengthLong,
                                                    );
                                                  }
                                                },
                                            downloadManager: downloadManager,
                                            width: 275.w,
                                            icon: widget.pageTitle == 'صوتيات'
                                                ? Mnb.microphone_1
                                                : widget.pageTitle == 'كتب'
                                                ? Mnb.book_open
                                                : Icons.video_library,
                                            title: selectedCollection
                                                .collections[index]
                                                .name,
                                            items: selectedCollection
                                                .collections[index]
                                                .files,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 25.w),
                                child: FilesCustomContainer(
                                  listTitle: widget.pageTitle,
                                  onSelectItem: (value) async {
                                    selectedCollection = value;
                                    context.read<HomeBloc>().add(
                                      OpenMusicPlayer(fileElement: null),
                                    );
                                    await audioPlayer.stop();
                                    setState(() {});
                                  },
                                  selectedCollection: selectedCollection,
                                  items: widget.content,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomSheet: widget.pageTitle == 'صوتيات'
                  ? BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        FileElement? fileElement;
                        if (state is IsMusicPlayerOpened) {
                          fileElement = state.fileElement;
                        }
                        return fileElement != null
                            ? FutureBuilder(
                                future: audioPlayer.setFilePath(
                                  fileElement.localPath,
                                ),
                                builder: (context, snapshot) {
                                  snapshot.hasData ? audioPlayer.play() : null;
                                  return snapshot.hasData
                                      ? AudioPlayerWidget(
                                          onTapNextButton: () {
                                            if (fileElement != null) {
                                              for (var element
                                                  in selectedCollection
                                                      .collections) {
                                                for (
                                                  var i = 0;
                                                  i < element.files.length;
                                                  i++
                                                ) {
                                                  if (element.files.last.id ==
                                                      fileElement.id) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: null,
                                                          ),
                                                        );
                                                    audioPlayer.stop();
                                                  } else if (element
                                                              .files[i]
                                                              .id ==
                                                          fileElement.id &&
                                                      element
                                                          .files[i + 1]
                                                          .isDownloaded) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: element
                                                                .files[i + 1],
                                                          ),
                                                        );
                                                  } else if (element
                                                              .files[i]
                                                              .id ==
                                                          fileElement.id &&
                                                      !element
                                                          .files[i + 1]
                                                          .isDownloaded) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: null,
                                                          ),
                                                        );
                                                    audioPlayer.stop();
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          onTapPrevuesButton: () {
                                            if (fileElement != null) {
                                              for (var element
                                                  in selectedCollection
                                                      .collections) {
                                                for (
                                                  var i = 0;
                                                  i < element.files.length;
                                                  i++
                                                ) {
                                                  if (element.files.first.id ==
                                                      fileElement.id) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: null,
                                                          ),
                                                        );
                                                    audioPlayer.stop();
                                                  } else if (element
                                                              .files[i]
                                                              .id ==
                                                          fileElement.id &&
                                                      element
                                                          .files[i - 1]
                                                          .isDownloaded) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: element
                                                                .files[i - 1],
                                                          ),
                                                        );
                                                  } else if (element
                                                              .files[i]
                                                              .id ==
                                                          fileElement.id &&
                                                      !element
                                                          .files[i - 1]
                                                          .isDownloaded) {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          OpenMusicPlayer(
                                                            fileElement: null,
                                                          ),
                                                        );
                                                    audioPlayer.stop();
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          duration: snapshot.data!,
                                          height: fileElement == null ? 0 : 175,
                                          fileElement: fileElement,
                                          audioPlayer: audioPlayer,
                                        )
                                      : const SizedBox.shrink();
                                },
                              )
                            : const SizedBox.shrink();
                      },
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
