import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../models/student_monthly_track_model.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/monthly_progress_container.dart';
import '../widgets/widgets.dart';

class StudentMonthlyTrack extends StatefulWidget {
  final List studentTracks;
  const StudentMonthlyTrack({super.key, required this.studentTracks});

  @override
  State<StudentMonthlyTrack> createState() => _StudentMonthlyTrackState();
}

class _StudentMonthlyTrackState extends State<StudentMonthlyTrack> {
  late DateTime date;
  late List studentTracks;
  StudentMonthlyTrackModel? studentTrackModel;
  int maxDayOfTheDate = 0;
  @override
  void initState() {
    date = DateTime.now();
    String tempMonth = date.month.toString().length < 2
        ? '0${date.month}'
        : date.month.toString();
    String tempDate = '${date.year}-$tempMonth';
    studentTracks = widget.studentTracks;
    List item = studentTracks
        .where((element) => element['date'] == tempDate)
        .toList();
    if (item.isNotEmpty) {
      studentTrackModel = StudentMonthlyTrackModel.fromJson(item.first);
      maxDayOfTheDate = DateTime(
        int.parse(studentTrackModel!.date.split('-').first),
        int.parse(studentTrackModel!.date.split('-').last) + 1,
        0,
      ).day;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
            title: 'الانجاز الشهري',
          ),
          SizedBox(
            height: 607.h,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  DateContainer(
                    onlyCenterText: true,
                    onTap: (p0) async {
                      if (p0 != null) {
                        date = p0;
                        String tempMonth = date.month.toString().length < 2
                            ? '0${date.month}'
                            : date.month.toString();
                        String tempDate = '${date.year}-$tempMonth';
                        List item = studentTracks
                            .where((element) => element['date'] == tempDate)
                            .toList();
                        if (item.isNotEmpty) {
                          studentTrackModel = StudentMonthlyTrackModel.fromJson(
                            item.first,
                          );
                          maxDayOfTheDate = DateTime(
                            int.parse(studentTrackModel!.date.split('-').first),
                            int.parse(studentTrackModel!.date.split('-').last) +
                                1,
                            0,
                          ).day;
                        } else {
                          studentTrackModel = null;
                        }
                        setState(() {});
                      }
                    },
                    // withList: true,
                  ),
                  SizedBox(height: 16.h),
                  studentTrackModel != null
                      ? SizedBox(
                          height: 510.h,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                MonthlyProgressContainer(
                                  width: 291.w,
                                  data: studentTrackModel!.quranProgress,
                                  title: 'حفظ القرآن',
                                ),
                                SizedBox(height: 15.h),
                                Container(
                                  alignment: Alignment.center,
                                  width: 291.w,
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.sp),
                                    color: AppColors.appBarColor,
                                  ),
                                  child: Text(
                                    'الغياب',
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
                                  width: 291.w,
                                  height: 45.h,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
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
                                  child: Row(
                                    children: [
                                      Text(
                                        studentTrackModel!.offDays.toString(),
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.darkBrownColor,
                                          fontSize: 15.sp,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'عدد أيام الغياب',
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.darkBrownColor,
                                          fontSize: 15.sp,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Container(
                                  alignment: Alignment.center,
                                  width: 291.w,
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.sp),
                                    color: AppColors.appBarColor,
                                  ),
                                  child: Text(
                                    'النقاط',
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
                                  width: 291.w,
                                  height: 45.h,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                  ),
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
                                  child: Row(
                                    children: [
                                      Text(
                                        studentTrackModel!.pointsCount
                                            .toString(),
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.darkBrownColor,
                                          fontSize: 15.sp,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        'النقاط',
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.darkBrownColor,
                                          fontSize: 15.sp,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(height: 20.h),
                            Image.asset(
                              'assets/images/warning.png',
                              width: 200.w,
                              height: 200.h,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'لا يوجد تفقد في هذا الشهر',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.brownColor,
                                fontSize: 35.sp,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
