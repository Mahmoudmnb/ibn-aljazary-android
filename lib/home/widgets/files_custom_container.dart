import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../methods/home_page_methods.dart';
import '../models/file_collection.dart';
import 'widgets.dart';

class FilesCustomContainer extends StatefulWidget {
  final List items;
  final FileCollectionModel selectedCollection;
  final Function(FileCollectionModel) onSelectItem;
  final String listTitle;
  const FilesCustomContainer({
    super.key,
    required this.listTitle,
    required this.onSelectItem,
    required this.selectedCollection,
    required this.items,
  });

  @override
  State<FilesCustomContainer> createState() => _DateContainerState();
}

class _DateContainerState extends State<FilesCustomContainer> {
  bool isMenuOpened = false;
  bool isLoading = false;
  late FileCollectionModel selectedCollection;
  List items = [];
  @override
  void initState() {
    selectedCollection = widget.selectedCollection;
    for (var element in widget.items) {
      if (element['name'] != selectedCollection.name) {
        items.add(element);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffE5F2F3)),
      ),
      child: Builder(builder: (context) {
        return TapRegion(
          onTapOutside: (event) {
            isMenuOpened = false;
            setState(() {});
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              GestureDetector(
                onTap: () async {
                  isMenuOpened = !isMenuOpened;
                  setState(() {});
                },
                child: Container(
                  height: 36.h,
                  width: 275.w,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                      color: AppColors.greyBrownColor,
                      borderRadius: BorderRadius.circular(16.sp),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0121eac0), blurRadius: 7.1)
                      ]),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !isLoading
                          ? Text(
                              selectedCollection.name,
                              style: TextStyle(
                                  fontFamily: 'Almarai',
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                    ],
                  ),
                ),
              ),
              CustomList(
                title: widget.listTitle,
                borderRadius: BorderRadius.circular(20.sp),
                maxHight: 160.h,
                width: 275.w,
                topOffset: 40.h,
                titleColor: AppColors.darkBrownColor,
                isMenuOpened: isMenuOpened,
                items: List.generate(items.length, (index) {
                  return CustomListItem(
                      borderRadius: BorderRadius.circular(16.sp),
                      onTap: () async {
                        if (!isLoading) {
                          isLoading = true;
                          setState(() {});
                          selectedCollection =
                              FileCollectionModel.fromJson(items[index]);
                          items = [];
                          var currentItems = await getFiles(widget.listTitle);
                          for (var element in currentItems!) {
                            if (element['name'] != selectedCollection.name) {
                              items.add(element);
                            }
                          }
                          widget.onSelectItem(selectedCollection);
                          isMenuOpened = false;
                          isLoading = false;
                          setState(() {});
                        }
                      },
                      text: items[index]['name'],
                      backgroundColor: AppColors.appBarColor,
                      textColor: AppColors.brownColor);
                }),
              )
            ],
          ),
        );
      }),
    );
  }
}
