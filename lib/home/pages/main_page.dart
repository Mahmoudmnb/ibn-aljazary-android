import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toast/toast.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/models/student_model.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';
import '../../main.dart';
import '../bloc/home_bloc.dart';
import '../methods/home_page_methods.dart';
import '../models/app_notification.dart';
import '../widgets/widgets.dart';
import 'courses_page.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'student_daily_track_page.dart';

class MainPage extends StatefulWidget {
  final StudentModel? student;
  const MainPage({super.key, this.student});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PageController pageController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List studentDailyTrack = [];
  Map studentWeaklyTrack = {};
  List books = [];
  List audios = [];
  List courses = [];

  handleMessageClick(RemoteMessage message) async {
    await removeNotification(
      AppNotification(
        body: message.notification?.body ?? '',
        id: message.messageId.toString(),
        title: message.notification?.title ?? '',
      ),
    );
    Constant.notifications.removeWhere(
      (element) => element.id.toString() == message.messageId.toString(),
    );
    try {
      for (;;) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          break;
        }
      }

      if (message.data['page'] == 'أوقاف') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenAwqafTestPage(date: ''));
      } else if (message.data['page'] == 'محلي') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenLocalTestPage());
      } else if (message.data['page'] == 'منهج') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenCourseTestPage());
      } else if (message.data['page'] == 'شهادة') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenGradesPage());
      } else if (message.data['page'] == 'استدعاء') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenRecallsPage());
      } else if (message.data['page'] == 'المتابعة اليومية') {
        context.read<HomeBloc>().add(OpenDailyTrackPage());
      } else if (message.data['page'] == 'صوتيات' ||
          message.data['page'] == 'كتب') {
        context.read<HomeBloc>().add(OpenBookAudioPage());
      } else if (message.data['page'] == 'الدروس العلمية') {
        context.read<HomeBloc>().add(OpenVideosPage());
      } else if (message.data['page'] == 'advertingImage') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        setState(() {});
      } else if (message.data['page'] == 'aboutInstitute') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        _scaffoldKey.currentState!.openEndDrawer();
        context.read<HomeBloc>().add(OpenAboutInstitutePage());
      } else if (message.data['page'] == 'donation') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        _scaffoldKey.currentState?.openEndDrawer();
        context.read<HomeBloc>().add(OpenDonationPage());
      } else if (message.data['page'] == 'profile') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
      } else if (message.data['page'] == 'student_ranking') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        context.read<HomeBloc>().add(OpenStudentRankingPage());
        setState(() {});
      }

      if (message.data['studentId'] != null) {
        List students = await getStudentsAccount();
        for (var element in students) {
          if (jsonDecode(element['data'])['id'].toString() ==
              message.data['studentId'].toString()) {
            Constant.student = StudentModel.fromMap(
              jsonDecode(element['data']),
            );
            await setCurrentUser(Constant.student!);
            break;
          }
        }
      }
    } catch (e) {
      log('handel error :' + e.toString());
    }
  }

  void initNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await addNotification(
        AppNotification(
          body: message.notification?.body ?? '',
          id: message.messageId.toString(),
          title: message.notification?.title ?? '',
        ),
      );
      Constant.notifications.add(
        AppNotification(
          body: message.notification?.body ?? '',
          id: message.messageId.toString(),
          title: message.notification?.title ?? '',
        ),
      );
      await handelMessageArrive(message);
      if ((message.data['page'] == 'صوتيات' ||
              message.data['page'] == 'كتب' ||
              message.data['page'] == 'الدروس العلمية') &&
          (message.data['type'] != 'file' ||
              message.data['method'] == 'delete')) {
        //* don't show notification for collection methods or delete in files
      } else if ((message.data['page'] == 'profile' &&
          message.data['show'] == 'false')) {
        //* don't show notification for update user name
      } else {
        const rtl = '\u200F'; // Right-To-Left Mark

        await flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          '$rtl${message.notification?.title ?? ''}',
          '$rtl${message.notification?.body ?? ''}',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'channelId',
              'channelName',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode({'id': message.messageId, 'data': message.data}),
        );

        if (message.data['page'] == 'advertingImage' ||
            message.data['page'] == 'profile' ||
            message.data['page'] == 'student_ranking') {
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        await handleMessageClick(
          RemoteMessage(
            data: jsonDecode(details.payload ?? '')['data'],
            messageId: jsonDecode(details.payload ?? '')['id'],
          ),
        );
      },
    );
    initNotifications();

    // When app is in background and user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await handleMessageClick(message);
    });

    // When app is terminated and opened from a notification
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        await handleMessageClick(message);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (pageController.page! > 0) {
            if (!Constant.isThereLoading) {
              pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.linear,
              );
            }
          } else {
            exit(1);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.brownBackgroundColor,
          body: PageView(
            controller: pageController,
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              HomePage(
                pageController: pageController,
                scaffoldKey: _scaffoldKey,
              ),
              StudentDailyTrackPage(
                studentDailyTrack: studentDailyTrack,
                pageController: pageController,
                studentWeaklyProgress: studentWeaklyTrack,
              ),
              LibraryPage(
                audios: audios,
                books: books,
                pageController: pageController,
              ),
              CoursesPage(courses: courses, pageController: pageController),
            ],
          ),
          bottomNavigationBar: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              bool isLoading = false;
              int selectedIndex = 0;
              if (state is DailyTrackPageOpened) {
                if (!Constant.isThereLoading) {
                  isLoading = true;
                  selectedIndex = 1;
                  if (Constant.student != null) {
                    Constant.isThereLoading = true;
                    getStudentDailyTrack(context).then((value) {
                      if (value == null) {
                        setState(() {});
                      } else {
                        List? temp = value;
                        getStudentWeaklyTrack(context).then((value) {
                          Map? temp1 = value;
                          if (temp1 != null) {
                            studentDailyTrack = temp;
                            studentWeaklyTrack = temp1;
                            setState(() {});
                            pageController
                                .animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 150),
                                  curve: Curves.linear,
                                )
                                .then((value) {
                                  isLoading = false;
                                  Constant.isThereLoading = false;
                                  context.read<HomeBloc>().add(InitEvent());
                                });
                          }
                        });
                      }
                    });
                  } else {
                    pageController
                        .animateToPage(
                          1,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.linear,
                        )
                        .then((value) {
                          isLoading = false;
                          Constant.isThereLoading = false;
                          context.read<HomeBloc>().add(InitEvent());
                        });
                  }
                }
              } else if (state is BookAudioPageOpened) {
                if (!Constant.isThereLoading) {
                  Constant.isThereLoading = true;
                  selectedIndex = 2;
                  isLoading = true;
                  getFiles('صوتيات').then((value) {
                    var audiosRes = value;
                    getFiles('كتب').then((value) {
                      var booksRes = value;
                      if (audiosRes != null && booksRes != null) {
                        audios = audiosRes;
                        books = booksRes;
                        setState(() {});
                        pageController
                            .animateToPage(
                              2,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.linear,
                            )
                            .then((value) {
                              Constant.isThereLoading = false;
                              isLoading = false;
                              context.read<HomeBloc>().add(InitEvent());
                            });
                      }
                    });
                  });
                }
              } else if (state is VideoPageOpened) {
                isLoading = true;
                selectedIndex = 3;
                if (!Constant.isThereLoading) {
                  getFiles('كورسات').then((value) {
                    if (value != null) {
                      courses = value;
                      setState(() {});
                      pageController
                          .animateToPage(
                            3,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear,
                          )
                          .then((value) {
                            Constant.isThereLoading = false;
                            isLoading = false;
                            context.read<HomeBloc>().add(InitEvent());
                          });
                    }
                  });
                }
              }
              return CustomBottomNavigationBar(
                selectedIndex: isLoading
                    ? selectedIndex
                    : pageController.page?.floor() ?? 0,
                isLoading: isLoading,
                pageController: pageController,
                backgroundColor: Color(0xffEBE4E0),
                selectedColor: AppColors.lightBrownColor,
                unSelectedColor: AppColors.bottomSheetUnSelectedColor,
                items: [
                  CustomBottomNavigationBarItem(
                    icon: Mnb.home,
                    onTap: () async {
                      if (!Constant.isThereLoading) {
                        pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.linear,
                        );
                        return true;
                      }
                      return false;
                    },
                  ),
                  CustomBottomNavigationBarItem(
                    icon: Mnb.task_square,
                    onTap: () async {
                      if (!Constant.isThereLoading) {
                        if (Constant.student != null) {
                          Constant.isThereLoading = true;
                          List? temp = await getStudentDailyTrack(context);
                          if (temp == null) {
                            setState(() {});
                          } else {
                            Map? temp1 = await getStudentWeaklyTrack(context);
                            if (temp1 != null) {
                              studentDailyTrack = temp;
                              studentWeaklyTrack = temp1;
                              setState(() {});
                              await pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.linear,
                              );
                              Constant.isThereLoading = false;
                              return true;
                            } else {
                              Constant.isThereLoading = false;
                              return false;
                            }
                          }
                        } else {
                          await pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear,
                          );
                          return true;
                        }
                      }
                      Constant.isThereLoading = false;
                      return false;
                    },
                  ),
                  CustomBottomNavigationBarItem(
                    icon: Mnb.book_,
                    onTap: () async {
                      if (!Constant.isThereLoading) {
                        var audiosRes = await getFiles('صوتيات');
                        var booksRes = await getFiles('كتب');
                        if (audiosRes != null && booksRes != null) {
                          audios = audiosRes;
                          books = booksRes;
                          setState(() {});
                          pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear,
                          );
                          return true;
                        } else {
                          return false;
                        }
                      }
                      return false;
                    },
                  ),
                  CustomBottomNavigationBarItem(
                    icon: Mnb.monitor,
                    onTap: () async {
                      if (!Constant.isThereLoading) {
                        var res = await getFiles('كورسات');
                        if (res != null) {
                          courses = res;
                          setState(() {});
                          pageController.animateToPage(
                            3,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear,
                          );
                          return true;
                        } else {
                          return false;
                        }
                      }
                      return false;
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
