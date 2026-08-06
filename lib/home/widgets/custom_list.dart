import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_list_item.dart';

class CustomList extends StatelessWidget {
  final Color backgroundColor;
  final bool isMenuOpened;
  final double width;
  final double maxHight;
  final double topOffset;
  final BorderRadius borderRadius;
  final List<CustomListItem> items;
  final String title;
  final Color titleColor;
  const CustomList({
    super.key,
    this.topOffset = 0,
    required this.titleColor,
    required this.title,
    required this.borderRadius,
    required this.isMenuOpened,
    required this.items,
    required this.maxHight,
    required this.width,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topOffset),
      constraints: BoxConstraints(maxHeight: maxHight),
      width: width,
      padding: EdgeInsets.all(isMenuOpened && items.isNotEmpty ? 10.w : 0),
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
                blurRadius: 16,
                color: const Color(0x3f000000),
                offset: Offset(0, 4.w))
          ]),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isMenuOpened && items.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: titleColor,
                          fontFamily: 'Almarai',
                          fontWeight: FontWeight.w700),
                    ),
                  )
                : const SizedBox.shrink(),
            SizedBox(height: isMenuOpened && items.isNotEmpty ? 8.h : 0),
            SingleChildScrollView(
              child: Column(
                children: List.generate(items.length, (index) {
                  return GestureDetector(
                    onTap: items[index].onTap,
                    child: AnimatedContainer(
                      width: width - 20.w,
                      margin: EdgeInsets.only(bottom: isMenuOpened ? 6.h : 0),
                      decoration: BoxDecoration(
                          color: items[index].backgroundColor,
                          borderRadius: items[index].borderRadius),
                      duration: const Duration(milliseconds: 100),
                      height: isMenuOpened ? 29.h : 0,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        items[index].text,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: items[index].textColor,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
