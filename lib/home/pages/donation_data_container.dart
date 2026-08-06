import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class DonationDataContainer extends StatelessWidget {
  final String title;
  final String text;
  const DonationDataContainer({
    super.key,
    required this.text,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 291.w,
          height: 44.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.appBarColor,
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.brownColor,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 291.w,
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xc000000),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: AppColors.brownColor,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
              Spacer(),
              Text(
                'مبلغ التبرع',
                style: TextStyle(
                  color: AppColors.brownColor,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
