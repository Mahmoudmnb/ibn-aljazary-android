import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_bottom_navigation_bar_item.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final List<CustomBottomNavigationBarItem> items;
  final Color selectedColor;
  final Color unSelectedColor;
  final PageController pageController;
  final Color backgroundColor;
  final bool isLoading;
  final int selectedIndex;
  const CustomBottomNavigationBar({
    super.key,
    this.backgroundColor = Colors.white,
    this.isLoading = false,
    this.selectedIndex = 0,
    required this.pageController,
    required this.items,
    required this.selectedColor,
    required this.unSelectedColor,
  }) : assert(items.length >= 2);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedIndex = 0;
  bool isLoading = false;
  int tempIndex = 0;
  @override
  void initState() {
    isLoading = widget.isLoading;
    selectedIndex = widget.selectedIndex;
    tempIndex = widget.selectedIndex;
    widget.pageController.addListener(() async {
      selectedIndex =
          (widget.pageController.page?.round()) ?? widget.items.length - 1;
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigationBar oldWidget) {
    isLoading = widget.isLoading;
    selectedIndex = widget.selectedIndex;
    tempIndex = widget.selectedIndex;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      margin: EdgeInsets.only(bottom: 10.h, right: 16.w, left: 16.w),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          return Expanded(
            child: IconButton(
              onPressed: () async {
                if (selectedIndex != index) {
                  if (!isLoading) {
                    tempIndex = index;
                    isLoading = true;
                    setState(() {});
                    bool isSuccess = await widget.items[index].onTap();
                    isLoading = false;
                    if (isSuccess) {
                      selectedIndex = index;
                    }
                    tempIndex = index;
                    setState(() {});
                  }
                }
              },
              highlightColor: Colors.transparent,
              icon: isLoading && index == tempIndex
                  ? Center(
                      child: CircularProgressIndicator(
                        color: widget.selectedColor,
                      ),
                    )
                  : Icon(
                      widget.items[index].icon,
                      size: 25.sp,
                      color: selectedIndex == index
                          ? widget.selectedColor
                          : widget.unSelectedColor,
                    ),
            ),
          );
        }).reversed.toList(),
      ),
    );
  }
}
