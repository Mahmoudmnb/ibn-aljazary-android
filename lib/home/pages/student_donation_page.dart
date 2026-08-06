import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/extensions.dart';
import '../models/student_donations_model.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/widgets.dart';
import 'donation_data_container.dart';

class StudentDonationPage extends StatefulWidget {
  final List studentDonations;
  const StudentDonationPage({super.key, required this.studentDonations});

  @override
  State<StudentDonationPage> createState() => _StudentDonationPageState();
}

class _StudentDonationPageState extends State<StudentDonationPage> {
  late DateTime date;
  late List studentDonations;
  List<StudentDonationsModel> studentGradesModel = [];
  @override
  void initState() {
    date = DateTime.now();
    studentDonations = widget.studentDonations;
    for (var element in studentDonations) {
      if (element['amount'] != 0) {
        studentGradesModel.add(StudentDonationsModel.fromJson(element));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: Column(
        children: [
          DataPagesAppBar(
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
            title: 'التبرعات',
          ),
          SizedBox(height: 15.h),
          DateContainer(
            fullDateMode: true,
            allDataMode: true,
            onTap: (p0) async {
              if (p0 != null) {
                if (p0.year == 0) {
                  studentGradesModel = [];
                  for (var element in studentDonations) {
                    if (element['amount'] != 0) {
                      studentGradesModel.add(
                        StudentDonationsModel.fromJson(element),
                      );
                    }
                  }
                } else {
                  date = p0;
                  studentGradesModel = [];
                  for (var element in studentDonations) {
                    if (element['donationDate']
                                .toString()
                                .toDate()!
                                .difference(date)
                                .inDays ==
                            0 &&
                        element['amount'] != 0) {
                      studentGradesModel.add(
                        StudentDonationsModel.fromJson(element),
                      );
                    }
                  }
                }
                setState(() {});
              }
            },
            withList: true,
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 538.h,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  widget.studentDonations.isEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 100.h),
                            Image.asset(
                              'assets/images/warning.png',
                              width: 200.w,
                              height: 200.h,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'لا يوجد تبرعات',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.brownColor,
                                fontSize: 40.sp,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                            left: 24.w,
                            right: 24.w,
                            top: 25.h,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 275.w,
                                height: 100.h,
                                padding: EdgeInsets.only(
                                  left: 20.w,
                                  right: 10.h,
                                  top: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.appBarColor,
                                  borderRadius: BorderRadius.circular(16.sp),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x19000000),
                                      blurRadius: 7.1,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget
                                              .studentDonations
                                              .last['donations']
                                              .toString()
                                              .toString(),
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'مبلغ التبرع الشهري',
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Text(
                                          widget
                                              .studentDonations
                                              .last['totalLast']
                                              .toString(),
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'المبلغ المتراكم',
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Text(
                                          widget
                                              .studentDonations
                                              .last['totalDonation']
                                              .toString(),
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          'المبلغ الكلي المدفوع',
                                          style: TextStyle(
                                            color: AppColors.brownColor,
                                            fontFamily: 'Almarai',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ...List.generate(studentGradesModel.length, (
                                index,
                              ) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: DonationDataContainer(
                                    text: studentGradesModel[index].amount
                                        .toString(),
                                    title: 'التبرع  ${index + 1}',
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
