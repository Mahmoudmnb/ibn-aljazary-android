import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/core/extensions.dart';
import '../../core/app_colors.dart';
import '../models/student_test_model.dart';
import '../widgets/data_container.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/widgets.dart';

class StudentTestPage extends StatefulWidget {
  final List studentTests;
  final String testType;
  const StudentTestPage({
    super.key,
    required this.testType,
    required this.studentTests,
  });

  @override
  State<StudentTestPage> createState() => _StudentTestPageState();
}

class _StudentTestPageState extends State<StudentTestPage> {
  late DateTime date;
  late List studentTests;
  List<StudentTestModel> studentTestsModel = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            title: widget.testType,
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: 22.h),
          DateContainer(
            fullDateMode: true,
            allDataMode: true,
            onTap: (p0) async {
              if (p0 != null) {
                if (p0.year == 0) {
                  studentTestsModel = [];
                  for (var element in studentTests) {
                    studentTestsModel.add(StudentTestModel.fromJson(element));
                  }
                } else {
                  date = p0;
                  studentTestsModel = [];
                  for (var element in studentTests) {
                    for (var attr in element['data']) {
                      if (attr['dataType'] == 'date') {
                        if (attr['mark']
                                .toString()
                                .toDate()!
                                .difference(date)
                                .inDays ==
                            0) {
                          studentTestsModel.add(
                            StudentTestModel.fromJson(element),
                          );
                        }
                      }
                    }
                  }
                }
                setState(() {});
              }
            },
            withList: true,
          ),
          studentTestsModel.isEmpty
              ? Column(
                  children: [
                    SizedBox(height: 80.h),
                    Image.asset(
                      'assets/images/warning.png',
                      width: 200.w,
                      height: 200.h,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      widget.testType == 'أوقاف'
                          ? 'لا يوجد سبر'
                          : widget.testType == 'محلي'
                          ? 'لا يوجد إختبارات'
                          : 'لا يوجد علامات منهج',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.brownColor,
                        fontSize: 40.sp,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 540.h,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Column(
                      children: List.generate(studentTestsModel.length, (
                        index,
                      ) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: TestDataContainer(
                            width: 290.w,
                            data: studentTestsModel[index],
                            title: widget.testType == 'أوقاف'
                                ? ' ${index + 1} السبر'
                                : widget.testType == 'محلي'
                                ? ' ${index + 1} الاختبار'
                                : ' ${index + 1} الامتحان',
                          ),
                        );
                      }),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  void initState() {
    date = DateTime.now();
    studentTests = widget.studentTests;
    for (var element in studentTests) {
      studentTestsModel.add(StudentTestModel.fromJson(element));
    }
    super.initState();
  }
}
