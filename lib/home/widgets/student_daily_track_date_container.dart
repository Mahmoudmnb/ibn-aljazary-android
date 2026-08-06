import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';

import '../../core/app_colors.dart';
import 'widgets.dart';

class StudentDailyTrackDateContainer extends StatefulWidget {
  final Future Function(DateTime?) onTap;
  final bool withList;
  final bool allDataMode;
  final bool fullDateMode;
  final DateTime? date;
  const StudentDailyTrackDateContainer({
    super.key,
    this.date,
    this.allDataMode = false,
    this.withList = false,
    this.fullDateMode = false,
    required this.onTap,
  });

  @override
  State<StudentDailyTrackDateContainer> createState() =>
      _StudentDailyTrackDateContainerState();
}

class _StudentDailyTrackDateContainerState
    extends State<StudentDailyTrackDateContainer> {
  bool isMenuOpened = false;
  String gregorianDate = '';
  String hijriDate = '';
  String middleText = '';
  bool isLoading = false;
  bool allDataMode = false;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brownColor),
      ),
      child: Builder(
        builder: (context) {
          return TapRegion(
            onTapOutside: (event) {
              isMenuOpened = false;
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (!isLoading) {
                      if (widget.withList) {
                        isMenuOpened = !isMenuOpened;
                        setState(() {});
                      } else {
                        DateTime? date = await pickDate(context, null);
                        isLoading = true;
                        setState(() {});
                        widget.onTap(date);
                        isLoading = false;
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    height: 36.h,
                    width: 290.w,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.brownColor1,
                      borderRadius: BorderRadius.circular(16.sp),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        !isLoading
                            ? Text(
                                hijriDate,
                                style: const TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14,
                                  color: AppColors.brownColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const SizedBox.shrink(),
                        !isLoading
                            ? Text(
                                middleText,
                                style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14.sp,
                                  color: AppColors.brownColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                        !isLoading
                            ? Text(
                                gregorianDate,
                                style: const TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14,
                                  color: AppColors.brownColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                widget.withList
                    ? CustomList(
                        title: 'طريقة العرض',
                        borderRadius: BorderRadius.circular(20.sp),
                        maxHight: 160.h,
                        width: 275.w,
                        topOffset: 40.h,
                        titleColor: AppColors.darkBrownColor,
                        isMenuOpened: isMenuOpened,
                        items: [
                          CustomListItem(
                            borderRadius: BorderRadius.circular(16.sp),
                            onTap: () async {
                              isMenuOpened = false;
                              middleText = 'محصلة الأسبوع';
                              allDataMode = true;
                              hijriDate = '';
                              gregorianDate = '';
                              await widget.onTap(DateTime(0));
                              setState(() {});
                            },
                            text: 'محصلة الأسبوع',
                            backgroundColor: AppColors.appBarColor,
                            textColor: AppColors.brownColor,
                          ),
                          CustomListItem(
                            borderRadius: BorderRadius.circular(16.sp),
                            onTap: () async {
                              isMenuOpened = false;
                              setState(() {});
                              DateTime? date = await pickDate(
                                context,
                                DateTime.now(),
                              );
                              isLoading = true;
                              setState(() {});
                              await widget.onTap(date);
                              isLoading = false;
                              allDataMode = false;
                              setState(() {});
                            },
                            text: 'إنجاز اليوم',
                            backgroundColor: AppColors.appBarColor,
                            textColor: AppColors.brownColor,
                          ),
                          CustomListItem(
                            borderRadius: BorderRadius.circular(16.sp),
                            onTap: () async {
                              isMenuOpened = false;
                              setState(() {});
                              DateTime? date = await pickDate(context, null);
                              isLoading = true;
                              setState(() {});
                              await widget.onTap(date);
                              isLoading = false;
                              allDataMode = false;
                              setState(() {});
                            },
                            text: 'اختيار يوم محدد',
                            backgroundColor: AppColors.appBarColor,
                            textColor: AppColors.brownColor,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    if (allDataMode) {
      middleText = 'إنجاز اليوم';
    } else {
      DateTime date = widget.date ?? DateTime.now();
      HijriDate h = HijriDate.dataToHijri(date.day, date.month, date.year);
      if (widget.fullDateMode) {
        gregorianDate = '${date.day} - ${date.month}  - ${date.year}';
        hijriDate = '${h.year} - ${h.dayName} - ${h.monthName} ';
      } else {
        gregorianDate = '${date.month} - ${date.year}';
        hijriDate = '${h.year}-${h.monthName}';
      }
    }
    super.initState();
  }

  Future<DateTime?> pickDate(BuildContext context, DateTime? date) async {
    if (date == null) {
      date = await showDatePicker(
        context: context,
        firstDate: DateTime(1500),
        lastDate: DateTime(5000),
      );
    }

    if (date != null) {
      middleText = '';
      HijriDate h = HijriDate.dataToHijri(date.day, date.month, date.year);
      if (widget.fullDateMode) {
        gregorianDate = '${date.day} - ${date.month}  - ${date.year}';
        hijriDate = '${h.year} - ${h.dayName} - ${h.monthName} ';
      } else {
        gregorianDate = '${date.month} - ${date.year}';
        hijriDate = '${h.year}-${h.monthName}';
      }
      setState(() {});
    }
    return date;
  }
}
