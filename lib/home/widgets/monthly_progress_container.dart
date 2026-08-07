import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../models/student_monthly_track_model.dart';

class MonthlyProgressContainer extends StatefulWidget {
  final String title;
  final List<Progress> data;
  final double width;
  final String prefixText;
  final String prefixItemText;

  const MonthlyProgressContainer({
    super.key,
    this.prefixText = '',
    this.prefixItemText = '',
    required this.width,
    required this.data,
    required this.title,
  });

  @override
  State<MonthlyProgressContainer> createState() => _MonthlyProgressContainer();
}

class _MonthlyProgressContainer extends State<MonthlyProgressContainer> {
  bool isMenuOpened = false;
  int pagesCount = 0;
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
            color: AppColors.appBarColor,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: AppColors.lightBrownColor,
              fontSize: 15.sp,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: widget.width,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x0c000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: InkWell(
            onTap: () {
              if (widget.data.isNotEmpty) {
                isMenuOpened = !isMenuOpened;
                setState(() {});
              }
            },
            child: Column(
              children: [
                SizedBox(
                  height: 45.h,
                  width: widget.width - 5.w,
                  child: Row(
                    children: [
                      widget.data.isEmpty
                          ? Spacer()
                          : Icon(
                              isMenuOpened
                                  ? Icons.keyboard_arrow_up_sharp
                                  : Icons.keyboard_arrow_down_sharp,
                              size: 20.sp,
                            ),
                      Expanded(
                        child: Text(
                          '${widget.prefixText}  $pagesCount',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkBrownColor,
                            fontSize: 15.sp,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMenuOpened ? 10.h : 0),
                Column(
                  children: List.generate(widget.data.length, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      height: isMenuOpened ? 40.h : 0,
                      width: widget.width.w - 10.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        children: [
                          Text(
                            '${widget.prefixItemText}  ',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.greyBrownColor,
                              fontFamily: 'Almarai',
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            '${widget.data[index].pagesNum}',
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: AppColors.greyBrownColor,
                              fontFamily: 'Almarai',
                              fontSize: 12.sp,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 170.w,
                            child: Text(
                              widget.data[index].name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.greyBrownColor,
                                fontFamily: 'Almarai',
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    for (var element in widget.data) {
      pagesCount += element.pagesNum;
    }

    super.initState();
  }
}
