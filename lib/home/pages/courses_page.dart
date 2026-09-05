import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/pages/splash_screen.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../bloc/home_bloc.dart';
import '../methods/home_page_methods.dart';
import '../models/file_collection.dart';
import '../widgets/drawer.dart';
import '../widgets/home_page_app_bar.dart';
import '../widgets/widgets.dart';
import 'collection_content.dart';
import 'communication_page.dart';

class CoursesPage extends StatefulWidget {
  final List courses;
  final PageController pageController;
  const CoursesPage({
    super.key,
    required this.pageController,
    required this.courses,
  });

  @override
  State<CoursesPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<CoursesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List courses = [];
  @override
  void initState() {
    courses = widget.courses;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (Navigator.of(context).canPop()) {
            var files = await getFiles('كورسات');
            Navigator.of(context).pop(files);
          }
        },
        child: Scaffold(
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
                    int code = await getStudentTest(
                      context: context,
                      testType: 'أوقاف',
                    );
                    _scaffoldKey.currentState?.closeEndDrawer();
                    Constant.isThereLoading = false;
                    if (code == 401) {
                      setState(() {});
                    }
                  }
                },
                text: 'سبر الأوقاف',
              ),
              DrawerItem(
                onTap: () async {
                  if (!Constant.isThereLoading) {
                    Constant.isThereLoading = true;
                    int code = await getStudentTest(
                      context: context,
                      testType: 'منهج',
                    );
                    _scaffoldKey.currentState?.closeEndDrawer();
                    Constant.isThereLoading = false;
                    if (code == 401) {
                      setState(() {});
                    }
                  }
                },
                text: 'علامات المنهج',
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommunicationPage(),
                      ),
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
          drawerScrimColor: const Color(0x3f000000),
          body: SingleChildScrollView(
            child: Column(
              children: [
                HomepageAppBar(
                  openNotificationDrawerDrawer: () async {
                    if (Constant.notifications.isNotEmpty) {
                      _scaffoldKey.currentState?.openDrawer();
                    }
                  },
                  title: 'الدروس العلمية',
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
                            MaterialPageRoute(
                              builder: (context) => SplashScreen(),
                            ),
                          );
                          setState(() {});
                        });
                      }
                    } catch (e) {
                      log(e.toString());
                    }
                  },
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      LibraryCustomContainer(
                        titleTextColor: AppColors.brownColor,
                        titleBackgroundColor: AppColors.brownColor1,
                        content: List.generate(courses.length, (index) {
                          FileCollectionModel fileCollection =
                              FileCollectionModel.fromJson(courses[index]);
                          return LibraryCustomContainerItem(
                            text: fileCollection.name,
                            icon: Icons.video_library,
                            onTap: () async {
                              List? audiosRes = await Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => CollectionContent(
                                        pageTitle: 'الدروس العلمية',
                                        content: courses,
                                        selectedCollection: fileCollection,
                                      ),
                                    ),
                                  );
                              if (audiosRes != null) {
                                courses = audiosRes;
                                setState(() {});
                              }
                            },
                          );
                        }),
                        title: 'الدروس العلمية',
                        width: 280.w,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
