import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/models/student_model.dart';
import '../../core/app_colors.dart';
import '../widgets/data_pages_app_bar.dart';

class ProfileCustomItem extends StatelessWidget {
  final String mainText;
  final String text;
  const ProfileCustomItem({
    super.key,
    required this.mainText,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          mainText,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16.sp,
            color: AppColors.brownColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: 244.w,
          padding: EdgeInsets.only(right: 10.w, top: 8.h, bottom: 8.h),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: AppColors.appBarColor,
            borderRadius: BorderRadius.circular(16.sp),
            boxShadow: [BoxShadow(color: Color(0x19000000), blurRadius: 7.1)],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.brownColor,
              fontSize: 14.sp,
              fontFamily: 'Almarai',
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  final StudentModel student;
  const ProfilePage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
            title: 'الملف الشخصي',
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15.h),
                Image(
                  image: AssetImage('assets/images/profile.png'),
                  fit: BoxFit.cover,
                  width: 100.w,
                  height: 100.h,
                ),
                SizedBox(height: 14.h),
                Text(
                  student.fName + ' ' + student.lName,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 20.sp,
                    color: AppColors.brownColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 275.w,
                  // height: 370.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      ProfileCustomItem(
                        mainText: 'رقم الطالب',
                        text: student.id.toString(),
                      ),
                      SizedBox(height: 14.h),
                      ProfileCustomItem(
                        mainText: 'اسم الحلقة',
                        text: student.className.toString(),
                      ),
                      SizedBox(height: 14.h),
                      ProfileCustomItem(
                        mainText: 'نوع الحلقة',
                        text: student.classSubject.toString(),
                      ),
                      SizedBox(height: 14.h),
                      ProfileCustomItem(
                        mainText: 'أساتذة الحلقة',
                        text: student.teachers.toString(),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
