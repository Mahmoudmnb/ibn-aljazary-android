import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../models/file_collection.dart';

class PDFScreen extends StatefulWidget {
  final FileElement file;

  const PDFScreen({super.key, required this.file});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool enableNightMode = false;
  Future<Map> getPageIndex() async {
    var f = await _controller.future;
    int currentPage = await f.getCurrentPage() ?? 0;
    int pageCount = await f.getPageCount() ?? 0;
    return {'pageIndex': currentPage, 'pageCount': pageCount};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brownBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Text(
          widget.file.name,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 15.sp,
            color: AppColors.brownColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.darkBrownColor,
            size: 25.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showMenu(
                color: Colors.white,
                context: context,
                position: RelativeRect.fromLTRB(50, 80.h, 0, 50),
                items: [
                  PopupMenuItem(
                    onTap: () async {
                      var res = await getPageIndex();
                      int pageIndex = res['pageIndex'];
                      int pageCount = res['pageCount'];
                      GlobalKey<FormState> formKey = GlobalKey<FormState>();
                      TextEditingController controller =
                          TextEditingController();
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.white2,
                            title: const Text(
                              'الذهاب الى',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontFamily: 'Almarai'),
                            ),
                            titleTextStyle: TextStyle(
                              color: AppColors.green,
                              fontFamily: 'Almarai',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            content: Form(
                              key: formKey,
                              child: Container(
                                width: 250.w,
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                color: AppColors.white2,
                                child: Row(
                                  children: [
                                    Text(
                                      '($pageIndex - $pageCount)',
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontFamily: 'Almarai',
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: TextFormField(
                                        onEditingComplete: () async {
                                          var res = await _controller.future;
                                          res.setPage(
                                            int.parse(controller.text),
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        autofocus: true,
                                        controller: controller,
                                        cursorColor: AppColors.green,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        keyboardType:
                                            const TextInputType.numberWithOptions(),
                                        textDirection: TextDirection.rtl,
                                        decoration: const InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.green,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: AppColors.green,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'الغاء',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontFamily: 'Almarai',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (controller.text.isNotEmpty) {
                                    var res = await _controller.future;
                                    res.setPage(int.parse(controller.text));
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                child: Text(
                                  'موافق',
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontFamily: 'Almarai',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        'الذهاب الى صفحة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColors.green,
                          fontFamily: 'Almarai',
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            icon: Icon(
              Icons.more_vert,
              color: AppColors.darkBrownColor,
              size: 25.sp,
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.file.localPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            fitEachPage: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            nightMode: enableNightMode,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (pages) {
              setState(() {
                pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              log(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              log('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              log('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              log('page change: $page/$total');
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      )
                    : Container()
              : Center(child: Text(errorMessage)),
        ],
      ),
      floatingActionButton: FutureBuilder(
        future: getPageIndex(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '(${snapshot.data!['pageIndex']} / ${snapshot.data!['pageCount']})',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
