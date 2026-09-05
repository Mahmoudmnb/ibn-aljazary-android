import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

class HomePageButton extends StatefulWidget {
  final String text;
  final Future Function() onTap;
  final Color backgroundColor;
  final double width;
  final double height;
  final IconData iconData;
  final bool isLoading;
  const HomePageButton({
    super.key,
    this.backgroundColor = Colors.white,
    this.isLoading = false,
    required this.iconData,
    required this.height,
    required this.width,
    required this.onTap,
    required this.text,
  });

  @override
  State<HomePageButton> createState() => _HomePageButtonState();
}

class _HomePageButtonState extends State<HomePageButton> {
  bool isLoading = false;
  @override
  void initState() {
    isLoading = widget.isLoading;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomePageButton oldWidget) {
    isLoading = widget.isLoading;
    super.didUpdateWidget(oldWidget);
  }

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
      child: Column(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16.sp),
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Icon(widget.iconData, size: 22.sp, color: Colors.white),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: widget.width + 26.w,
            height: 34.h,
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.lightBrownColor,
                fontSize: 13.sp,
                height: 1.2,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
