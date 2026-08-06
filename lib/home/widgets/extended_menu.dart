import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../bloc/home_bloc.dart';
import '../methods/home_page_methods.dart';
import '../models/file_collection.dart';
import 'expanded_menu_item.dart';

class ExtendedMenu extends StatefulWidget {
  final double width;
  final String title;
  final List<FileElement> items;
  final IconData icon;
  final DownloadManager downloadManager;
  final Function(FileElement?) onSelectItem;
  final String fromPage;
  const ExtendedMenu({
    super.key,
    this.fromPage = 'كتب',
    required this.onSelectItem,
    required this.downloadManager,
    required this.icon,
    required this.items,
    required this.title,
    required this.width,
  });

  @override
  State<ExtendedMenu> createState() => _ExtendedMenuState();
}

class _ExtendedMenuState extends State<ExtendedMenu> {
  bool isMenuOpened = false;
  int selectedFileIndex = -1;
  late DownloadManager dl;
  DownloadTask? task;
  int loadingItemIndex = -1;

  Future<void> downloadFile(String url, int index, BuildContext context) async {
    loadingItemIndex = index;
    setState(() {});
    await checkInternet(() async {
      final response = await http.head(Uri.parse(url));
      loadingItemIndex = -1;
      try {
        setState(() {});
      } catch (e) {}
      if (response.statusCode == 200) {
        if (url.contains('youtube.com') || url.contains('youtu.be')) {
          ToastContext().init(context);
          Toast.show('لا يمكن تحميل هذا الملف ', duration: Toast.lengthLong);
        } else {
          task = dl.getDownload(url);
          task = dl.getDownload(url);
          if (task != null && task!.status.value != DownloadStatus.completed) {
            switch (task!.status.value) {
              case DownloadStatus.downloading:
                await dl.pauseDownload(url);
                break;
              case DownloadStatus.paused:
                await dl.resumeDownload(url);
                break;
              case DownloadStatus.failed:
                {
                  await dl.cancelDownload(url);
                  var dir = await getApplicationSupportDirectory();
                  File partial = File(
                    '${dir.path}/${url.split('/').last}.partial',
                  );
                  File tempFile = File(
                    '${dir.path}/${url.split('/').last}.temp',
                  );
                  partial.existsSync()
                      ? partial.deleteSync()
                      : tempFile.existsSync()
                      ? tempFile.deleteSync()
                      : null;
                  await dl.addDownload(url, dir.path);
                  task = dl.getDownload(url);
                  task = dl.getDownload(url);
                }
              default:
                log(task!.status.value.toString());
            }
          } else {
            var dir = await getApplicationSupportDirectory();
            await dl.addDownload(url, dir.path);
            task = dl.getDownload(url);
            task = dl.getDownload(url);
          }
          setState(() {});
        }
      } else {
        ToastContext().init(context);
        Toast.show('رابط غير صالح', duration: Toast.lengthLong);
      }
    }, context);
  }

  @override
  initState() {
    dl = widget.downloadManager;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        selectedFileIndex = -1;
        setState(() {});
      },
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Color(0x0121eac0), blurRadius: 7.1),
          ],
        ),
        padding: EdgeInsets.only(bottom: isMenuOpened ? 20.h : 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(16.sp),
                onTap: () {
                  if (widget.items.isNotEmpty) {
                    isMenuOpened = !isMenuOpened;
                    setState(() {});
                  }
                },
                child: Container(
                  width: widget.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.sp),
                    color: AppColors.brownColor1,
                  ),
                  margin: EdgeInsets.only(bottom: isMenuOpened ? 20.h : 0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 11.h,
                  ),
                  child: Row(
                    children: [
                      widget.items.isEmpty
                          ? SizedBox()
                          : Icon(
                              isMenuOpened
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.brownColor,
                              size: 22.sp,
                            ),
                      // const Spacer(),
                      Expanded(
                        child: Text(
                          widget.title,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.brownColor,
                            fontSize: 16.sp,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) => BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    FileElement? fileElement;
                    if (state is IsMusicPlayerOpened) {
                      fileElement = state.fileElement;
                    }
                    return Center(
                      child: ExpandedMenuItem(
                        isLoading: loadingItemIndex == index,
                        withDownload: widget.fromPage != 'الدروس العلمية',
                        icon: widget.icon,
                        task: dl.getDownload(widget.items[index].url)
                          ?..status.addListener(() async {
                            var t = dl.getDownload(widget.items[index].url);
                            t = dl.getDownload(widget.items[index].url);
                            if (t != null &&
                                t.status.value == DownloadStatus.completed) {
                              var dir = await getApplicationSupportDirectory();
                              await updateFile(
                                "${dir.path}/${dl.getFileNameFromUrl(widget.items[index].url)}",
                                widget.items[index].id,
                              );
                              widget.items[index].isDownloaded = true;
                              widget.items[index].localPath =
                                  "${dir.path}/${dl.getFileNameFromUrl(widget.items[index].url)}";
                              try {
                                setState(() {});
                              } catch (e) {}
                            }
                          }),
                        width: widget.width - 14.w,
                        height: isMenuOpened ? 38.h : 0,
                        isItemSelected:
                            fileElement != null &&
                            fileElement.id == widget.items[index].id,
                        bottomMargin: index == widget.items.length - 1
                            ? 0
                            : isMenuOpened
                            ? 20.h
                            : 0,
                        downloadFile: () async {
                          if (widget.items[index].isDownloaded) {
                            if (fileElement == null ||
                                fileElement.id != widget.items[index].id) {
                              widget.onSelectItem(widget.items[index]);
                              setState(() {});
                            }
                          } else {
                            Constant.isThereLoading = true;
                            if (widget.fromPage == 'الدروس العلمية') {
                              await launchUrl(
                                Uri.parse(widget.items[index].url),
                              );
                            } else {
                              await downloadFile(
                                widget.items[index].url,
                                index,
                                context,
                              );
                            }

                            Constant.isThereLoading = false;
                          }
                        },
                        fileElement: widget.items[index],
                        onTap: () async {
                          if (widget.items[index].isDownloaded) {
                            if (fileElement == null ||
                                fileElement.id != widget.items[index].id) {
                              widget.onSelectItem(widget.items[index]);
                              setState(() {});
                            }
                          } else {
                            if (widget.fromPage == 'الدروس العلمية') {
                              try {
                                ToastContext().init(context);
                                final response = await http.head(
                                  Uri.parse(widget.items[index].url),
                                );
                                if (response.statusCode == 200) {
                                  await launchUrl(
                                    Uri.parse(widget.items[index].url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  Toast.show(
                                    'هناك مشكلة في الرابط',
                                    duration: Toast.lengthLong,
                                  );
                                }
                              } catch (e) {
                                if (e.toString().contains(
                                  'No host specified in URI',
                                )) {
                                  Toast.show(
                                    'هناك مشكلة في الرابط',
                                    duration: Toast.lengthLong,
                                  );
                                } else {
                                  Toast.show(
                                    'حدث خطأ غير متوقع ',
                                    duration: Toast.lengthLong,
                                  );
                                }
                              }
                            } else {
                              downloadFile(
                                widget.items[index].url,
                                index,
                                context,
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
