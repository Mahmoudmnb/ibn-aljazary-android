import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';
import '../models/app_notification.dart';

class NotificationDrawer extends StatefulWidget {
  final Function() onDrawerClosed;
  const NotificationDrawer({super.key, required this.onDrawerClosed});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  late List<AppNotification> notifications;
  @override
  initState() {
    notifications = Constant.notifications.reversed.toList();
    super.initState();
  }

  @override
  void dispose() {
    widget.onDrawerClosed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60.h,
          width: 60.w,
          margin: EdgeInsets.only(top: 11.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
              bottomRight: Radius.circular(20.sp),
            ),
          ),
          child: Icon(
            Mnb.notification,
            color: AppColors.brownColor,
            size: 25.sp,
          ),
        ),
        Container(
          width: 240.w,
          height: 360.h,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(bottom: 8.h, top: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.sp),
              bottomRight: Radius.circular(20.sp),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                notifications.length,
                (index) => Container(
                  width: 220.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.brownColor1.withAlpha(950),
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Text(
                    notifications[index].body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Almarai',
                      color: AppColors.brownColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
