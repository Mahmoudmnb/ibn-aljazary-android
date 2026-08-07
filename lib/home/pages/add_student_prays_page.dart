import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/extensions.dart';
import '../methods/home_page_methods.dart';
import '../widgets/data_pages_app_bar.dart';

class AddStudentPraysPage extends StatefulWidget {
  const AddStudentPraysPage({super.key});

  @override
  State<AddStudentPraysPage> createState() => _AddStudentPraysPageState();
}

class _AddStudentPraysPageState extends State<AddStudentPraysPage> {
  final Map<String, String?> _prays = {
    'fajer': null,
    'zohar': null,
    'asar': null,
    'magrib': null,
    'esha': null,
  };
  final List<Map<String, String>> _prayLabels = const [
    {'key': 'fajer', 'label': 'الفجر'},
    {'key': 'zohar', 'label': 'الظهر'},
    {'key': 'asar', 'label': 'العصر'},
    {'key': 'magrib', 'label': 'المغرب'},
    {'key': 'esha', 'label': 'العشاء'},
  ];
  final List<Map<String, String>> _prayerOptions = const [
    {'name': 'في المسجد', 'value': 'in_mosque'},
    {'name': 'في البيت', 'value': 'at_home'},
    {'name': 'لم يصل', 'value': 'no'},
  ];
  DateTime _selectedDate = DateTime.now();
  int? _recordId;
  bool _isLoading = false;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchSelectedDayPrays();
  }

  void _clearPrays() {
    for (final key in _prays.keys) {
      _prays[key] = null;
    }
  }

  bool _recordMatchesSelectedDate(dynamic record) {
    return record['date']?.toString() == _selectedDate.toCustomString();
  }

  void _applyRecord(Map record) {
    _recordId = int.tryParse(record['id'].toString());
    for (final key in _prays.keys) {
      final value = record[key]?.toString();
      _prays[key] = value == null || value.isEmpty ? null : value;
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      await _fetchSelectedDayPrays();
    }
  }

  Future<void> _fetchSelectedDayPrays() async {
    if (_isFetching || Constant.student == null) {
      return;
    }

    setState(() {
      _isFetching = true;
    });

    await checkInternet(() async {
      final uri = Uri.parse(Constant.getStudentPrayers).replace(
        queryParameters: {'studentId': Constant.student!.id.toString()},
      );
      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization":
              "Bearer ${await getToken(Constant.student!.id.toString())}",
        },
      );

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] ?? [];
        _clearPrays();
        _recordId = null;

        final records = data.where(_recordMatchesSelectedDate).toList();
        if (records.isNotEmpty) {
          _applyRecord(records.first);
        }
      } else if (response.statusCode == 405 || response.statusCode == 401) {
        await removeUnauthorizedUser();
      } else {
        Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
      }
    }, context);

    if (mounted) {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _savePrays() async {
    if (_isLoading || _isFetching || Constant.student == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int statusCode = 200;
    await checkInternet(() async {
      final body = {
        if (_recordId != null) 'id': _recordId,
        'studentId': Constant.student!.id,
        'date': _selectedDate.toCustomString(),
        ..._prays,
      };
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await getToken(Constant.student!.id.toString())}",
      };
      final response = _recordId == null
          ? await http.post(
              Uri.parse(Constant.addStudentPrayer),
              body: jsonEncode(body),
              headers: headers,
            )
          : await http.put(
              Uri.parse(Constant.updateStudentPrayer),
              body: jsonEncode(body),
              headers: headers,
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Toast.show('تم حفظ الصلوات بنجاح', duration: Toast.lengthLong);
        final data = jsonDecode(response.body)['data'];
        if (data != null) {
          _recordId = int.tryParse(data['id'].toString());
        }
      } else if (response.statusCode == 405 || response.statusCode == 401) {
        await removeUnauthorizedUser();
        statusCode = 401;
      } else if (response.statusCode == 400) {
        final body = jsonDecode(response.body);
        await _fetchSelectedDayPrays();
        Toast.show(
          _recordId == null
              ? body['message']?.toString() ?? 'خطأ غير معروف حاول ثانية'
              : 'تم تحميل سجل هذا اليوم يمكنك تعديله الآن',
          duration: Toast.lengthLong,
        );
      } else {
        Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
      }
    }, context);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (statusCode == 401) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            title: 'إضافة الصلوات',
            onBackButtonPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Container(
                    width: 291.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.sp),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0c000000), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SectionTitle(text: 'التاريخ'),
                        SizedBox(height: 10.h),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(12.sp),
                          child: Container(
                            height: 46.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: AppColors.brownBackgroundColor,
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: AppColors.lightBrownColor,
                                  size: 22.sp,
                                ),
                                const Spacer(),
                                Text(
                                  _selectedDate.toCustomString(),
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: AppColors.brownColor,
                                    fontFamily: 'Almarai',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        if (_isFetching)
                          Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        _SectionTitle(text: 'الصلوات'),
                        SizedBox(height: 12.h),
                        ..._prayLabels.map(
                          (pray) => _PrayStatusField(
                            key: ValueKey(
                              '${pray['key']}-${_prays[pray['key']]}',
                            ),
                            title: pray['label'] ?? '',
                            value: _prays[pray['key']],
                            options: _prayerOptions,
                            onChanged: (value) => setState(
                              () => _prays[pray['key'] ?? ''] = value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: _savePrays,
                    borderRadius: BorderRadius.circular(14.sp),
                    child: Container(
                      alignment: Alignment.center,
                      width: 291.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.appBarColor,
                        borderRadius: BorderRadius.circular(14.sp),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.lightBrownColor,
                            )
                          : Text(
                              'حفظ',
                              style: TextStyle(
                                color: AppColors.lightBrownColor,
                                fontFamily: 'Almarai',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.lightBrownColor,
        fontFamily: 'Almarai',
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PrayStatusField extends StatelessWidget {
  final String title;
  final String? value;
  final List<Map<String, String>> options;
  final ValueChanged<String?> onChanged;
  const _PrayStatusField({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.brownColor,
                fontFamily: 'Almarai',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              alignment: AlignmentDirectional.centerEnd,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.brownBackgroundColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Colors.white,
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option['value'],
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        option['name'] ?? '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColors.brownColor,
                          fontFamily: 'Almarai',
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
