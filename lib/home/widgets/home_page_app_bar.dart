import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';

class HomepageAppBar extends StatelessWidget {
  final Future<void> Function() openDrawer;
  final Future<void> Function() openNotificationDrawerDrawer;

  final String title;
  const HomepageAppBar({
    super.key,
    required this.openDrawer,
    required this.openNotificationDrawerDrawer,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.only(bottom: 10.h),
      alignment: Alignment.bottomCenter,
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
          Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  await openNotificationDrawerDrawer();
                },
                child: IconButton(
                  onPressed: null,
                  icon: Icon(
                    Mnb.notification,
                    color: AppColors.lightBrownColor,
                    size: 25.sp,
                  ),
                ),
              ),
              Constant.notifications.isNotEmpty
                  ? Positioned(
                      top: 25.h,
                      right: 13,
                      child: Container(
                        width: 8.h,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
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
          IconButton(
            onPressed: () async {
              await openDrawer();
            },
            icon: Icon(
              Mnb.list_caption,
              color: AppColors.lightBrownColor,
              size: 25.sp,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }
}
