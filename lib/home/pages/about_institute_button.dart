import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class AboutInstituteButton extends StatefulWidget {
  final Future Function() ontTap;
  const AboutInstituteButton({super.key, required this.ontTap});

  @override
  State<AboutInstituteButton> createState() => _AboutInstituteButtonState();
}

class _AboutInstituteButtonState extends State<AboutInstituteButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        isLoading = true;
        setState(() {});
        await widget.ontTap();
        isLoading = false;
        setState(() {});
      },
      child: Container(
        width: 275.w,
        height: 69.h,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'نبذة عن المعهد',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Almarai',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Container(
                    height: 40.h,
                    width: 3,
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: const BoxDecoration(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
