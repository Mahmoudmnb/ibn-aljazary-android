import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem extends StatefulWidget {
  final String text;
  final Color textColor;
  final Future Function() onTap;
  final bool isLoading;
  const DrawerItem({
    super.key,
    this.isLoading = false,
    this.textColor = Colors.black,
    required this.onTap,
    required this.text,
  });

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  bool isLoading = false;
  @override
  void initState() {
    isLoading = widget.isLoading;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DrawerItem oldWidget) {
    isLoading = widget.isLoading;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!isLoading) {
          isLoading = true;
          if (mounted) {
            setState(() {});
          }
          await widget.onTap();
          if (!mounted) {
            return;
          }
          isLoading = false;
          setState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        alignment: Alignment.centerRight,
        height: 50.h,
        width: 240.w,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: widget.textColor))
            : Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 18.sp,
                  color: widget.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
