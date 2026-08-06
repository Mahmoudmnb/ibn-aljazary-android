import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import 'custom_text_field.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function() onEditingCompleted;
  final Color color;
  final Color backgroundColor;
  const PasswordTextField({
    super.key,
    this.backgroundColor = Colors.white,
    required this.color,
    required this.onEditingCompleted,
    required this.focusNode,
    required this.controller,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool visiblePassword = false;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      backgroundColor: widget.backgroundColor,
      boxShadow: const [
        BoxShadow(
            color: Color(0x19000000), offset: Offset(-4, 5), blurRadius: 9.5),
      ],
      focusNode: widget.focusNode,
      textInputType: TextInputType.visiblePassword,
      onTapOutSide: (p0) {
        FocusScope.of(context).unfocus();
      },
      onEditingCompleted: widget.onEditingCompleted,
      obscureText: !visiblePassword,
      prefIcon: IconButton(
          onPressed: () {
            visiblePassword = !visiblePassword;
            setState(() {});
          },
          icon: Icon(
            visiblePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.darkBrownColor,
            size: 20.sp,
          )),
      validator: (p0) {
        if (p0!.length < 4) {
          return 'كلمة السر يجب أن تكون أكتر من أربعة محارف';
        }
        return null;
      },
      controller: widget.controller,
      maxLength: 50,
      height: 40.h,
      width: 243.w,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
