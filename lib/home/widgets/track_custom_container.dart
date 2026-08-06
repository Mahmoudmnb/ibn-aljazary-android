import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets.dart';

class TrackCustomContainer extends StatelessWidget {
  final String title;
  final List<ProgressBarItem> items;
  const TrackCustomContainer({
    super.key,
    required this.items,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.sp),
      ),
      padding: EdgeInsets.all(15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xff30727C),
                fontFamily: 'Almarai',
                fontSize: 16.sp,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 14.h),
          ...List.generate(items.length, (index) {
            return Column(
              children: [
                ProgressBar(
                    maxValue: items[index].maxValue,
                    value: items[index].value,
                    progressColor: items[index].progressColor,
                    lastColor: items[index].lastColor,
                    rightText: items[index].rightText,
                    lefText: items[index].lefText,
                    width: items[index].width,
                    height: items[index].height),
                index == items.length - 1
                    ? const SizedBox.shrink()
                    : SizedBox(height: 14.h),
              ],
            );
          }),
        ],
      ),
    );
  }
}
