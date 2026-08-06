import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/extensions.dart';
import '../models/student_recall_model.dart';

class RecallDataContainer extends StatefulWidget {
  final String title;
  final StudentRecallModel data;
  final double width;
  const RecallDataContainer({
    super.key,
    required this.width,
    required this.data,
    required this.title,
  });

  @override
  State<RecallDataContainer> createState() => _RecallDataContainerState();
}

class _RecallDataContainerState extends State<RecallDataContainer> {
  bool isMenuOpened = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            width: widget.width,
            height: 44.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.sp),
                color: AppColors.appBarColor),
            child: Text(
              widget.title,
              style: TextStyle(
                  color: AppColors.lightBrownColor,
                  fontSize: 15.sp,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700),
            )),
        SizedBox(height: 8.h),
        Container(
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Color(0x0c000000), blurRadius: 8, offset: Offset(0, 2))
          ], color: Colors.white, borderRadius: BorderRadius.circular(16.sp)),
          child: InkWell(
            onTap: () {
              isMenuOpened = !isMenuOpened;
              setState(() {});
            },
            child: Column(
              children: [
                SizedBox(
                  height: 45.h,
                  child: Row(
                    children: [
                      Icon(
                        isMenuOpened
                            ? Icons.keyboard_arrow_up_sharp
                            : Icons.keyboard_arrow_down_sharp,
                        size: 20.sp,
                      ),
                      SizedBox(
                        width: 240.w,
                        child: Text(
                          widget.data.cause,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.darkBrownColor,
                              fontSize: 15.sp,
                              fontFamily: 'Almarai',
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: isMenuOpened ? 10.h : 0),
                Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 50),
                          height: isMenuOpened ? 280.h : 0,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('تاريخ الاستدعاء',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'Almarai',
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightBrownColor)),
                                SizedBox(height: 10.h),
                                Text(widget.data.recallDate.toCustomString(),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Almarai',
                                        color: AppColors.greyBrownColor)),
                                SizedBox(height: 15.h),
                                Text('تمت المراجعة',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'Almarai',
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightBrownColor)),
                                SizedBox(height: 10.h),
                                Text(widget.data.isChecked == 1 ? 'نعم' : 'لا',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Almarai',
                                        color: AppColors.greyBrownColor)),
                                SizedBox(height: 15.h),
                                Text('المراجع',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'Almarai',
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightBrownColor)),
                                SizedBox(height: 10.h),
                                Text(
                                    widget.data.checkerName.isEmpty
                                        ? '-       '
                                        : widget.data.checkerName,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Almarai',
                                        color: AppColors.greyBrownColor)),
                                SizedBox(height: 15.h),
                                Text('تاريخ المراجعة',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'Almarai',
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightBrownColor)),
                                SizedBox(height: 10.h),
                                Text(
                                    widget.data.checkDate.isEmpty
                                        ? '-         '
                                        : widget.data.checkDate,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontFamily: 'Almarai',
                                        color: AppColors.greyBrownColor)),
                                SizedBox(height: 15.h),
                              ],
                            ),
                          ),
                        ),
                      ]),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
