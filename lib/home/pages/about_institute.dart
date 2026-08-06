import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/data_pages_app_bar.dart';

class AboutInstitute extends StatelessWidget {
  final String aboutText;
  const AboutInstitute({super.key, required this.aboutText});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF9F9F9),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DataPagesAppBar(
                onBackButtonPressed: () {
                  Navigator.of(context).pop();
                },
                title: 'نبذة عن المعهد',
                height: 60,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  aboutText,
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: 'Almarai', fontSize: 20.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
