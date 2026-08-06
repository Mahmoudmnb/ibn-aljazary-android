import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import 'widgets.dart';

class DrawerList extends StatefulWidget {
  final List<DrawerListItem> users;
  final Future Function() onAddNewItemTap;
  const DrawerList({
    super.key,
    required this.onAddNewItemTap,
    required this.users,
  }) : assert(users.length > 0);

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  bool isOpened = false;
  late List<DrawerListItem> users;
  @override
  void initState() {
    users = widget.users;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        isOpened = false;
        setState(() {});
      },
      child: Container(
        width: 240.w,
        constraints: BoxConstraints(maxHeight: 230.h),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(color: Color(0x3f000000), blurRadius: 7.1)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              bottomLeft: Radius.circular(20.sp),
              bottomRight: Radius.circular(20.sp)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  isOpened = !isOpened;
                  setState(() {});
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: Row(
                    children: [
                      Icon(
                        isOpened
                            ? Icons.check
                            : Icons.keyboard_arrow_down_sharp,
                        color: AppColors.brownColor,
                        size: 25.sp,
                      ),
                      // const Spacer(),
                      Expanded(
                        child: Text(
                          users.isNotEmpty ? users.first.text : '',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.brownColor,
                              fontFamily: 'Almarai',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(users.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isOpened ? const Divider() : const SizedBox.shrink(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      alignment: Alignment.centerRight,
                      height: isOpened ? 40.h : 0,
                      width: 240.w,
                      child: index == users.length - 1
                          ? InkWell(
                              onTap: () async {
                                await widget.onAddNewItemTap();
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: isOpened ? 20.sp : 0,
                                    color: AppColors.brownColor,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'إضافة طالب',
                                    style: TextStyle(
                                        color: AppColors.brownColor,
                                        fontFamily: 'Almarai',
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700),
                                  )
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () async {
                                var res = await users[index + 1].onTap();
                                if (res) {
                                  var t = List.of(users);
                                  var temp = t[0];
                                  t[0] = t[index + 1];
                                  t[index + 1] = temp;
                                  users = t;
                                  setState(() {});
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    users[index + 1].text,
                                    style: TextStyle(
                                        color: AppColors.brownColor,
                                        fontFamily: 'Almarai',
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }
}
