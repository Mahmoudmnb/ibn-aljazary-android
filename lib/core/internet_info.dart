import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetInfo {
  static Future<bool> isConnected() async {
    InternetConnectionChecker netInfo =
        InternetConnectionChecker.createInstance();
    bool isConnected = await netInfo.hasConnection;
    return isConnected;
    // await Future.delayed(const Duration(seconds: 2));
    // return true;
  }
}
