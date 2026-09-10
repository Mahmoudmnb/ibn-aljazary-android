import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toast/toast.dart';

import '../auth/models/student_model.dart';
import '../home/models/app_notification.dart';
import 'app_colors.dart';
import 'internet_info.dart';

Future checkInternet(Future Function() fun, BuildContext? context) async {
  context != null ? ToastContext().init(context) : null;
  bool isMounted = context != null && context.mounted
      ? true
      : context == null
      ? true
      : false;
  try {
    bool isConnected = await InternetInfo.isConnected();
    if (isMounted) {
      if (isConnected) {
        await fun();
      } else if (context != null) {
        Toast.show('تأكد من اتصالك بالانترنت', duration: Toast.lengthLong);
      }
    }
  } on SocketException catch (_) {
    if (context != null && context.mounted) {
      Toast.show('تأكد من اتصالك بالانترنت', duration: Toast.lengthLong);
    }
  } catch (e) {
    log(e.toString());
    if (isMounted && context != null) {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }
}

Future showLoginRequiredDialog(
  BuildContext context,
  Future<void> Function() onLoginPress,
) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 240.w,
        height: 237.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 31.h),
            Image(
              image: AssetImage('assets/images/warning.png'),
              width: 70.w,
              height: 70.h,
            ),
            SizedBox(height: 16.h),
            Text(
              'عليك تسجيل الدخول أولاً',
              style: TextStyle(
                color: AppColors.brownColor,
                fontFamily: 'Almarai',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            InkWell(
              onTap: () async {
                await onLoginPress();
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                width: 160.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: AppColors.appBarColor,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: AppColors.brownColor,
                    fontFamily: 'Almarai',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class Constant {
  static StudentModel? student;
  static List studentsAccount = [];
  static List<AppNotification> notifications = [];
  static bool isThereLoading = false;

  // static const String domainName = 'http://10.0.2.2:8002';

  static const String domainName = 'https://ibn-aljazary.mahmoudbannan.com';

  static const String baseUrl = '$domainName/api';
  static const String getAboutText = '$baseUrl/getAboutText';
  static const String studentLogIn = '$baseUrl/studentLogIn';
  static const String studentLogout = '$baseUrl/studentLogout';

  static const String getStudentInfo = '$baseUrl/getStudentInfo';
  static const String getStudentMonthlyProgress =
      '$baseUrl/getStudentMonthlyProgress';
  static const String getStudentRecalls = '$baseUrl/getStudentRecalls';
  static const String getStudentGrades = '$baseUrl/getGrades';
  static const String getStudentDonations = '$baseUrl/getStudentDonations';
  static const String getStudentMarks = '$baseUrl/getStudentMarks';
  static const String getStudentPrayers = '$baseUrl/getStudentPrayers';
  static const String addStudentPrayer = '$baseUrl/addStudentPrayer';
  static const String updateStudentPrayer = '$baseUrl/updateStudentPrayer';
  static const String getInstituteActions = '$baseUrl/getInstituteActions';
  static const String getInstituteActionStudents =
      '$baseUrl/getInstituteActionStudents';
  static const String updateInstituteActionStudent =
      '$baseUrl/updateInstituteActionStudent';
  static const String getStudentDailyTrack = '$baseUrl/getStudentDailyProgress';
  static const String getStudentDailyProgress =
      '$baseUrl/getStudentDailyProgress';
  static const String getStudentHomeworks = '$baseUrl/getStudentHomeworks';
  static const String saveStudentHomework = '$baseUrl/saveStudentHomework';
  static const String getAllCollections = '$baseUrl/getAllCollections';
  static const String exportFileDataBase = '$baseUrl/exportFileDataBase';
  static const String getNewFiles = '$baseUrl/getNewFiles';
}
