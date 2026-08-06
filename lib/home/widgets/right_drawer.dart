import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/models/student_model.dart';
import '../../auth/pages/splash_screen.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';
import 'widgets.dart';

class RightDrawer extends StatefulWidget {
  final List<DrawerItem> items;
  final List users;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PageController pageController;
  const RightDrawer({
    super.key,
    required this.pageController,
    required this.scaffoldKey,
    required this.users,
    required this.items,
  });

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  late List users;
  @override
  initState() {
    users = widget.users;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            fit: StackFit.loose,
            children: [
              Container(
                width: 240.w,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: 70.h),
                padding: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3f000000),
                      offset: Offset(-10, 0),
                      blurRadius: 20,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.sp),
                    bottomLeft: Radius.circular(20.sp),
                    bottomRight: Radius.circular(20.sp),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  fit: StackFit.loose,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 75),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(widget.items.length, (index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.items[index],
                              index == widget.items.length - 1
                                  ? const SizedBox.shrink()
                                  : const Divider(),
                            ],
                          );
                        }),
                      ),
                    ),
                    DrawerList(
                      onAddNewItemTap: () async {
                        if (!Constant.isThereLoading) {
                          Constant.isThereLoading = true;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SplashScreen(),
                            ),
                          );
                          widget.scaffoldKey.currentState!.closeEndDrawer();
                          widget.pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear,
                          );
                          Constant.isThereLoading = false;
                        }
                      },
                      users: List.generate(users.length, (index) {
                        StudentModel student = StudentModel.fromMap(
                          jsonDecode(users[index]['data']),
                        );
                        return DrawerListItem(
                          text: '${student.fName} ${student.lName}',
                          onTap: () async {
                            StudentModel student = StudentModel.fromMap(
                              jsonDecode(users[index]['data']),
                            );
                            var res = await setCurrentUser(student);
                            if (res) {
                              Constant.student = student;
                              widget.pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.linear,
                              );
                            }
                            setState(() {});
                            return res;
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Container(
                height: 60.h,
                width: 60.w,
                margin: EdgeInsets.only(top: 11.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.sp),
                    topRight: Radius.circular(20.sp),
                    bottomLeft: Radius.circular(20.sp),
                  ),
                ),
                child: Icon(
                  Mnb.list_caption,
                  color: AppColors.brownColor,
                  size: 25.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
