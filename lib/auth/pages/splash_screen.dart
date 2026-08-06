import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/auth_from.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late TextEditingController emailCon;
  late TextEditingController passwordCon;
  late TextEditingController studentIdCon;
  late FocusNode emailNode;
  late FocusNode passwordNode;
  late FocusNode idNode;
  late GlobalKey<FormState> formKey;
  Duration duration = Duration(milliseconds: 800);

  bool logoOpacity = true;
  bool showAuth = false;
  double topRightLogoRightPadding = -150;
  double topRightLogoTopPadding = -150;

  Future<void> initAnimation(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    topRightLogoRightPadding = 0;
    topRightLogoTopPadding = 0;
    logoOpacity = false;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 1000));
    showAuth = true;
    setState(() {});
  }

  @override
  void initState() {
    emailCon = TextEditingController();
    passwordCon = TextEditingController();
    studentIdCon = TextEditingController();
    formKey = GlobalKey<FormState>();
    emailNode = FocusNode();
    passwordNode = FocusNode();
    idNode = FocusNode();
    initAnimation(context);
    super.initState();
  }

  @override
  void dispose() {
    emailCon.dispose();
    passwordCon.dispose();
    studentIdCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          width: 323.w,
          height: 700.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                top: topRightLogoTopPadding.h,
                right: topRightLogoRightPadding.w,
                child: AnimatedRotation(
                  duration: duration,
                  turns: topRightLogoRightPadding != 0 ? 0.2.sp : 0,
                  child: Image.asset(
                    'assets/images/top_right_logo.png',
                    width: 100.w,
                  ),
                ),
                duration: duration,
              ),
              AnimatedPositioned(
                bottom: topRightLogoTopPadding.h,
                left: topRightLogoRightPadding.w,
                child: AnimatedRotation(
                  duration: duration,
                  turns: topRightLogoRightPadding != 0 ? -0.2.sp : 0,
                  child: Image.asset(
                    'assets/images/bottom_left_logo.png',
                    width: 100.w,
                  ),
                ),
                duration: duration,
              ),
              AnimatedPositioned(
                top: showAuth ? 60.h : 220.h,
                child: AnimatedOpacity(
                  opacity: logoOpacity ? 0 : 1,
                  duration: duration,
                  child: AnimatedContainer(
                    width: 190.w,
                    height: showAuth ? 173.h : 223.h,
                    duration: duration,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                duration: duration,
              ),
              AnimatedPositioned(
                top: 240.h,
                duration: duration,
                child: AnimatedOpacity(
                  opacity: showAuth ? 1 : 0,
                  duration: duration,
                  child: AuthForm(
                    formKey: formKey,
                    emailCon: emailCon,
                    passwordCon: passwordCon,
                    studentIdCon: studentIdCon,
                    emailNode: emailNode,
                    passwordNode: passwordNode,
                    idNode: idNode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
