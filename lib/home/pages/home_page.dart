import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

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
import 'about_institute.dart';
import 'communication_page.dart';
import 'login_required_page.dart';

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

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    try {
      getImages = getAdvertingImages();
    } catch (e) {}
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
          bool isDonationLoading = false;
          bool isPersonalFileLoading = false;
          if (state is DonationPageOpened) {
            if (!Constant.isThereLoading) {
              _scaffoldKey.currentState!.openEndDrawer();
              Constant.isThereLoading = true;
              isDonationLoading = true;
              getStudentDonations(context).then((value) {
                _scaffoldKey.currentState!.closeEndDrawer();
                Constant.isThereLoading = false;
                isDonationLoading = false;
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
              checkInternet(() async {
                http.Response res = await http.get(
                  Uri.parse(Constant.getAboutText),
                  headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json",
                    "Authorization":
                        "Bearer ${await (getToken(Constant.student!.id.toString()))}",
                  },
                );
                if (res.statusCode == 200) {
                  isAboutInstituteLoading = false;
                  Constant.isThereLoading = false;
                  context.read<HomeBloc>().add(InitEvent());
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutInstitute(
                        aboutText: jsonDecode(res.body)['text'],
                      ),
                    ),
                  );
                  _scaffoldKey.currentState!.closeEndDrawer();
                } else if (res.statusCode == 405 || res.statusCode == 401) {
                  await removeUnauthorizedUser();
                } else {
                  isAboutInstituteLoading = false;
                  Constant.isThereLoading = false;
                  context.read<HomeBloc>().add(InitEvent());
                  ToastContext().init(context);
                  Toast.show(
                    'خطأ غير معروف حاول ثانية',
                    duration: Toast.lengthLong,
                  );
                }
              }, context);
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
                isLoading: isDonationLoading,
                onTap: () async {
                  if (!Constant.isThereLoading) {
                    Constant.isThereLoading = true;
                    int code = await getStudentDonations(context);
                    _scaffoldKey.currentState!.closeEndDrawer();
                    Constant.isThereLoading = false;
                    if (code == 401) {
                      setState(() {});
                    }
                  }
                },
                text: 'التبرعات',
              ),
              DrawerItem(
                onTap: () async {
                  if (!Constant.isThereLoading) {
                    await checkInternet(() async {
                      http.Response res = await http.get(
                        Uri.parse(Constant.getAboutText),
                        headers: {
                          "Content-Type": "application/json",
                          "Accept": "application/json",
                          "Authorization":
                              "Bearer ${await (getToken(Constant.student!.id.toString()))}",
                        },
                      );
                      if (res.statusCode == 200) {
                        isAboutInstituteLoading = false;
                        Constant.isThereLoading = false;
                        context.read<HomeBloc>().add(InitEvent());
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AboutInstitute(
                              aboutText: jsonDecode(res.body)['text'],
                            ),
                          ),
                        );
                        _scaffoldKey.currentState!.closeEndDrawer();
                      } else if (res.statusCode == 405 ||
                          res.statusCode == 401) {
                        await removeUnauthorizedUser();
                        setState(() {});
                      } else {
                        isAboutInstituteLoading = false;
                        Constant.isThereLoading = false;
                        context.read<HomeBloc>().add(InitEvent());
                        ToastContext().init(context);
                        Toast.show(
                          'خطأ غير معروف حاول ثانية',
                          duration: Toast.lengthLong,
                        );
                      }
                    }, context);
                  }
                },
                text: 'نبذة عن المعهد',
              ),
              DrawerItem(
                isLoading: isAboutInstituteLoading,
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
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Constant.student != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 15.h),
                      Text(
                        '${Constant.student!.fName} ${Constant.student!.lName}',
                        style: TextStyle(
                          color: AppColors.brownColor,
                          fontSize: 18.sp,
                          fontFamily: 'Almarai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 25.h,
                        child: Constant.student!.className.isEmpty
                            ? SizedBox.shrink()
                            : Text(
                                'حلقة ${Constant.student!.className}',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.brownColor,
                                  fontSize: 15.sp,
                                  fontFamily: 'Almarai',
                                ),
                              ),
                      ),
                      SizedBox(height: 15.h),
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
                                      height: 120.h,
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
                                                    (context, url, error) =>
                                                        Center(
                                                          child: Text(
                                                            textAlign: TextAlign
                                                                .center,
                                                            error.toString(),
                                                          ),
                                                        ),
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
                      SizedBox(height: 15.h),
                      Container(
                        width: 291.w,
                        height: 54.h,
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
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.star,
                              color: Color(0xffF6E862),
                              size: 25.sp,
                            ),
                            SizedBox(width: 16.w),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        width: 300.w,
                        height: 215.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
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
                                    return HomePageButton(
                                      width: 55.w,
                                      height: 55.h,
                                      isLoading: isLoading,
                                      iconData: Mnb.task_square,
                                      backgroundColor: Color(0xffA58774),
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
                                SizedBox(width: 15.w),
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    bool isLoading = false;
                                    if (state is AwqafTestPageOpened) {
                                      if (!Constant.isThereLoading) {
                                        Constant.isThereLoading = true;
                                        isLoading = true;
                                        getStudentTest(
                                          context: context,
                                          testType: 'أوقاف',
                                          date: state.date,
                                        ).then((value) {
                                          isLoading = false;
                                          Constant.isThereLoading = false;
                                          context.read<HomeBloc>().add(
                                            InitEvent(),
                                          );
                                        });
                                      }
                                    }
                                    return HomePageButton(
                                      width: 60.w,
                                      height: 60.h,
                                      iconData: Mnb.award,
                                      backgroundColor: Color(0xffA58774),
                                      isLoading: isLoading,
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
                                    );
                                  },
                                ),
                                SizedBox(width: 15.w),
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    bool isLoading = false;
                                    if (state is CourseTestPageOpened) {
                                      if (!Constant.isThereLoading) {
                                        Constant.isThereLoading = true;
                                        isLoading = true;
                                        getStudentTest(
                                          context: context,
                                          testType: 'منهج',
                                        ).then((value) {
                                          isLoading = false;
                                          Constant.isThereLoading = false;
                                          context.read<HomeBloc>().add(
                                            InitEvent(),
                                          );
                                        });
                                      }
                                    }
                                    return HomePageButton(
                                      width: 60.w,
                                      height: 60.h,
                                      isLoading: isLoading,
                                      iconData: Mnb.teacher,
                                      backgroundColor: Color(0xffA58774),
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
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    bool isLoading = false;
                                    if (state is GradesPageOpened) {
                                      if (!Constant.isThereLoading) {
                                        Constant.isThereLoading = true;
                                        isLoading = true;
                                        getStudentGrades(context).then((value) {
                                          isLoading = false;
                                          Constant.isThereLoading = false;
                                          context.read<HomeBloc>().add(
                                            InitEvent(),
                                          );
                                        });
                                      }
                                    }
                                    return HomePageButton(
                                      width: 60.w,
                                      height: 60.h,
                                      iconData: Mnb.medal,
                                      isLoading: isLoading,
                                      backgroundColor: Color(0xffA58774),
                                      onTap: () async {
                                        if (!Constant.isThereLoading) {
                                          Constant.isThereLoading = true;
                                          int code = await getStudentGrades(
                                            context,
                                          );
                                          Constant.isThereLoading = false;
                                          if (code == 401) {
                                            setState(() {});
                                          }
                                        }
                                      },
                                      text: 'الشهادات',
                                    );
                                  },
                                ),
                                SizedBox(width: 15.w),
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
                                    return HomePageButton(
                                      width: 60.w,
                                      height: 60.h,
                                      isLoading: isLoading,
                                      iconData: Mnb.message,
                                      backgroundColor: Color(0xffA58774),
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
                                SizedBox(width: 15.w),
                                HomePageButton(
                                  width: 60.w,
                                  height: 60.h,
                                  iconData: Mnb.calendar,
                                  backgroundColor: Color(0xffA58774),
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
