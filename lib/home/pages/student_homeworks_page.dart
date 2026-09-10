import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toast/toast.dart';

import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/extensions.dart';
import '../methods/home_page_methods.dart';
import '../widgets/data_pages_app_bar.dart';

class StudentHomeworksPage extends StatefulWidget {
  const StudentHomeworksPage({super.key});

  @override
  State<StudentHomeworksPage> createState() => _StudentHomeworksPageState();
}

class _StudentHomeworksPageState extends State<StudentHomeworksPage> {
  final TextEditingController _homeworkCon = TextEditingController();
  final FocusNode _homeworkFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  List _homeworks = [];
  Map? _selectedHomework;
  String _savedHomework = '';
  bool _isFetching = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchHomeworks();
  }

  @override
  void dispose() {
    _homeworkCon.dispose();
    _homeworkFocusNode.dispose();
    super.dispose();
  }

  String get _selectedDateText => _selectedDate.toCustomString();

  bool get _hasChanges => _homeworkCon.text.trim() != _savedHomework.trim();

  String get _statusText {
    if (_isSaving) {
      return 'جار الحفظ';
    }
    if (_hasChanges) {
      return 'تعديلات غير محفوظة';
    }
    return _savedHomework.trim().isEmpty ? 'لم تكتب بعد' : 'محفوظة';
  }

  Future<void> _fetchHomeworks() async {
    if (_isFetching || Constant.student == null) {
      return;
    }

    setState(() => _isFetching = true);
    final data = await getStudentHomeworks(context);
    if (!mounted) {
      return;
    }

    if (data != null) {
      _homeworks = data;
      _selectHomeworkForDate(_selectedDate);
    }
    setState(() => _isFetching = false);
  }

  void _selectHomeworkForDate(DateTime date) {
    _selectedDate = date;
    final records = _homeworks
        .where(
          (element) =>
              element is Map &&
              element['homeworkDate']?.toString() == _selectedDateText,
        )
        .toList();
    _selectedHomework = records.isEmpty ? null : Map.from(records.first);
    _savedHomework = _selectedHomework?['homework']?.toString() ?? '';
    _homeworkCon.text = _savedHomework;
    _homeworkCon.selection = TextSelection.collapsed(
      offset: _homeworkCon.text.length,
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _selectHomeworkForDate(pickedDate);
      setState(() {});
    }
  }

  Future<void> _saveHomework() async {
    if (_isSaving || Constant.student == null || !_hasChanges) {
      return;
    }

    setState(() => _isSaving = true);
    final data = await saveStudentHomework(
      context: context,
      homeworkId: _selectedHomework?['id'] is int
          ? _selectedHomework!['id'] as int
          : int.tryParse(_selectedHomework?['id']?.toString() ?? ''),
      studentId: Constant.student!.id,
      homeworkDate: _selectedDateText,
      homework: _homeworkCon.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (data != null) {
      _selectedHomework = Map.from(data);
      _savedHomework = _selectedHomework?['homework']?.toString() ?? '';
      final index = _homeworks.indexWhere(
        (element) =>
            element is Map &&
            element['homeworkDate']?.toString() == _selectedDateText,
      );
      if (index == -1) {
        _homeworks.insert(0, _selectedHomework);
      } else {
        _homeworks[index] = _selectedHomework;
      }
      _homeworkCon.text = _savedHomework;
      _homeworkCon.selection = TextSelection.collapsed(
        offset: _homeworkCon.text.length,
      );
    }

    setState(() => _isSaving = false);
  }

  Widget _buildStatusPill() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 28.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _hasChanges ? AppColors.lightGreen : AppColors.appBarColor,
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasChanges
                ? Icons.mode_edit_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: AppColors.brownColor,
            size: 14.sp,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              _statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.brownColor,
                fontSize: 11.sp,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard() {
    final hasText = _homeworkCon.text.trim().isNotEmpty;
    final canSave = _hasChanges && !_isSaving;

    return Container(
      width: 291.w,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      _selectedDateText,
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
            SizedBox(height: 12.h),
            _buildStatusPill(),
            SizedBox(height: 12.h),
            Container(
              constraints: BoxConstraints(minHeight: 160.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.appBarColor.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(12.sp),
              ),
              child: TextField(
                controller: _homeworkCon,
                focusNode: _homeworkFocusNode,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 6,
                maxLines: 9,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.darkBrownColor,
                  fontSize: 14.sp,
                  height: 1.55,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'ما الذي سيُراجع في البيت؟',
                  hintStyle: TextStyle(
                    color: AppColors.darkBrownColor.withValues(alpha: 0.45),
                    fontSize: 13.sp,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                GestureDetector(
                  onTap: hasText
                      ? () {
                          _homeworkCon.clear();
                          setState(() {});
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: hasText
                          ? const Color(0xffF8EFEF)
                          : AppColors.appBarColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: hasText
                          ? const Color(0xffB94A48)
                          : AppColors.greyBrownColor.withValues(alpha: 0.45),
                      size: 19.sp,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: GestureDetector(
                    onTap: canSave ? _saveHomework : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 38.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: canSave || _isSaving
                            ? AppColors.brownColor
                            : AppColors.appBarColor,
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.save_outlined,
                                  color: canSave
                                      ? Colors.white
                                      : AppColors.brownColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'حفظ التعاهد',
                                  style: TextStyle(
                                    color: canSave
                                        ? Colors.white
                                        : AppColors.brownColor,
                                    fontSize: 14.sp,
                                    fontFamily: 'Almarai',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Container(
      width: 291.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سجل التعاهد',
              style: TextStyle(
                color: AppColors.darkBrownColor,
                fontSize: 15.sp,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            if (_homeworks.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: Text(
                    'لا يوجد تعاهد منزلي بعد',
                    style: TextStyle(
                      color: AppColors.greyBrownColor,
                      fontSize: 13.sp,
                      fontFamily: 'Almarai',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              ..._homeworks.map((homework) {
                final item = homework is Map ? homework : {};
                return InkWell(
                  onTap: () {
                    final date = DateTime.tryParse(
                      item['homeworkDate']?.toString() ?? '',
                    );
                    if (date != null) {
                      _selectHomeworkForDate(date);
                      setState(() {});
                    }
                  },
                  borderRadius: BorderRadius.circular(12.sp),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brownBackgroundColor,
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['homeworkDate']?.toString() ?? '',
                          style: TextStyle(
                            color: AppColors.brownColor,
                            fontSize: 12.sp,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item['homework']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.darkBrownColor,
                            fontSize: 12.sp,
                            height: 1.45,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.brownBackgroundColor,
      body: Column(
        children: [
          DataPagesAppBar(
            title: 'التعاهد المنزلي',
            onBackButtonPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      children: [
                        _buildHomeworkCard(),
                        SizedBox(height: 16.h),
                        _buildHistory(),
                        SizedBox(height: 22.h),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
