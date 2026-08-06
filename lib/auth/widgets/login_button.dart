import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginButton extends StatefulWidget {
  final Future Function() onTap;
  final String text;
  final Color backgroundColor;
  final List<BoxShadow> boxShadow;
  final Color textColor;
  const LoginButton({
    super.key,
    required this.textColor,
    required this.boxShadow,
    required this.backgroundColor,
    required this.text,
    required this.onTap,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!isLoading) {
          isLoading = true;
          setState(() {});
          await widget.onTap();
          isLoading = false;
          setState(() {});
        }
      },
      child: Container(
        width: 160.w,
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12.sp),
          boxShadow: widget.boxShadow,
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: widget.textColor,
                  strokeWidth: 2.w,
                  strokeAlign: -3.sp,
                ),
              )
            : Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Almarai',
                    color: widget.textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
