import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContainerWithTitle extends StatelessWidget {
  final String title;
  final String content;
  final double width;
  final Color titleBackgroundColor;
  final Color titleTextColor;
  const ContainerWithTitle({
    super.key,
    required this.titleTextColor,
    required this.titleBackgroundColor,
    required this.width,
    required this.content,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 7.1,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
            width: width.w,
            decoration: BoxDecoration(
              color: titleBackgroundColor,
              borderRadius: BorderRadius.circular(16.sp),
            ),
            child: Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                  color: titleTextColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16),
            child: Text(
              content,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Almarai',
                  color: const Color(0xff30727C)),
            ),
          )
        ],
      ),
    );
  }
}
