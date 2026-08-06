import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/extensions.dart';
import '../models/student_recall_model.dart';
import '../widgets/data_pages_app_bar.dart';
import '../widgets/recall_data_container.dart';
import '../widgets/widgets.dart';

class StudentRecallsPage extends StatefulWidget {
  final List studentRecalls;
  const StudentRecallsPage({
    super.key,
    required this.studentRecalls,
  });

  @override
  State<StudentRecallsPage> createState() => _StudentMonthlyTrackState();
}

class _StudentMonthlyTrackState extends State<StudentRecallsPage> {
  late DateTime date;
  late List studentRecalls;
  List<StudentRecallModel> studentRecallsModel = [];
  @override
  void initState() {
    date = DateTime.now();
    studentRecalls = widget.studentRecalls;
    for (var element in studentRecalls) {
      studentRecallsModel.add(StudentRecallModel.fromJson(element));
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
                title: 'الاستدعاءات'),
            SizedBox(height: 15.h),
            DateContainer(
              fullDateMode: true,
              allDataMode: true,
              onTap: (p0) async {
                if (p0 != null) {
                  if (p0.year == 0) {
                    studentRecallsModel = [];
                    for (var element in studentRecalls) {
                      studentRecallsModel
                          .add(StudentRecallModel.fromJson(element));
                    }
                  } else {
                    date = p0;
                    studentRecallsModel = [];
                    for (var element in studentRecalls) {
                      if (element['recallDate']
                              .toString()
                              .toDate()!
                              .difference(date)
                              .inDays ==
                          0) {
                        studentRecallsModel
                            .add(StudentRecallModel.fromJson(element));
                      }
                    }
                  }
                  setState(() {});
                }
              },
              withList: true,
            ),
            SizedBox(
              height: 548.h,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    studentRecallsModel.isEmpty
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
                                'لا يوجد استدعاء في هذا اليوم',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.brownColor,
                                    fontSize: 40.sp,
                                    fontFamily: 'Almarai'),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 535.h,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Column(
                                children: List.generate(
                                  studentRecalls.length,
                                  (index) {
                                    StudentRecallModel studentRecallModel =
                                        StudentRecallModel.fromJson(
                                            studentRecalls[index]);
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: RecallDataContainer(
                                        width: 290.w,
                                        data: studentRecallModel,
                                        title: ' ${index + 1} الاستدعاء',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
