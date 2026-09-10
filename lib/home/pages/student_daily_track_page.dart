import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/pages/splash_screen.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/extensions.dart';
import '../methods/home_page_methods.dart';
import '../models/student_daily_check.dart';
import '../models/student_monthly_track_model.dart';
import '../widgets/drawer.dart';
import '../widgets/home_page_app_bar.dart';
import '../widgets/monthly_progress_container.dart';
import '../widgets/student_daily_track_date_container.dart';
import '../widgets/widgets.dart';
import 'communication_page.dart';
import 'login_required_page.dart';

class StudentDailyTrackPage extends StatefulWidget {
  final List studentDailyTrack;
  final PageController pageController;
  final Map studentWeaklyProgress;
  const StudentDailyTrackPage({
    super.key,
    required this.studentWeaklyProgress,
    required this.pageController,
    required this.studentDailyTrack,
  });

  @override
  State<StudentDailyTrackPage> createState() => _StudentDailyTrackPageState();
}

class _StudentDailyTrackPageState extends State<StudentDailyTrackPage> {
  late DateTime date;
  late List studentTracks;
  StudentDailyTrackModel? studentTrackModel;
  bool isWeaklyTrack = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _selectDailyTrackForDate(DateTime selectedDate) {
    date = selectedDate;
    final item = studentTracks
        .where(
          (element) =>
              element is Map && element['trackDate'] == date.toCustomString(),
        )
        .toList();
    if (item.isNotEmpty) {
      studentTrackModel = StudentDailyTrackModel.fromJson(
        Map<String, dynamic>.from(item.first),
      );
    } else {
      studentTrackModel = null;
    }
  }

  Map<dynamic, dynamic> get _weeklyProgressSum {
    final sum = widget.studentWeaklyProgress['sum'];
    if (sum is Map) {
      return Map<dynamic, dynamic>.from(sum);
    }
    return widget.studentWeaklyProgress;
  }

