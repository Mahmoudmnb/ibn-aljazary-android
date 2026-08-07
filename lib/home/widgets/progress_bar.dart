import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double maxValue;
  final double value;
  final Color progressColor;
  final Color lastColor;
  final String rightText;
  final String lefText;
  final double width;
  final double height;
  const ProgressBar({
    super.key,
    required this.maxValue,
    required this.value,
    required this.progressColor,
    required this.lastColor,
    required this.rightText,
    required this.lefText,
    required this.width,
    required this.height,
  }); //: assert(value <= maxValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: lastColor,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 7.1)],
      ),
      alignment: Alignment.centerRight,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            width: (width * value / maxValue) > 0
                ? (width * value / maxValue)
                : maxValue,
            height: height,
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: BorderRadius.circular(16.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  lefText,
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.rtl,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.green,
                    fontFamily: 'Almarai',
                    // fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // const Spacer(),
                Expanded(
                  child: Text(
                    rightText,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.green,
                      fontFamily: 'Almarai',
                      // fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
