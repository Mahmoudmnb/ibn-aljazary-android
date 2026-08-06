import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class DataPagesAppBar extends StatelessWidget {
  final String title;
  final onBackButtonPressed;
  final double height;
  const DataPagesAppBar({
    super.key,
    this.height = 90,
    required this.onBackButtonPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.h),
      alignment: Alignment.bottomCenter,
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appBarColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.sp),
          bottomRight: Radius.circular(20.sp),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          onBackButtonPressed == null
              ? SizedBox()
              : GestureDetector(
                  onTap: onBackButtonPressed,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(5.sp),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.lightBrownColor,
                        size: 15.sp,
                      ),
                    ),
                  ),
                ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightBrownColor,
                fontFamily: 'Almarai',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 45.w),
        ],
      ),
    );
  }
}
