import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../widgets/data_pages_app_bar.dart';

class CommunicationPage extends StatelessWidget {
  const CommunicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DataPagesAppBar(
                onBackButtonPressed: () {
                  Navigator.of(context).pop();
                },
                title: 'للتواصل'),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: '+963983130657',
                            );
                            await launchUrl(launchUri);
                          } catch (e) {
                            ToastContext().init(context);
                            Toast.show('حصل خطأ غير متوقع',
                                duration: Toast.lengthLong);
                          }
                        },
                        child: Text(
                          '+963983130657',
                          style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff02A6FF)),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'الإدارة',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brownColor,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: '+963947219157',
                            );
                            await launchUrl(launchUri);
                          } catch (e) {
                            ToastContext().init(context);
                            Toast.show('حصل خطأ غير متوقع',
                                duration: Toast.lengthLong);
                          }
                        },
                        child: Text(
                          '+963947219157',
                          style: TextStyle(
                              fontFamily: 'Almarai',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff02A6FF)),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '2 الإدارة',
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brownColor,
                        ),
                      )
                    ],
                  )
                ],
              ),
              title: 'للتواصل',
            ),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: GestureDetector(
                onTap: () {
                  try {
                    launchUrl(Uri.parse(
                        'https://whatsapp.com/channel/0029VbAZddkBlHpbk8U4U72M'));
                  } catch (e) {
                    ToastContext().init(context);
                    Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
                  }
                },
                child: Text(
                  'رابط الدخول للقناة',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Almarai',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xb2008E99)),
                ),
              ),
              title: 'قناة الواتساب',
            ),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: GestureDetector(
                onTap: () {
                  try {
                    launchUrl(Uri.parse('https://t.me/alimamabuhanifa'));
                  } catch (e) {
                    ToastContext().init(context);
                    Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
                  }
                },
                child: Text(
                  'رابط الدخول للقناة',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Almarai',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xb2008E99)),
                ),
              ),
              title: 'قناة التلغرام',
            ),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: GestureDetector(
                onTap: () {
                  try {
                    launchUrl(Uri.parse(
                        'https://www.facebook.com/share/16XDMaaFjb/'));
                  } catch (e) {
                    ToastContext().init(context);
                    Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
                  }
                },
                child: Text(
                  'رابط الصفحة',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Almarai',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xb2008E99)),
                ),
              ),
              title: 'صفحة الفيسبوك',
            ),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: GestureDetector(
                onTap: () {
                  try {
                    launchUrl(Uri.parse(
                        'https://www.instagram.com/alemam.abo.hanfa?igsh=YnppZGxpNmFxY2tm'));
                  } catch (e) {
                    ToastContext().init(context);
                    Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
                  }
                },
                child: Text(
                  'رابط الصفحة',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Almarai',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xb2008E99)),
                ),
              ),
              title: 'صفحة الانستغرام',
            ),
            SizedBox(height: 16.h),
            CommunicationPageContainer(
              content: GestureDetector(
                onTap: () {
                  try {
                    launchUrl(
                        Uri.parse('https://m.youtube.com/@alemam.abo.hanfa'));
                  } catch (e) {
                    ToastContext().init(context);
                    Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
                  }
                },
                child: Text(
                  'رابط الصفحة',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Almarai',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(0xb2008E99)),
                ),
              ),
              title: 'قناة اليوتيوب',
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class CommunicationPageContainer extends StatelessWidget {
  final String title;
  final Widget content;
  const CommunicationPageContainer(
      {super.key, required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 275.w,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(color: Color(0x19000000), blurRadius: 7.1.sp),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
                color: AppColors.darkBrownColor,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp),
          ),
          SizedBox(height: 17.h),
          content
        ],
      ),
    );
  }
}
