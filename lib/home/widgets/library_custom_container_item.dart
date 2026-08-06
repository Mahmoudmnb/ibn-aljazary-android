import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class LibraryCustomContainerItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function() onTap;
  const LibraryCustomContainerItem({
    super.key,
    required this.icon,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 244.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.brownColor2,
          borderRadius: BorderRadius.circular(16.sp),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: AppColors.brownColor,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              icon,
              size: 20.sp,
              color: AppColors.brownColor,
            )
          ],
        ),
      ),
    );
  }
}