  List<Map<String, dynamic>> get _weeklyProgressTracks {
    final data = widget.studentWeaklyProgress['data'];
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  DateTime get _currentWeekStart {
    DateTime startWeekDate = DateTime.now();
    while (startWeekDate.weekday != DateTime.friday) {
      startWeekDate = startWeekDate.subtract(const Duration(days: 1));
    }
    return startWeekDate;
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  String _attendanceText(StudentDailyTrackModel track) {
    if (track.withOrder == 1) {
      return 'غائب بإذن';
    }
    if (track.withoutOrder == 1) {
      return 'غائب';
    }
    return 'حاضر';
  }

  String _quranProgressText(List<Progress> progress) {
    if (progress.isEmpty) {
      return 'لا يوجد حفظ';
    }

    return progress
        .map((item) {
          final partName = item.name.trim().isEmpty ? 'قرآن' : item.name;
          final pageNumbers = item.pageNumbers.isEmpty
              ? ''
              : ' (${item.pageNumbers.join(', ')})';
          return '$partName: ${item.pagesNum} صفحة$pageNumbers';
        })
        .join('\n');
  }

  Widget _buildWeeklyMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 126.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.appBarColor.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brownColor, size: 18.sp),
          SizedBox(height: 7.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.darkBrownColor,
              fontSize: 16.sp,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.greyBrownColor,
              fontSize: 11.sp,
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInfoRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76.w,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.greyBrownColor,
                fontSize: 11.sp,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.darkBrownColor,
                fontSize: 12.sp,
                height: 1.45,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrackCard(Map<String, dynamic> trackData) {
    final track = StudentDailyTrackModel.fromJson(trackData);
    final rankLevel = _stringValue(trackData['rankLevel']);
    final rankValue = [
      if (track.rankValue.isNotEmpty) track.rankValue,
      if (track.rankPercent != null) '${track.rankPercent}%',
    ].join(' - ');
    final quranPages = track.quranProgress.fold<int>(
      0,
      (sum, item) => sum + item.pagesNum,
    );

    return Container(
      width: 291.w,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.sp),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.appBarColor,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Text(
                    _attendanceText(track),
                    style: TextStyle(
                      color: AppColors.brownColor,
                      fontSize: 10.sp,
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  track.date.toCustomString(),
                  style: TextStyle(
                    color: AppColors.darkBrownColor,
                    fontSize: 13.sp,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            _buildWeeklyInfoRow('الحلقة', track.className),
            _buildWeeklyInfoRow(
              'قرآن',
              _quranProgressText(track.quranProgress),
            ),
            _buildWeeklyInfoRow('عدد الصفحات', '$quranPages صفحة'),
            _buildWeeklyInfoRow('النقاط', track.pointsCount.toString()),
            _buildWeeklyInfoRow('التقييم', rankValue),
            _buildWeeklyInfoRow('الترتيب', rankLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressContent() {
    final sum = _weeklyProgressSum;
    final tracks = _weeklyProgressTracks;
    final startDate = _currentWeekStart;
    final endDate = DateTime.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            width: 291.w,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.sp),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محصلة الأسبوع الحالي',
                  style: TextStyle(
                    color: AppColors.darkBrownColor,
                    fontSize: 16.sp,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${startDate.toCustomString()} - ${endDate.toCustomString()}',
                  style: TextStyle(
                    color: AppColors.greyBrownColor,
                    fontSize: 11.sp,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildWeeklyMetric(
                      icon: Icons.menu_book_outlined,
                      label: 'حفظ جديد (قرآن)',
                      value: '${_intValue(sum['quranNewPagesCount'])} صفحة',
                    ),
                    _buildWeeklyMetric(
                      icon: Icons.stars_outlined,
                      label: 'النقاط',
                      value: _intValue(
                        sum['points_count'] ?? sum['pointsCount'],
                      ).toString(),
                    ),
                    _buildWeeklyMetric(
                      icon: Icons.event_available_outlined,
                      label: 'أيام الدوام',
                      value: '${_intValue(sum['onDays'])} أيام',
                    ),
                    _buildWeeklyMetric(
                      icon: Icons.event_busy_outlined,
                      label: 'أيام الغياب',
                      value: '${_intValue(sum['offDays'])} أيام',
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            alignment: Alignment.centerRight,
            width: 291.w,
            child: Text(
              'تفاصيل الأيام',
              style: TextStyle(
                color: AppColors.brownColor,
                fontSize: 14.sp,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          tracks.isEmpty
              ? Container(
                  width: 291.w,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.sp),
                  ),
                  child: Text(
                    'لا توجد متابعات مسجلة لهذا الأسبوع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.greyBrownColor,
                      fontSize: 13.sp,
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : Column(children: tracks.map(_buildWeeklyTrackCard).toList()),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.brownBackgroundColor,
      endDrawer: RightDrawer(
        pageController: widget.pageController,
        scaffoldKey: _scaffoldKey,
        users: Constant.studentsAccount,
        items: [
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                await getStudentInfo(context);
                _scaffoldKey.currentState?.closeEndDrawer();
              }
            },
            text: 'الملف الشخصي',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                Constant.isThereLoading = true;
                int code = await getStudentGrades(context);
                _scaffoldKey.currentState?.closeEndDrawer();
                Constant.isThereLoading = false;
                if (code == 401) {
                  setState(() {});
                }
              }
            },
            text: 'الشهادات',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                Constant.isThereLoading = true;
                int? statusCode = await openAboutInstitutePage(
                  context: context,
                  scaffoldKey: _scaffoldKey,
                );
                Constant.isThereLoading = false;
                if ((statusCode == 405 || statusCode == 401) && mounted) {
                  setState(() {});
                }
              }
            },
            text: 'نبذة عن المعهد',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CommunicationPage()),
                );
              }
            },
            text: 'للتواصل',
          ),
          DrawerItem(
            textColor: const Color(0xffDE0000),
            onTap: () async {
              if (!Constant.isThereLoading) {
                Constant.isThereLoading = true;
                var res = await deleteStudentAccount(Constant.student!);
                Constant.studentsAccount = res;
                if (res.isEmpty) {
                  if (context.mounted) {
                    Constant.student = null;
                    _scaffoldKey.currentState!.closeEndDrawer();
                    setState(() {});
                  }
                } else {
                  _scaffoldKey.currentState!.closeEndDrawer();
                  widget.pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.linear,
                  );
                }
                Constant.isThereLoading = false;
              }
            },
            text: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: NotificationDrawer(
        onDrawerClosed: () async {
          await clearAllNotification();
          Constant.notifications = [];
          setState(() {});
        },
      ),
      body: Column(
        children: [
          HomepageAppBar(
            openNotificationDrawerDrawer: () async {
              if (Constant.notifications.isNotEmpty) {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            title: isWeaklyTrack ? 'محصلة الاسبوع' : 'المتابعة اليومية',
            openDrawer: () async {
              try {
                Constant.studentsAccount = await getStudentsAccount();
                if (!context.mounted) {
                  return;
                }
                if (Constant.student != null &&
                    Constant.studentsAccount.isNotEmpty) {
                  setState(() {});
                  _scaffoldKey.currentState?.openEndDrawer();
                } else {
                  showLoginRequiredDialog(context, () async {
                    final navigator = Navigator.of(context);
                    await navigator.push(
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                    );
                    if (!mounted) {
                      return;
                    }
                    setState(() {});
                  });
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),
          Expanded(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 12.h : 0),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: keyboardHeight > 0 ? 32.h : 16.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Constant.student != null
                        ? Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 65.h),
                                child: Column(
                                  children: [
                                    studentTrackModel != null
                                        ? isWeaklyTrack
                                              ? _buildWeeklyProgressContent()
                                              : studentTrackModel!.withOrder ==
                                                        1 ||
                                                    studentTrackModel!
                                                            .withoutOrder ==
                                                        1
                                              ? Column(
                                                  children: [
                                                    SizedBox(height: 20.h),
                                                    Image.asset(
                                                      'assets/images/warning.png',
                                                      width: 200.w,
                                                      height: 200.h,
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    Text(
                                                      'الطالب غير مداوم في هذا اليوم',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .brownColor,
                                                        fontSize: 40.sp,
                                                        fontFamily: 'Almarai',
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: isWeaklyTrack
                                                            ? 5
                                                            : 20.h,
                                                      ),
                                                      !isWeaklyTrack &&
                                                              studentTrackModel!
                                                                  .quranProject
                                                                  .isNotEmpty
                                                          ? Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 291.w,
                                                              height: 44.h,
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16.sp,
                                                                    ),
                                                                color: AppColors
                                                                    .appBarColor,
                                                              ),
                                                              child: Text(
                                                                'مشروع القرآن',
                                                                style: TextStyle(
                                                                  color: AppColors
                                                                      .lightBrownColor,
                                                                  fontSize:
                                                                      15.sp,
                                                                  fontFamily:
                                                                      'Almarai',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                      SizedBox(
                                                        height:
                                                            !isWeaklyTrack &&
                                                                studentTrackModel!
                                                                    .quranProject
                                                                    .isNotEmpty
                                                            ? 8.h
                                                            : 0,
                                                      ),
                                                      !isWeaklyTrack &&
                                                              studentTrackModel!
                                                                  .quranProject
                                                                  .isNotEmpty
                                                          ? Container(
                                                              width: 291.w,
                                                              height: 45.h,
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        15.w,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Color(
                                                                      0x0c000000,
                                                                    ),
                                                                    blurRadius:
                                                                        8,
                                                                    offset:
                                                                        Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ],
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16.sp,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                studentTrackModel!
                                                                    .quranProject
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  color: AppColors
                                                                      .darkBrownColor,
                                                                  fontSize:
                                                                      15.sp,
                                                                  fontFamily:
                                                                      'Almarai',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox.shrink(),
                                                      SizedBox(
                                                        height:
                                                            !isWeaklyTrack &&
                                                                studentTrackModel!
                                                                    .quranProject
                                                                    .isNotEmpty
                                                            ? 15.h
                                                            : 0,
                                                      ),
                                                      MonthlyProgressContainer(
                                                        width: 291.w,
                                                        data: studentTrackModel!
                                                            .quranProgress,
                                                        title: 'حفظ القرآن',
                                                        prefixItemText: 'صفحة',
                                                        prefixText:
                                                            'عدد الصفحات',
                                                      ),
                                                      SizedBox(height: 15.h),
                                                      studentTrackModel!
                                                              .quranVocabProgress
                                                              .isEmpty
                                                          ? SizedBox.shrink()
                                                          : Column(
                                                              children: [
                                                                MonthlyProgressContainer(
                                                                  width: 291.w,
                                                                  data: studentTrackModel!
                                                                      .quranVocabProgress,
                                                                  title:
                                                                      'مشروع أفلا يتدبرون القرآن',
                                                                  prefixItemText:
                                                                      'مفردة',
                                                                  prefixText:
                                                                      'عدد المفردات',
                                                                ),
                                                                SizedBox(
                                                                  height: 15.h,
                                                                ),
                                                              ],
                                                            ),
                                                      studentTrackModel!
                                                              .hadithProgress
                                                              .isEmpty
                                                          ? SizedBox.shrink()
                                                          : Column(
                                                              children: [
                                                                MonthlyProgressContainer(
                                                                  width: 291.w,
                                                                  data: studentTrackModel!
                                                                      .hadithProgress,
                                                                  prefixItemText:
                                                                      'حديث',
                                                                  prefixText:
                                                                      'عدد الأحاديث',
                                                                  title:
                                                                      'مشروع نضر الله امرأ سمع منا حديثا فبلغه',
                                                                ),
                                                                SizedBox(
                                                                  height: 15.h,
                                                                ),
                                                              ],
                                                            ),
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        width: 291.w,
                                                        height: 44.h,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16.sp,
                                                              ),
                                                          color: AppColors
                                                              .appBarColor,
                                                        ),
                                                        child: Text(
                                                          'النقاط',
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .lightBrownColor,
                                                            fontSize: 15.sp,
                                                            fontFamily:
                                                                'Almarai',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      Container(
                                                        width: 291.w,
                                                        height: 45.h,
                                                        alignment: Alignment
                                                            .centerRight,
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 15.w,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Color(
                                                                0x0c000000,
                                                              ),
                                                              blurRadius: 8,
                                                              offset: Offset(
                                                                0,
                                                                2,
                                                              ),
                                                            ),
                                                          ],
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16.sp,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              studentTrackModel!
                                                                  .pointsCount
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign.end,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .darkBrownColor,
                                                                fontSize: 15.sp,
                                                                fontFamily:
                                                                    'Almarai',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              'النقاط',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .darkBrownColor,
                                                                fontSize: 15.sp,
                                                                fontFamily:
                                                                    'Almarai',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.h),
                                                      studentTrackModel!
                                                                      .rankPercent ==
                                                                  null &&
                                                              studentTrackModel!
                                                                  .rankValue
                                                                  .isEmpty
                                                          ? SizedBox.shrink()
                                                          : Column(
                                                              children: [
                                                                Container(
                                                                  width: 291.w,
                                                                  height: 45.h,
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15.w,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(
                                                                          0x0c000000,
                                                                        ),
                                                                        blurRadius:
                                                                            8,
                                                                        offset:
                                                                            Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          16.sp,
                                                                        ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        '${studentTrackModel!.rankPercent ?? ''} ${studentTrackModel!.rankValue}'
                                                                            .trim(),
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.darkBrownColor,
                                                                          fontSize:
                                                                              15.sp,
                                                                          fontFamily:
                                                                              'Almarai',
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                      Spacer(),
                                                                      Text(
                                                                        'التقييم',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.darkBrownColor,
                                                                          fontSize:
                                                                              15.sp,
                                                                          fontFamily:
                                                                              'Almarai',
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8.h,
                                                                ),
                                                              ],
                                                            ),
                                                      isWeaklyTrack
                                                          ? Column(
                                                              children: [
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  width: 291.w,
                                                                  height: 44.h,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          16.sp,
                                                                        ),
                                                                    color: AppColors
                                                                        .appBarColor,
                                                                  ),
                                                                  child: Text(
                                                                    'ايام الدوام',
                                                                    style: TextStyle(
                                                                      color: AppColors
                                                                          .lightBrownColor,
                                                                      fontSize:
                                                                          15.sp,
                                                                      fontFamily:
                                                                          'Almarai',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8.h,
                                                                ),
                                                                Container(
                                                                  width: 291.w,
                                                                  height: 45.h,
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15.w,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Color(
                                                                          0x0c000000,
                                                                        ),
                                                                        blurRadius:
                                                                            8,
                                                                        offset:
                                                                            Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          16.sp,
                                                                        ),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        '${widget.studentWeaklyProgress['onDays']} أيام',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.darkBrownColor,
                                                                          fontSize:
                                                                              15.sp,
                                                                          fontFamily:
                                                                              'Almarai',
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                      Spacer(),
                                                                      Text(
                                                                        'ايام الدوام',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.darkBrownColor,
                                                                          fontSize:
                                                                              15.sp,
                                                                          fontFamily:
                                                                              'Almarai',
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : SizedBox.shrink(),
                                                      SizedBox(height: 16.h),
                                                      isWeaklyTrack
                                                          ? SizedBox.shrink()
                                                          : Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: 291.w,
                                                              height: 44.h,
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16.sp,
                                                                    ),
                                                                color: AppColors
                                                                    .appBarColor,
                                                              ),
                                                              child: Text(
                                                                'ملاحظات',
                                                                style: TextStyle(
                                                                  color: AppColors
                                                                      .lightBrownColor,
                                                                  fontSize:
                                                                      15.sp,
                                                                  fontFamily:
                                                                      'Almarai',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                            ),
                                                      SizedBox(height: 8.h),
                                                      isWeaklyTrack
                                                          ? SizedBox.shrink()
                                                          : Container(
                                                              width: 291.w,
                                                              height: 130.h,
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        15.w,
                                                                    vertical:
                                                                        15.h,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Color(
                                                                      0x0c000000,
                                                                    ),
                                                                    blurRadius:
                                                                        8,
                                                                    offset:
                                                                        Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ],
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      16.sp,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    studentTrackModel!
                                                                        .nots
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                      color: AppColors
                                                                          .darkBrownColor,
                                                                      fontSize:
                                                                          15.sp,
                                                                      fontFamily:
                                                                          'Almarai',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      SizedBox(height: 16.h),
                                                    ],
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
                                                'لا يوجد متابعة في هذا اليوم',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AppColors.brownColor,
                                                  fontSize: 40.sp,
                                                  fontFamily: 'Almarai',
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: StudentDailyTrackDateContainer(
                                  fullDateMode: true,
                                  withList: true,
                                  date: date,
                                  onTap: (p0) async {
                                    if (p0 != null) {
                                      if (p0.year > 0) {
                                        isWeaklyTrack = false;
                                        _selectDailyTrackForDate(p0);
                                      } else {
                                        isWeaklyTrack = true;
                                        studentTrackModel = StudentDailyTrackModel(
                                          id: null,
                                          date: date,
                                          withOrder: 0,
                                          withoutOrder: 0,
                                          quranProject: '',
                                          nots: '',
                                          behave: 0,
                                          pointsCount:
                                              _weeklyProgressSum['points_count'] ??
                                              _weeklyProgressSum['pointsCount'] ??
                                              0,
                                          rankPercent:
                                              _weeklyProgressSum['rankPercent'] ??
                                              _weeklyProgressSum['rank_percentage'],
                                          rankValue:
                                              _weeklyProgressSum['rankValue'] ??
                                              '',
                                          quranQuizCount:
                                              _weeklyProgressSum['quranQuizCount'] ??
                                              0,
                                          hadithQuizCount:
                                              _weeklyProgressSum['hadithQuizCount'] ??
                                              0,
                                          quranProgress: [
                                            Progress(
                                              name: '',
                                              pagesNum:
                                                  _weeklyProgressSum['quranNewPagesCount'] ??
                                                  0,
                                              pageNumbers: [],
                                            ),
                                          ],
                                          hadithProgress: [],
                                          quranVocabProgress: [],
                                          className: '',
                                        );
                                      }
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : LoginRequiredPage(
                            onLoginPress: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SplashScreen(),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    date = DateTime.now();
    studentTracks = widget.studentDailyTrack;
    if (studentTracks.isNotEmpty) {
      final firstTrack = studentTracks.first;
      if (firstTrack is Map) {
        studentTrackModel = StudentDailyTrackModel.fromJson(
          Map<String, dynamic>.from(firstTrack),
        );
        date = studentTrackModel!.date;
      }
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant StudentDailyTrackPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentDailyTrack == widget.studentDailyTrack) {
      return;
    }

    studentTracks = widget.studentDailyTrack;
    if (isWeaklyTrack) {
      return;
    }

    if (studentTrackModel == null && studentTracks.isNotEmpty) {
      final firstTrack = studentTracks.first;
      if (firstTrack is Map) {
        studentTrackModel = StudentDailyTrackModel.fromJson(
          Map<String, dynamic>.from(firstTrack),
        );
        date = studentTrackModel!.date;
      }
    } else {
      _selectDailyTrackForDate(date);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
