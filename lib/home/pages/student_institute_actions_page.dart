import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../methods/home_page_methods.dart';
import '../widgets/data_pages_app_bar.dart';

class StudentInstituteActionsPage extends StatefulWidget {
  const StudentInstituteActionsPage({super.key});

  @override
  State<StudentInstituteActionsPage> createState() =>
      _StudentInstituteActionsPageState();
}

class _StudentInstituteActionsPageState
    extends State<StudentInstituteActionsPage> {
  List<Map<String, dynamic>> _actions = [];
  bool _isLoading = true;
  int? _updatingMembershipId;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<Map<String, String>> _headers() async {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization":
          "Bearer ${await getToken(Constant.student!.id.toString())}",
    };
  }

  Future<void> _loadActions() async {
    if (Constant.student == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await checkInternet(() async {
      final headers = await _headers();
      final actionsResponse = await http.get(
        Uri.parse(Constant.getInstituteActions),
        headers: headers,
      );

      if (!mounted) {
        return;
      }

      if (actionsResponse.statusCode == 405 ||
          actionsResponse.statusCode == 401) {
        await removeUnauthorizedUser();
        if (mounted) {
          Navigator.of(context).pop(false);
        }
        return;
      }

      if (actionsResponse.statusCode != 200) {
        Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
        return;
      }

      final loadedActions = (jsonDecode(actionsResponse.body) as List)
          .map((action) => Map<String, dynamic>.from(action))
          .toList();
      final actionStudentResponses = await Future.wait(
        loadedActions.map(
          (action) => http.get(
            Uri.parse('${Constant.getInstituteActionStudents}/${action['id']}'),
            headers: headers,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      final linkedActions = <Map<String, dynamic>>[];
      for (var i = 0; i < loadedActions.length; i++) {
        if (actionStudentResponses[i].statusCode != 200) {
          continue;
        }

        final students = jsonDecode(actionStudentResponses[i].body) as List;
        Map<String, dynamic>? membership;
        for (final student in students) {
          if (student['student_id'].toString() ==
              Constant.student!.id.toString()) {
            membership = Map<String, dynamic>.from(student);
            break;
          }
        }

        if (membership != null) {
          linkedActions.add({
            ...loadedActions[i],
            'membership_id': membership['id'],
            'accepted': membership['accepted'],
          });
        }
      }

      _actions = linkedActions;
    }, context);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateActionStatus(
    Map<String, dynamic> action,
    bool accepted,
  ) async {
    if (_updatingMembershipId != null || Constant.student == null) {
      return;
    }

    final membershipId = int.tryParse(action['membership_id'].toString());
    if (membershipId == null) {
      return;
    }

    setState(() {
      _updatingMembershipId = membershipId;
    });

    await checkInternet(() async {
      final response = await http.put(
        Uri.parse(Constant.updateInstituteActionStudent),
        headers: await _headers(),
        body: jsonEncode({
          'id': membershipId,
          'institute_action_id': action['id'],
          'student_id': Constant.student!.id,
          'accepted': accepted,
        }),
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        action['accepted'] = accepted;
        Toast.show(
          accepted ? 'تم قبول النشاط بنجاح' : 'تم رفض النشاط بنجاح',
          duration: Toast.lengthLong,
        );
      } else if (response.statusCode == 405 || response.statusCode == 401) {
        await removeUnauthorizedUser();
        if (mounted) {
          Navigator.of(context).pop(false);
        }
      } else {
        final body = jsonDecode(response.body);
        Toast.show(
          body['message']?.toString() ?? 'خطأ غير معروف حاول ثانية',
          duration: Toast.lengthLong,
        );
      }
    }, context);

    if (mounted) {
      setState(() {
        _updatingMembershipId = null;
      });
    }
  }

  String _acceptedText(dynamic accepted) {
    if (accepted == true || accepted == 1 || accepted?.toString() == '1') {
      return 'مقبول';
    }
    if (accepted == false || accepted == 0 || accepted?.toString() == '0') {
      return 'مرفوض';
    }
    return 'بانتظار الرد';
  }

  Color _acceptedColor(dynamic accepted) {
    if (accepted == true || accepted == 1 || accepted?.toString() == '1') {
      return AppColors.green;
    }
    if (accepted == false || accepted == 0 || accepted?.toString() == '0') {
      return const Color(0xffDE0000);
    }
    return AppColors.greyBrownColor;
  }

  bool _isTrue(dynamic value) {
    return value == true || value == 1 || value?.toString() == '1';
  }

  String _dateText(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) {
      return value?.toString() ?? '';
    }
    return '${date.day.toString().padLeft(2, '0')} - ${date.month.toString().padLeft(2, '0')} - ${date.year}';
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: AppColors.appBarColor,
                borderRadius: BorderRadius.circular(9.sp),
              ),
              child: Icon(icon, color: AppColors.brownColor, size: 16.sp),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.greyBrownColor,
                      fontSize: 11.sp,
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.darkBrownColor,
                      fontSize: 13.sp,
                      height: 1.45,
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            title: 'نشاطات المعهد',
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: 18.h),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightBrownColor,
                    ),
                  )
                : _actions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/warning.png',
                          width: 170.w,
                          height: 170.h,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'لا يوجد نشاطات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.brownColor,
                            fontSize: 34.sp,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.lightBrownColor,
                    onRefresh: _loadActions,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: _actions.length,
                      itemBuilder: (context, index) {
                        final action = _actions[index];
                        final membershipId = int.tryParse(
                          action['membership_id'].toString(),
                        );
                        final isUpdating =
                            _updatingMembershipId != null &&
                            _updatingMembershipId == membershipId;
                        final actionTitle = action['action']?.toString() ?? '';
                        final actionDescription =
                            action['description']?.toString() ?? '';
                        final actionDate = _dateText(action['action_date']);
                        final actionStatus = _isTrue(action['is_active'])
                            ? 'نشط'
                            : 'غير نشط';
                        final responseStatus = _acceptedText(
                          action['accepted'],
                        );

                        return Container(
                          width: 291.w,
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.sp),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0c000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        actionTitle,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: AppColors.brownColor,
                                          fontSize: 16.sp,
                                          height: 1.35,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 9.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _acceptedColor(
                                          action['accepted'],
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          20.sp,
                                        ),
                                      ),
                                      child: Text(
                                        responseStatus,
                                        style: TextStyle(
                                          color: _acceptedColor(
                                            action['accepted'],
                                          ),
                                          fontSize: 11.sp,
                                          fontFamily: 'Almarai',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                _infoRow(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'تاريخ النشاط',
                                  value: actionDate,
                                ),
                                _infoRow(
                                  icon: Icons.article_outlined,
                                  label: 'الوصف',
                                  value: actionDescription,
                                ),
                                _infoRow(
                                  icon: Icons.toggle_on_outlined,
                                  label: 'حالة النشاط',
                                  value: actionStatus,
                                ),
                                _infoRow(
                                  icon: Icons.confirmation_number_outlined,
                                  label: 'رقم النشاط',
                                  value: action['id']?.toString() ?? '',
                                ),
                                _infoRow(
                                  icon: Icons.assignment_ind_outlined,
                                  label: 'رقم المشاركة',
                                  value:
                                      action['membership_id']?.toString() ?? '',
                                ),
                                SizedBox(height: 14.h),
                                isUpdating
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.lightBrownColor,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: _ActionStatusButton(
                                              text: 'رفض',
                                              color: const Color(0xffDE0000),
                                              onTap: () => _updateActionStatus(
                                                action,
                                                false,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: _ActionStatusButton(
                                              text: 'قبول',
                                              color: AppColors.green2,
                                              onTap: () => _updateActionStatus(
                                                action,
                                                true,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionStatusButton extends StatelessWidget {
  final String text;
  final Color color;
  final Future<void> Function() onTap;
  const _ActionStatusButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.sp),
      child: Container(
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Almarai',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
