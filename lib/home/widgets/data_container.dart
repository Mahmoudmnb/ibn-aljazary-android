import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../models/student_test_model.dart';

class TestDataContainer extends StatefulWidget {
  final String title;
  final StudentTestModel data;
  final double width;
  const TestDataContainer({
    super.key,
    required this.width,
    required this.data,
    required this.title,
  });

  @override
  State<TestDataContainer> createState() => _TestDataContainerState();
}

class _TestDataContainerState extends State<TestDataContainer> {
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
            color: AppColors.brownColor1,
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
                      Spacer(),
                      Text(
                        widget.data.testSubject,
                        style: TextStyle(
                          color: AppColors.darkBrownColor,
                          fontSize: 17.sp,
                          fontFamily: 'Almarai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMenuOpened ? 10.h : 0),
                Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      widget.data.data.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 50),
                        height: isMenuOpened ? 70.h : 0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.data.data[index].attName.toString(),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'Almarai',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.lightBrownColor,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                widget.data.data[index].mark.toString() ==
                                            'true' ||
                                        widget.data.data[index].mark
                                                .toString() ==
                                            '1'
                                    ? 'نعم'
                                    : widget.data.data[index].mark.toString() ==
                                              'false' ||
                                          widget.data.data[index].mark
                                                  .toString() ==
                                              '0'
                                    ? 'لا'
                                    : widget.data.data[index].mark.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Almarai',
                                  color: AppColors.greyBrownColor,
                                ),
                              ),
                              SizedBox(height: 15.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
