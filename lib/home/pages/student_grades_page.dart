import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/extensions.dart';
import '../models/student_grade_model.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/grade_data_container.dart';
import '../widgets/widgets.dart';

class StudentGradesPage extends StatefulWidget {
  final List studentGrades;
  const StudentGradesPage({
    super.key,
    required this.studentGrades,
  });

  @override
  State<StudentGradesPage> createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage> {
  late DateTime date;
  late List studentRecalls;
  List<StudentGradeModel> studentGradesModel = [];
  @override
  void initState() {
    date = DateTime.now();
    studentRecalls = widget.studentGrades;
    for (var element in studentRecalls) {
      studentGradesModel.add(StudentGradeModel.fromJson(element));
    }
    super.initState();
  }

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
                title: 'الشهادات'),
            SizedBox(height: 20.h),
            DateContainer(
              fullDateMode: true,
              allDataMode: true,
              onTap: (p0) async {
                if (p0 != null) {
                  if (p0.year == 0) {
                    studentGradesModel = [];
                    for (var element in studentRecalls) {
                      studentGradesModel
                          .add(StudentGradeModel.fromJson(element));
                    }
                  } else {
                    date = p0;
                    studentGradesModel = [];
                    for (var element in studentRecalls) {
                      if (element['originalDate']
                              .toString()
                              .toDate()!
                              .difference(date)
                              .inDays ==
                          0) {
                        studentGradesModel
                            .add(StudentGradeModel.fromJson(element));
                      }
                    }
                  }
                  setState(() {});
                }
              },
              withList: true,
            ),
            studentGradesModel.isEmpty
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
                        'لا يوجد شهادات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.brownColor,
                            fontSize: 40.sp,
                            fontFamily: 'Almarai'),
                      ),
                    ],
                  )
                : SizedBox(
                    height: 540.h,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Column(
                        children: List.generate(
                          studentGradesModel.length,
                          (index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: GradeDataContainer(
                                width: 290.w,
                                data: studentGradesModel[index],
                                title: ' ${index + 1} الشهادة',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
          ],
        ));
  }
}
