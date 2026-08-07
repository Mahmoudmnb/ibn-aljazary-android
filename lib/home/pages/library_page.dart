import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/methods/auth_page_methods.dart';
import '../../auth/pages/splash_screen.dart';
import '../../core/app_colors.dart';
import '../../core/constant.dart';
import '../../core/mnb_icons.dart';
import '../methods/home_page_methods.dart';
import '../models/file_collection.dart';
import '../widgets/drawer.dart';
import '../widgets/home_page_app_bar.dart';
import '../widgets/widgets.dart';
import 'add_student_prays_page.dart';
import 'collection_content.dart';
import 'communication_page.dart';
import 'student_institute_actions_page.dart';

class LibraryPage extends StatefulWidget {
  final List audios;
  final List books;
  final PageController pageController;
  const LibraryPage({
    super.key,
    required this.pageController,
    required this.audios,
    required this.books,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List books;
  late List audios;
  @override
  void initState() {
    books = widget.books;
    audios = widget.audios;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      key: _scaffoldKey,
      endDrawer: RightDrawer(
        pageController: widget.pageController,
        scaffoldKey: _scaffoldKey,
        users: Constant.studentsAccount,
        items: [
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                await getStudentInfo(context);
                _scaffoldKey.currentState?.closeEndDrawer();
              }
            },
            text: 'الملف الشخصي',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                Constant.isThereLoading = true;
                await getStudentDonations(context);
                _scaffoldKey.currentState!.closeEndDrawer();
                Constant.isThereLoading = false;
              }
            },
            text: 'التبرعات',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                _scaffoldKey.currentState?.closeEndDrawer();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddStudentPraysPage(),
                  ),
                );
              }
            },
            text: 'إضافة الصلوات',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                _scaffoldKey.currentState?.closeEndDrawer();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StudentInstituteActionsPage(),
                  ),
                );
              }
            },
            text: 'نشاطات المعهد',
          ),
          DrawerItem(
            onTap: () async {
              if (!Constant.isThereLoading) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CommunicationPage()),
                );
              }
            },
            text: 'للتواصل',
          ),
          DrawerItem(
            textColor: const Color(0xffDE0000),
            onTap: () async {
              if (!Constant.isThereLoading) {
                Constant.isThereLoading = true;
                var res = await deleteStudentAccount(Constant.student!);
                Constant.studentsAccount = res;
                if (res.isEmpty) {
                  if (context.mounted) {
                    Constant.student = null;
                    _scaffoldKey.currentState!.closeEndDrawer();
                    setState(() {});
                  }
                } else {
                  _scaffoldKey.currentState!.closeEndDrawer();
                  widget.pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.linear,
                  );
                }
                Constant.isThereLoading = false;
              }
            },
            text: 'تسجيل الخروج',
          ),
        ],
      ),
      drawer: NotificationDrawer(
        onDrawerClosed: () async {
          await clearAllNotification();
          Constant.notifications = [];
          setState(() {});
        },
      ),
      drawerScrimColor: const Color(0x3f000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomepageAppBar(
              openNotificationDrawerDrawer: () async {
                if (Constant.notifications.isNotEmpty) {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              title: 'المكتبة',
              openDrawer: () async {
                try {
                  Constant.studentsAccount = await getStudentsAccount();
                  if (Constant.student != null &&
                      Constant.studentsAccount.isNotEmpty) {
                    setState(() {});
                    _scaffoldKey.currentState?.openEndDrawer();
                  } else {
                    showLoginRequiredDialog(context, () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                      );
                      setState(() {});
                    });
                  }
                } catch (e) {
                  log(e.toString());
                }
              },
            ),
            SizedBox(height: 30.h),
            LibraryCustomContainer(
              titleTextColor: AppColors.darkBrownColor,
              titleBackgroundColor: AppColors.brownColor1,
              content: List.generate(audios.length, (index) {
                FileCollectionModel fileCollection =
                    FileCollectionModel.fromJson(audios[index]);
                return LibraryCustomContainerItem(
                  text: fileCollection.name,
                  icon: Mnb.microphone_1,
                  onTap: () async {
                    List? audiosRes = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CollectionContent(
                          pageTitle: 'صوتيات',
                          content: audios,
                          selectedCollection: fileCollection,
                        ),
                      ),
                    );
                    if (audiosRes != null) {
                      audios = audiosRes;
                      setState(() {});
                    }
                  },
                );
              }),
              title: 'صوتيات',
              width: 270.w,
            ),
            SizedBox(height: 20.h),
            LibraryCustomContainer(
              titleTextColor: AppColors.darkBrownColor,
              titleBackgroundColor: AppColors.brownColor1,
              content: List.generate(books.length, (index) {
                FileCollectionModel fileCollection =
                    FileCollectionModel.fromJson(books[index]);
                return LibraryCustomContainerItem(
                  text: fileCollection.name,
                  icon: Mnb.book_open,
                  onTap: () async {
                    List? booksRes = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CollectionContent(
                          pageTitle: 'كتب',
                          content: books,
                          selectedCollection: fileCollection,
                        ),
                      ),
                    );
                    if (booksRes != null) {
                      books = booksRes;
                      setState(() {});
                    }
                  },
                );
              }),
              title: 'كتب',
              width: 270.w,
            ),
          ],
        ),
      ),
    );
  }
}
