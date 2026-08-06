import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toast/toast.dart';

import '../../core/app_colors.dart';
import '../methods/auth_page_methods.dart';
import 'custom_text_field.dart';
import 'login_button.dart';
import 'password_text_field.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailCon;
  final TextEditingController passwordCon;
  final TextEditingController studentIdCon;
  final GlobalKey<FormState> formKey;
  final FocusNode emailNode;
  final FocusNode passwordNode;
  final FocusNode idNode;
  const AuthForm({
    super.key,
    required this.formKey,
    required this.emailCon,
    required this.passwordCon,
    required this.studentIdCon,
    required this.emailNode,
    required this.passwordNode,
    required this.idNode,
  });

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 243.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'اسم المستخدم',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      color: AppColors.darkBrownColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    backgroundColor: Color(0xffFCF9F2),
                    focusNode: emailNode,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        offset: Offset(-4, 5),
                        blurRadius: 9.5,
                      ),
                    ],
                    textInputType: TextInputType.emailAddress,
                    onTapOutSide: (p0) {
                      FocusScope.of(context).unfocus();
                    },
                    onEditingCompleted: () {
                      FocusScope.of(context).requestFocus(passwordNode);
                    },
                    validator: (p0) {
                      if (p0!.length < 3) {
                        return 'اسم المستخدم يجب ان يكون اكثر من ثلاث حروف';
                      }
                      return null;
                    },
                    controller: emailCon,
                    maxLength: 50,
                    height: 40.h,
                    width: 243.w,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'كلمة السر',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      color: AppColors.darkBrownColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  PasswordTextField(
                    backgroundColor: Color(0xffFCF9F2),
                    color: AppColors.darkBrownColor,
                    focusNode: passwordNode,
                    controller: passwordCon,
                    onEditingCompleted: () {
                      FocusScope.of(context).requestFocus(idNode);
                    },
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'رقم الطالب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Almarai',
                      color: AppColors.darkBrownColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    backgroundColor: Color(0xffFCF9F2),
                    focusNode: idNode,
                    validator: (p0) {
                      if (p0!.isEmpty) {
                        return 'رقم الطالب لايمكن أن يكون فارغاً';
                      }
                      return null;
                    },
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        offset: Offset(-4, 5),
                        blurRadius: 9.5,
                      ),
                    ],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputType: TextInputType.number,
                    onTapOutSide: (p0) {
                      FocusScope.of(context).unfocus();
                    },
                    controller: studentIdCon,
                    maxLength: 50,
                    height: 40.h,
                    width: 243.w,
                    borderRadius: BorderRadius.circular(16.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            LoginButton(
              textColor: Color(0xffFFFEFC),
              text: 'تسجيل الدخول',
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000),
                  offset: Offset(-4, 5),
                  blurRadius: 9.5,
                ),
              ],
              backgroundColor: AppColors.lightBrownColor,
              onTap: () async {
                await login(
                  formKey: formKey,
                  context: context,
                  email: emailCon.text.trim(),
                  id: studentIdCon.text.trim(),
                  password: passwordCon.text.trim(),
                );
              },
            ),
            SizedBox(height: 20.h),
            LoginButton(
              textColor: AppColors.darkBrownColor,
              boxShadow: [],
              backgroundColor: Colors.transparent,
              text: 'التسجيل لاحقاً',
              onTap: () async {
                await skipLogIn(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
