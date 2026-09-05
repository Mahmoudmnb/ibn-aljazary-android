import 'dart:async';
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
import '../widgets/widgets.dart';
import 'courses_page.dart';
import 'home_page.dart';
import 'library_page.dart';
import 'student_daily_track_page.dart';
import 'student_institute_actions_page.dart';

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
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  List studentDailyTrack = [];
  Map studentWeaklyTrack = {};
  List books = [];
  List audios = [];
  List courses = [];
  static const AndroidNotificationChannel _notificationChannel =
      AndroidNotificationChannel(
        'channelId',
        'channelName',
        importance: Importance.high,
      );

  Future<void> _switchStudentFromMessage(RemoteMessage message) async {
    if (message.data['studentId'] == null) {
      return;
    }

    List students = await getStudentsAccount();
    for (var element in students) {
      if (jsonDecode(element['data'])['id'].toString() ==
          message.data['studentId'].toString()) {
        Constant.student = StudentModel.fromMap(jsonDecode(element['data']));
        await setCurrentUser(Constant.student!);
        break;
      }
    }
  }

  int _notificationId(RemoteMessage message) {
    final id = message.messageId ?? message.data['id']?.toString();
    return id == null
        ? DateTime.now().millisecondsSinceEpoch.remainder(2147483647)
        : id.hashCode.abs().remainder(2147483647);
  }

  handleMessageClick(RemoteMessage message) async {
    final notification = appNotificationFromMessage(message);
    await removeNotification(notification);
    Constant.notifications.removeWhere(
      (element) => element.id.toString() == notification.id,
    );
    try {
      await _switchStudentFromMessage(message);
      if (!mounted) {
        return;
      }
      final navigator = Navigator.of(context);
      final homeBloc = context.read<HomeBloc>();

      for (;;) {
        if (navigator.canPop()) {
          navigator.pop();
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
        if (!mounted) return;
        homeBloc.add(OpenAwqafTestPage(date: ''));
      } else if (message.data['page'] == 'محلي') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        homeBloc.add(OpenLocalTestPage());
      } else if (message.data['page'] == 'منهج') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        homeBloc.add(OpenCourseTestPage());
      } else if (message.data['page'] == 'شهادة') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        homeBloc.add(OpenGradesPage());
      } else if (message.data['page'] == 'استدعاء') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        homeBloc.add(OpenRecallsPage());
      } else if (message.data['page'] == 'المتابعة اليومية') {
        homeBloc.add(OpenDailyTrackPage());
      } else if (message.data['page'] == 'صوتيات' ||
          message.data['page'] == 'كتب') {
        homeBloc.add(OpenBookAudioPage());
      } else if (message.data['page'] == 'الدروس العلمية') {
        homeBloc.add(OpenVideosPage());
      } else if (message.data['page'] == 'advertingImage') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        setState(() {});
      } else if (message.data['page'] == 'aboutInstitute') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        _scaffoldKey.currentState!.openEndDrawer();
        homeBloc.add(OpenAboutInstitutePage());
      } else if (message.data['page'] == 'donation') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) return;
        _scaffoldKey.currentState?.openEndDrawer();
        homeBloc.add(OpenDonationPage());
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
        if (!mounted) return;
        homeBloc.add(OpenStudentRankingPage());
        setState(() {});
      } else if (message.data['page'] == 'institute_actions') {
        await pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        );
        if (!mounted) {
          return;
        }
        navigator.push(
          MaterialPageRoute(
            builder: (context) => const StudentInstituteActionsPage(),
          ),
        );
      }
    } catch (e) {
      log('handel error :$e');
    }
  }

  void initNotifications() {
    _messageSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      await handelMessageArrive(message);

      if (shouldShowNotification(message)) {
        final notification = appNotificationFromMessage(message);
        await addNotification(notification);
        Constant.notifications.add(notification);
        const rtl = '\u200F'; // Right-To-Left Mark
        await flutterLocalNotificationsPlugin.show(
          id: _notificationId(message),
          title: '$rtl${notification.title}',
          body: '$rtl${notification.body}',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'channelId',
              'channelName',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode({'id': message.messageId, 'data': message.data}),
        );

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> _initLocalNotifications() async {
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

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_notificationChannel);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload == null || details.payload!.isEmpty) {
          return;
        }

        try {
          final payload = jsonDecode(details.payload!);
          final data = payload['data'];
          if (data is! Map) {
            return;
          }

          await handleMessageClick(
            RemoteMessage(
              data: Map<String, dynamic>.from(data),
              messageId: payload['id']?.toString(),
            ),
          );
        } catch (e) {
          log('notification payload error: $e');
        }
      },
    );
  }

  @override
  void initState() {
    pageController = PageController(initialPage: 0);

    unawaited(_initLocalNotifications());
    initNotifications();

    // When app is in background and user taps the notification
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) async {
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
  void dispose() {
    _messageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

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
          bottomNavigationBar: isKeyboardOpen
              ? null
              : BlocBuilder<HomeBloc, HomeState>(
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
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        curve: Curves.linear,
                                      )
                                      .then((value) {
                                        isLoading = false;
                                        Constant.isThereLoading = false;
                                        context.read<HomeBloc>().add(
                                          InitEvent(),
                                        );
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
                      backgroundColor: AppColors.appBarColor,
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
                                List? temp = await getStudentDailyTrack(
                                  context,
                                );
                                if (temp == null) {
                                  setState(() {});
                                } else {
                                  Map? temp1 = await getStudentWeaklyTrack(
                                    context,
                                  );
                                  if (temp1 != null) {
                                    studentDailyTrack = temp;
                                    studentWeaklyTrack = temp1;
                                    setState(() {});
                                    await pageController.animateToPage(
                                      1,
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
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
