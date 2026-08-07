import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/methods/auth_page_methods.dart';
import 'auth/models/student_model.dart';
import 'auth/pages/splash_screen.dart';
import 'core/app_background.dart';
import 'core/app_colors.dart';
import 'core/constant.dart';
import 'firebase_options.dart';
import 'home/bloc/home_bloc.dart';
import 'home/methods/home_page_methods.dart';
import 'home/models/app_notification.dart';
import 'home/pages/main_page.dart';

Future<void> handelMessageArrive(RemoteMessage message) async {
  if (message.data['page'] == 'صوتيات' ||
      message.data['page'] == 'كتب' ||
      message.data['page'] == 'الدروس العلمية') {
    await updateFilesDataBase(message.data);
  } else if (message.data['page'] == 'advertingImage') {
    String urls = '';
    for (var element in jsonDecode(message.data['urls'])) {
      urls += '\n$element';
    }
    urls = urls.replaceFirst('\n', '');
    await updateAdvertingImages(urls);
  } else if (message.data['page'] == 'student_ranking') {
    await updateStudentRanking(
      studentId: message.data['studentId'].toString(),
      level: message.data['level'].toString(),
      score: message.data['score'].toString(),
      year: message.data['year'].toString(),
      month: message.data['month'].toString(),
      classStudentCount: message.data['classStudentCount'].toString(),
    );
  } else if (message.data['page'] == 'profile') {
    await updateStudentProfile(message.data);
  }
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
}

bool shouldShowNotification(RemoteMessage message) {
  if ((message.data['page'] == 'صوتيات' ||
          message.data['page'] == 'كتب' ||
          message.data['page'] == 'الدروس العلمية') &&
      (message.data['type'] != 'file' || message.data['method'] == 'delete')) {
    return false;
  }

  if (message.data['page'] == 'profile' && message.data['show'] == 'false') {
    return false;
  }

  return true;
}

AppNotification appNotificationFromMessage(RemoteMessage message) {
  return AppNotification(
    body: message.notification?.body ?? message.data['body']?.toString() ?? '',
    id:
        message.messageId ??
        message.data['id']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString(),
    title:
        message.notification?.title ?? message.data['title']?.toString() ?? '',
  );
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await handelMessageArrive(message);

  if (shouldShowNotification(message)) {
    await addNotification(appNotificationFromMessage(message));
    log(
      "Background message: ${message.notification?.title ?? message.data['title'] ?? ''}",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  requestPermission();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences sh = await SharedPreferences.getInstance();
  Constant.notifications = ((sh.getStringList('notifications')) ?? [])
      .map((e) => AppNotification.fromMap(jsonDecode(e)))
      .toList();
  List tables = await getTablesNameInDataBase('usersDataBase.db');
  if (tables.isNotEmpty) {
    Constant.student = await getCurrentStudentAccount();
    Constant.studentsAccount = await getStudentsAccount();
  }
  bool? res = sh.getBool('isFirstTime');
  runApp(MyApp(student: Constant.student, isFirstTime: res == null));
}

class MyApp extends StatelessWidget {
  final StudentModel? student;
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime, required this.student});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: MaterialApp(
        title: 'مقرأة الإمام ابي حنيفة',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brownColor),
          scaffoldBackgroundColor: Colors.transparent,
          useMaterial3: true,
        ),
        builder: (context, child) =>
            AppBackground(child: child ?? const SizedBox.shrink()),
        debugShowCheckedModeBanner: false,
        home: ScreenUtilInit(
          designSize: const Size(323, 700),
          builder: (context, child) =>
              isFirstTime ? const SplashScreen() : MainPage(student: student),
        ),
      ),
    );
  }
}
