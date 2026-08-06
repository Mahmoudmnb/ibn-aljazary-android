import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';

import '../../core/app_colors.dart';
import '../../core/mnb_icons.dart';

class DateContainer extends StatefulWidget {
  final Future Function(DateTime?) onTap;
  final bool withList;
  final bool allDataMode;
  final bool fullDateMode;
  final bool onlyCenterText;
  const DateContainer({
    super.key,
    this.onlyCenterText = false,
    this.allDataMode = false,
    this.withList = false,
    this.fullDateMode = false,
    required this.onTap,
  });

  @override
  State<DateContainer> createState() => _DateContainerState();
}

class _DateContainerState extends State<DateContainer> {
  bool isMenuOpened = false;
  String gregorianDate = '';
  String hijriDate = '';
  String middleText = '';
  bool isLoading = false;
  late DateTime date;
  Future<DateTime?> pickDate(BuildContext context) async {
    DateTime? date = await showDatePicker(
        context: context, firstDate: DateTime(1500), lastDate: DateTime(5000));
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

  @override
  void initState() {
    if (widget.allDataMode) {
      middleText = 'عرض الكل';
    }
    date = DateTime.now();
    HijriDate h = HijriDate.dataToHijri(date.day, date.month, date.year);
    if (widget.fullDateMode) {
      gregorianDate = '${date.day} - ${date.month}  - ${date.year}';
      hijriDate = '${h.year} - ${h.dayName} - ${h.monthName} ';
    } else {
      gregorianDate = '${date.month} - ${date.year}';
      hijriDate = '${h.year}-${h.monthName}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appBarColor),
      ),
      child: Builder(builder: (context) {
        return Row(
          children: [
            SizedBox(width: 18.w),
            GestureDetector(
              onTap: widget.onlyCenterText
                  ? null
                  : () {
                      if (middleText.isEmpty) {
                        middleText = 'عرض الكل';
                        widget.onTap(DateTime(0));
                        setState(() {});
                      }
                      // else {
                      //   middleText = '';
                      //   widget.onTap(date);
                      //   HijriDate h = HijriDate.dataToHijri(
                      //       date.day, date.month, date.year);
                      //   if (widget.fullDateMode) {
                      //     gregorianDate =
                      //         '${date.day} - ${date.month}  - ${date.year}';
                      //     hijriDate =
                      //         '${h.year} - ${h.dayName} - ${h.monthName} ';
                      //   } else {
                      //     gregorianDate = '${date.month} - ${date.year}';
                      //     hijriDate = '${h.year}-${h.monthName}';
                      //   }
                      // }
                    },
              child: Container(
                width: 240.w,
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                    color: AppColors.dartBrownColor1,
                    borderRadius: BorderRadius.circular(16.sp)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    middleText.isNotEmpty
                        ? SizedBox.shrink()
                        : Text(
                            hijriDate,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Almarai',
                            ),
                          ),
                    middleText.isNotEmpty
                        ? Text(
                            middleText,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontFamily: 'Almarai',
                                fontWeight: FontWeight.w700),
                          )
                        : SizedBox.shrink(),
                    middleText.isNotEmpty ? SizedBox.shrink() : Spacer(),
                    middleText.isNotEmpty
                        ? SizedBox.shrink()
                        : Text(
                            gregorianDate,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'Almarai',
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () async {
                DateTime? d = await pickDate(context);
                if (d != null) {
                  date = d;
                }
                widget.onTap(d);
              },
              child: Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                    color: AppColors.dartBrownColor1,
                    borderRadius: BorderRadius.circular(16.sp)),
                child: Icon(
                  Mnb.calendar,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
