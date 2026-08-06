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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                await getStudentDonations(context);
                _scaffoldKey.currentState!.closeEndDrawer();
                Constant.isThereLoading = false;
              }
            },
            text: 'التبرعات',
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
                if (Constant.student != null &&
                    Constant.studentsAccount.isNotEmpty) {
                  setState(() {});
                  _scaffoldKey.currentState?.openEndDrawer();
                } else {
                  showLoginRequiredDialog(context, () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                    );
                    setState(() {});
                  });
                }
              } catch (e) {
                log(e.toString());
              }
            },
          ),
          SizedBox(
            height: 550.h,
            child: SingleChildScrollView(
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
                                      ? studentTrackModel!.withOrder == 1 ||
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
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          AppColors.brownColor,
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
                                                    isWeaklyTrack
                                                        ? SizedBox.shrink()
                                                        : Container(
                                                            alignment: Alignment
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
                                                                fontSize: 15.sp,
                                                                fontFamily:
                                                                    'Almarai',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                    SizedBox(
                                                      height: isWeaklyTrack
                                                          ? 0
                                                          : 8.h,
                                                    ),
                                                    isWeaklyTrack
                                                        ? SizedBox.shrink()
                                                        : Container(
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
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                              color:
                                                                  Colors.white,
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
                                                          ),
                                                    SizedBox(
                                                      height: isWeaklyTrack
                                                          ? 0
                                                          : 15.h,
                                                    ),
                                                    MonthlyProgressContainer(
                                                      width: 291.w,
                                                      data: studentTrackModel!
                                                          .quranProgress,
                                                      title: 'حفظ القرآن',
                                                      prefixItemText: 'صفحة',
                                                      prefixText: 'عدد الصفحات',
                                                    ),
                                                    SizedBox(height: 15.h),
                                                    MonthlyProgressContainer(
                                                      width: 291.w,
                                                      data: studentTrackModel!
                                                          .quranVocabProgress,
                                                      title:
                                                          'مشروع أفلا يتدبرون القرآن',
                                                      prefixItemText: 'مفردة',

                                                      prefixText:
                                                          'عدد المفردات',
                                                    ),
                                                    SizedBox(height: 15.h),
                                                    MonthlyProgressContainer(
                                                      width: 291.w,
                                                      data: studentTrackModel!
                                                          .hadithProgress,
                                                      prefixItemText: 'حديث',
                                                      prefixText:
                                                          'عدد الأحاديث',
                                                      title:
                                                          'مشروع نضر الله امرأ سمع منا حديثا فبلغه',
                                                    ),
                                                    SizedBox(height: 15.h),
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
                                                        'السلوك',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .lightBrownColor,
                                                          fontSize: 15.sp,
                                                          fontFamily: 'Almarai',
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.h),
                                                    Container(
                                                      width: 291.w,
                                                      height: 45.h,
                                                      alignment:
                                                          Alignment.centerRight,
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
                                                                .behave
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
                                                            'السلوك',
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
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      '${widget.studentWeaklyProgress['onDays']} أيام',
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
                                                                            FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                    Spacer(),
                                                                    Text(
                                                                      'ايام الدوام',
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
                                                            alignment: Alignment
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
                                                                fontSize: 15.sp,
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
                                                            alignment: Alignment
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
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      Offset(
                                                                        0,
                                                                        2,
                                                                      ),
                                                                ),
                                                              ],
                                                              color:
                                                                  Colors.white,
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
                                      date = p0;
                                      List item = studentTracks
                                          .where(
                                            (element) =>
                                                element['trackDate'] ==
                                                date.toCustomString(),
                                          )
                                          .toList();
                                      if (item.isNotEmpty) {
                                        studentTrackModel =
                                            StudentDailyTrackModel.fromJson(
                                              item.first,
                                            );
                                      } else {
                                        studentTrackModel = null;
                                      }
                                    } else {
                                      isWeaklyTrack = true;
                                      studentTrackModel = StudentDailyTrackModel(
                                        date: date,
                                        withOrder: 0,
                                        withoutOrder: 0,
                                        quranProject: '',
                                        nots: '',
                                        behave: widget
                                            .studentWeaklyProgress['behave'],
                                        quranQuizCount:
                                            widget
                                                .studentWeaklyProgress['quranQuizCount'] ??
                                            0,
                                        hadithQuizCount:
                                            widget
                                                .studentWeaklyProgress['hadithQuizCount'] ??
                                            0,
                                        quranProgress: [
                                          Progress(
                                            name: '',
                                            pagesNum: widget
                                                .studentWeaklyProgress['quranNewPagesCount'],
                                          ),
                                        ],
                                        hadithProgress: [
                                          Progress(
                                            name: '',
                                            pagesNum: widget
                                                .studentWeaklyProgress['hadithNewPagesCount'],
                                          ),
                                        ],
                                        quranVocabProgress: [
                                          Progress(
                                            name: '',
                                            pagesNum: widget
                                                .studentWeaklyProgress['quranVocabPagesCount'],
                                          ),
                                        ],
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
        ],
      ),
    );
  }

  @override
  void initState() {
    date = DateTime.now();
    studentTracks = widget.studentDailyTrack;
    if (studentTracks.isNotEmpty) {
      studentTrackModel = StudentDailyTrackModel.fromJson(studentTracks.first);
      date = studentTrackModel!.date;
    }
    super.initState();
  }
}
