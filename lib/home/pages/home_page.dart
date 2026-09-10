import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/pages/splash_screen.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';
import '../bloc/home_bloc.dart';
import '../methods/home_page_methods.dart';
import '../widgets/drawer.dart';
import '../widgets/home_page_app_bar.dart';
import '../widgets/widgets.dart';
import 'add_student_prays_page.dart';
import 'communication_page.dart';
import 'login_required_page.dart';
import 'student_homeworks_page.dart';
import 'student_institute_actions_page.dart';

class HomePage extends StatefulWidget {
  final PageController pageController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HomePage({
    super.key,
    required this.pageController,
    required this.scaffoldKey,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GlobalKey<ScaffoldState> _scaffoldKey;
  bool isDrawerOpened = false;
  late Future getImages;
  int selectedImageIndex = 0;
  StreamController<int> streamController = StreamController<int>.broadcast();
  late Sink<int> sink;
  late Stream<int> stream;
  int maxImageLen = 0;
  bool isAboutInstituteLoading = false;

  Widget _buildHomeActionButton({
    required String text,
    required IconData iconData,
    required Future<void> Function() onTap,
    bool isLoading = false,
  }) {
    return HomePageButton(
      width: 42.w,
      height: 42.h,
      labelWidth: 68.w,
      labelHeight: 30.h,
      labelFontSize: 10.5,
      iconSize: 19,
      gap: 3,
      isLoading: isLoading,
      iconData: iconData,
      backgroundColor: AppColors.green2,
      onTap: onTap,
      text: text,
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    try {
      getImages = getAdvertingImages();
    } catch (_) {}
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _scaffoldKey = widget.scaffoldKey;
    sink = streamController.sink;
    stream = streamController.stream;
    getImages = getAdvertingImages();
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (selectedImageIndex == maxImageLen) {
        selectedImageIndex = 0;
      } else {
        selectedImageIndex++;
      }
      if (maxImageLen > 0) {
        sink.add(selectedImageIndex);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) {
          setState(() {});
        }
      },
      endDrawer: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          bool isPersonalFileLoading = false;
          if (state is DonationPageOpened) {
            if (!Constant.isThereLoading) {
              _scaffoldKey.currentState!.openEndDrawer();
              Constant.isThereLoading = true;
              getStudentDonations(context).then((value) {
                _scaffoldKey.currentState!.closeEndDrawer();
                Constant.isThereLoading = false;
                context.read<HomeBloc>().add(InitEvent());
              });
            }
          } else if (state is PersonalPageOpened) {
            if (!Constant.isThereLoading) {
              _scaffoldKey.currentState!.openEndDrawer();
              Constant.isThereLoading = true;
              isPersonalFileLoading = true;
              getStudentInfo(context).then((value) {
                _scaffoldKey.currentState!.closeEndDrawer();
                Constant.isThereLoading = false;
                isPersonalFileLoading = false;
                context.read<HomeBloc>().add(InitEvent());
              });
            }
          } else if (state is AboutInstitutePageOpened) {
            if (!Constant.isThereLoading) {
              _scaffoldKey.currentState!.openEndDrawer();
              Constant.isThereLoading = true;
              isAboutInstituteLoading = true;
              openAboutInstitutePage(
                context: context,
                scaffoldKey: _scaffoldKey,
              ).then((statusCode) {
                if (!mounted) {
                  return;
                }
                isAboutInstituteLoading = false;
                Constant.isThereLoading = false;
                context.read<HomeBloc>().add(InitEvent());
                if (statusCode == 405 || statusCode == 401) {
                  setState(() {});
                }
              });
            }
          }
          return RightDrawer(
            pageController: widget.pageController,
            scaffoldKey: _scaffoldKey,
            users: Constant.studentsAccount,
            items: [
              DrawerItem(
                isLoading: isPersonalFileLoading,
                onTap: () async {
                  if (!Constant.isThereLoading) {
                    int code = await getStudentInfo(context);
                    _scaffoldKey.currentState?.closeEndDrawer();
                    if (code == 401) {
                      setState(() {});
                    }
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
                isLoading: isAboutInstituteLoading,
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
                    bool isSuccess = await logout(
                      id: Constant.student!.id,
                      context: context,
                    );
                    if (isSuccess) {
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
                    }
                    setState(() {});
                    Constant.isThereLoading = false;
                  }
                },
                text: 'تسجيل الخروج',
              ),
            ],
          );
        },
      ),
      drawer: NotificationDrawer(
        onDrawerClosed: () async {
          await clearAllNotification();
          Constant.notifications = [];
          setState(() {});
        },
      ),
      drawerScrimColor: const Color(0x3f000000),
      key: _scaffoldKey,
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          HomepageAppBar(
            title: 'الرئيسية',
            openNotificationDrawerDrawer: () async {
              if (Constant.notifications.isNotEmpty) {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Constant.student != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        '${Constant.student!.fName} ${Constant.student!.lName}',
                        style: TextStyle(
                          color: AppColors.brownColor,
                          fontSize: 16.sp,
                          fontFamily: 'Almarai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        height: 21.h,
                        child: Constant.student!.className.isEmpty
                            ? SizedBox.shrink()
                            : Text(
                                'حلقة ${Constant.student!.className}',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.brownColor,
                                  fontSize: 13.sp,
                                  fontFamily: 'Almarai',
                                ),
                              ),
                      ),
                      SizedBox(height: 10.h),
                      FutureBuilder(
                        future: getImages,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            maxImageLen = snapshot.data.length - 1;
                          }
                          return snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? CircularProgressIndicator()
                              : snapshot.hasData
                              ? StreamBuilder(
                                  builder: (context, data) {
                                    return Container(
                                      width: 275.w,
                                      height: 130.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffEBEBEB),
                                        borderRadius: BorderRadius.circular(
                                          20.sp,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          20.sp,
                                        ),
                                        child: snapshot.data.isEmpty
                                            ? Center(
                                                child: Text(
                                                  'لا يوجد إعلانات',
                                                  style: TextStyle(
                                                    fontFamily: 'Almarai',
                                                    fontSize: 20.sp,
                                                    color: AppColors.brownColor,
                                                  ),
                                                ),
                                              )
                                            : CachedNetworkImage(
                                                progressIndicatorBuilder:
                                                    (
                                                      context,
                                                      url,
                                                      progress,
                                                    ) => Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Color(
                                                              0xff008E99,
                                                            ),
                                                            value: progress
                                                                .progress,
                                                          ),
                                                    ),
                                                fit: BoxFit.fill,
                                                errorWidget:
                                                    (context, url, error) {
                                                      log(error.toString());
                                                      return Center(
                                                        child: Text(
                                                          textAlign:
                                                              TextAlign.center,
                                                          error.toString(),
                                                        ),
                                                      );
                                                    },
                                                imageUrl:
                                                    selectedImageIndex >=
                                                        snapshot.data.length
                                                    ? snapshot.data.last
                                                    : snapshot
                                                          .data[selectedImageIndex]
                                                          .toString()
                                                          .replaceAll(
                                                            'http://localhost:8000',
                                                            'http://10.0.2.2:8000',
                                                          ),
                                              ),
                                      ),
                                    );
                                  },
                                  stream: stream,
                                )
                              : IconButton(
                                  onPressed: () {
                                    getImages = getAdvertingImages();
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.replay),
                                );
                        },
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 291.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x05000000),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              ' ${Constant.student?.classStudentCount} / ${Constant.student?.rankLevel}   ترتيب الطالب على حلقته',
                              style: TextStyle(
                                color: AppColors.brownColor,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Almarai',
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.star,
                              color: Color(0xffF6E862),
                              size: 22.sp,
                            ),
                            SizedBox(width: 14.w),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: 300.w,
                        height: 270.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    bool isLoading = false;
                                    if (state is LocalTestPageOpened) {
                                      if (!Constant.isThereLoading) {
                                        Constant.isThereLoading = true;
                                        isLoading = true;
                                        getStudentTest(
                                          context: context,
                                          testType: 'محلي',
                                        ).then((value) {
                                          isLoading = false;
                                          Constant.isThereLoading = false;
                                          context.read<HomeBloc>().add(
                                            InitEvent(),
                                          );
                                        });
                                      }
                                    }
                                    return _buildHomeActionButton(
                                      isLoading: isLoading,
                                      iconData: Mnb.task_square,
                                      onTap: () async {
                                        if (!Constant.isThereLoading) {
                                          Constant.isThereLoading = true;
                                          int statusCode = await getStudentTest(
                                            context: context,
                                            testType: 'محلي',
                                          );
                                          if (statusCode == 401) {
                                            setState(() {});
                                          }
                                          Constant.isThereLoading = false;
                                        }
                                      },
                                      text: 'الاختبارات',
                                    );
                                  },
                                ),
                                _buildHomeActionButton(
                                  iconData: Icons.task_alt_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      int code = await getStudentTest(
                                        context: context,
                                        testType: 'أوقاف',
                                      );
                                      if (code == 401) {
                                        setState(() {});
                                      }
                                      Constant.isThereLoading = false;
                                    }
                                  },
                                  text: 'سبر الأوقاف',
                                ),
                                _buildHomeActionButton(
                                  iconData: Icons.menu_book_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      int code = await getStudentTest(
                                        context: context,
                                        testType: 'منهج',
                                      );
                                      if (code == 401) {
                                        setState(() {});
                                      }
                                      Constant.isThereLoading = false;
                                    }
                                  },
                                  text: 'علامات المنهج',
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildHomeActionButton(
                                  iconData: Icons.home_work_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StudentHomeworksPage(),
                                        ),
                                      );
                                      Constant.isThereLoading = false;
                                      setState(() {});
                                    }
                                  },
                                  text: 'التعاهد المنزلي',
                                ),
                                _buildHomeActionButton(
                                  iconData: Icons.volunteer_activism_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      int code = await getStudentDonations(
                                        context,
                                      );
                                      Constant.isThereLoading = false;
                                      if (code == 401) {
                                        setState(() {});
                                      }
                                    }
                                  },
                                  text: 'التبرعات',
                                ),
                                _buildHomeActionButton(
                                  iconData: Icons.fact_check_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AddStudentPraysPage(),
                                        ),
                                      );
                                      Constant.isThereLoading = false;
                                      setState(() {});
                                    }
                                  },
                                  text: 'الصلوات',
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildHomeActionButton(
                                  iconData: Icons.event_available_outlined,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StudentInstituteActionsPage(),
                                        ),
                                      );
                                      Constant.isThereLoading = false;
                                      setState(() {});
                                    }
                                  },
                                  text: 'نشاطات المعهد',
                                ),
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    bool isLoading = false;
                                    if (state is RecallsPageOpened) {
                                      if (!Constant.isThereLoading) {
                                        Constant.isThereLoading = true;
                                        isLoading = true;
                                        getStudentRecalls(context).then((
                                          value,
                                        ) {
                                          isLoading = false;
                                          Constant.isThereLoading = false;
                                          context.read<HomeBloc>().add(
                                            InitEvent(),
                                          );
                                        });
                                      }
                                    }
                                    return _buildHomeActionButton(
                                      isLoading: isLoading,
                                      iconData: Mnb.message,
                                      onTap: () async {
                                        if (!Constant.isThereLoading) {
                                          Constant.isThereLoading = true;
                                          int code = await getStudentRecalls(
                                            context,
                                          );
                                          if (code == 401) {
                                            setState(() {});
                                          }
                                          Constant.isThereLoading = false;
                                        }
                                      },
                                      text: 'الاستدعاءات',
                                    );
                                  },
                                ),
                                _buildHomeActionButton(
                                  iconData: Mnb.calendar,
                                  onTap: () async {
                                    if (!Constant.isThereLoading) {
                                      Constant.isThereLoading = true;
                                      int code =
                                          await getStudentMonthlyProgress(
                                            context,
                                          );
                                      if (code == 401) {
                                        setState(() {});
                                      }
                                      Constant.isThereLoading = false;
                                    }
                                  },
                                  text: 'الانجاز الشهري',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : LoginRequiredPage(
                    onLoginPress: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                      );
                      setState(() {});
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
