import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../models/file_collection.dart';

class ExpandedMenuItem extends StatelessWidget {
  final FileElement fileElement;
  final Function() onTap;
  final double width;
  final double height;
  final bool isItemSelected;
  final double bottomMargin;
  final DownloadTask? task;
  final IconData icon;
  final Function() downloadFile;
  final bool withDownload;
  final bool isLoading;
  const ExpandedMenuItem({
    super.key,
    this.task,
    this.isLoading = false,
    this.withDownload = true,
    required this.downloadFile,
    required this.icon,
    required this.bottomMargin,
    required this.isItemSelected,
    required this.width,
    required this.height,
    required this.onTap,
    required this.fileElement,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.sp),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 150),
        width: width,
        height: height == 0 ? height : null,
        decoration: BoxDecoration(
          color: isItemSelected ? AppColors.brownColor : Color(0xffEBE4E0),
          borderRadius: BorderRadius.circular(16.sp),
        ),
        margin: EdgeInsets.only(bottom: bottomMargin),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                fileElement.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isItemSelected ? Colors.white : AppColors.brownColor,
                  fontSize: 14.sp,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            task?.status.value == DownloadStatus.downloading
                ? ValueListenableBuilder(
                    valueListenable: task!.progress,
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          color: AppColors.brownColor,
                          value: value == 0.0 ? null : value,
                        ),
                      );
                    },
                  )
                : withDownload
                ? isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            color: AppColors.brownColor,
                          ),
                        )
                      : InkWell(
                          onTap: downloadFile,
                          child: Icon(
                            fileElement.isDownloaded
                                ? icon
                                : Icons.download_outlined,
                            color: isItemSelected
                                ? Colors.white
                                : AppColors.brownColor,
                            size: height != 0 ? 20.sp : 0,
                          ),
                        )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
