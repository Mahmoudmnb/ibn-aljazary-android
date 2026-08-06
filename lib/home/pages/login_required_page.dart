import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class LoginRequiredPage extends StatelessWidget {
  final Function() onLoginPress;
  const LoginRequiredPage({super.key, required this.onLoginPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 323.w,
      height: 500.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 90.h),
          Image(
            image: AssetImage('assets/images/warning.png'),
            width: 150.w,
            height: 150.h,
          ),
          SizedBox(height: 25.h),
          Text(
            'عليك تسجيل الدخول أولاً',
            style: TextStyle(
                color: AppColors.brownColor,
                fontFamily: 'Almarai',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 50.h),
          InkWell(
            onTap: () {
              onLoginPress();
            },
            child: Container(
              alignment: Alignment.center,
              width: 160.w,
              height: 38.h,
              decoration: BoxDecoration(
                  color: AppColors.brownColor,
                  borderRadius: BorderRadius.circular(12.sp)),
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Almarai',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        ],
      ),
    );
  }
}
