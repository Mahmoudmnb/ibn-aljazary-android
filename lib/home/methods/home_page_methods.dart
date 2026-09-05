import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

import '/core/extensions.dart';
import '../../auth/methods/auth_page_methods.dart';
import '../../auth/models/student_model.dart';
import '../../core/constant.dart';
import '../bloc/home_bloc.dart';
import '../models/app_notification.dart';
import '../pages/profile_page.dart';
import '../pages/student_donation_page.dart';
import '../pages/student_grades_page.dart';
import '../pages/student_monthly_track.dart';
import '../pages/student_recalls_page.dart';
import '../pages/student_test_page.dart';

Future<void> addNotification(AppNotification notification) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  List<String> notifications = (sh.getStringList('notifications')) ?? [];
  notifications.add(jsonEncode(notification.toMap()));
  await sh.setStringList('notifications', notifications);
}

Future<List<AppNotification>> getNotifications() async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  List<String> notifications = (sh.getStringList('notifications')) ?? [];
  return notifications
      .map((e) => AppNotification.fromMap(jsonDecode(e)))
      .toList();
}

Future<void> removeNotification(AppNotification notification) async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  List<String> notifications = (sh.getStringList('notifications')) ?? [];
  notifications = notifications
      .where((element) => jsonDecode(element)['id'] != notification.id)
      .toList();
  await sh.setStringList('notifications', notifications);
}

Future<void> clearAllNotification() async {
  SharedPreferences sh = await SharedPreferences.getInstance();
  await sh.remove('notifications');
}

Future<List<String>> getAdvertingImages() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/advertingImage.txt');
  return file.readAsLinesSync();
}

Future<Map?> getBookAudiosCourses(BuildContext context) async {
  Map? temp;
  await checkInternet(() async {
    http.Response res = await http.get(Uri.parse(Constant.getAllCollections));
    if (res.statusCode == 200) {
      Map body = jsonDecode(res.body);
      temp = {
        'audios': body['audios'],
        'books': body['books'],
        'courses': body['courses'],
      };
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return temp;
}

Future<List?> getFiles(String type) async {
  String path = await getDatabasesPath();
  String filesDataBasePath = '$path/files.db';
  Database db = await openDatabase(filesDataBasePath);
  List? data;

  try {
    var res = await db.rawQuery(
      """
      SELECT 
        s.id as sId, s.name as sName, s.type,
        c.id as cId, c.name as cName,
        f.id as fId, f.name as fName, f.url,
        f.isDownloaded, f.localPath
      FROM collection s
      LEFT JOIN collection c ON c.superCollection = s.id
      LEFT JOIN filesCollection f ON c.id = f.collectionId
      WHERE s.superCollection IS NULL AND s.type = ?
      ORDER BY sId, cId
    """,
      [type],
    );

    final Map<int, Map<String, dynamic>> subjects = {};

    for (final row in res) {
      final int sId = row['sId'] as int;
      final int? cId = row['cId'] as int?;
      final int? fId = row['fId'] as int?;

      subjects.putIfAbsent(
        sId,
        () => {
          'sId': sId,
          'name': row['sName'],
          'collections': <int, Map<String, dynamic>>{},
        },
      );

      if (cId != null) {
        final collections =
            subjects[sId]!['collections'] as Map<int, Map<String, dynamic>>;
        collections.putIfAbsent(
          cId,
          () => {
            'cId': cId,
            'name': row['cName'],
            'files': <Map<String, dynamic>>[],
          },
        );

        if (fId != null) {
          (collections[cId]!['files'] as List).add({
            'id': fId,
            'name': row['fName'],
            'url': row['url'],
            'isDownloaded': row['isDownloaded'],
            'localPath': row['localPath'],
          });
        }
      }
    }

    data = subjects.values.map((s) {
      return {
        'sId': s['sId'],
        'name': s['name'],
        'collections': (s['collections'] as Map).values.toList(),
      };
    }).toList();
  } catch (e) {
    log(e.toString());
    data = [];
  }

  return data;
}

Future<List?> getStudentDailyTrack(BuildContext context) async {
  List? temp;
  await checkInternet(() async {
    http.Response res = await http.post(
      Uri.parse(Constant.getStudentDailyTrack),
      body: jsonEncode({'sId': Constant.student!.id}),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      temp = jsonDecode(res.body)['data'];
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return temp;
}

Future getStudentDonations(BuildContext context) async {
  int code = 200;
  await checkInternet(() async {
    http.Response res = await http.post(
      Uri.parse(Constant.getStudentDonations),
      body: jsonEncode({'studentId': Constant.student!.id}),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                StudentDonationPage(studentDonations: jsonDecode(res.body)),
          ),
        );
      }
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      code = 401;
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future getStudentGrades(BuildContext context) async {
  int code = 200;
  await checkInternet(() async {
    http.Response res = await http.get(
      Uri.parse('${Constant.getStudentGrades}/${Constant.student!.id}'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                StudentGradesPage(studentGrades: jsonDecode(res.body)),
          ),
        );
      }
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      code = 401;
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future getStudentInfo(BuildContext context) async {
  int code = 200;
  await checkInternet(() async {
    var res = await http.get(
      Uri.parse('${Constant.getStudentInfo}/${Constant.student!.id}'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      Constant.student = StudentModel.fromMap(jsonDecode(res.body));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfilePage(student: Constant.student!),
        ),
      );
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      code = 401;
    } else {
      ToastContext().init(context);
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future getStudentMonthlyProgress(BuildContext context) async {
  int code = 200;
  await checkInternet(() async {
    http.Response res = await http.get(
      Uri.parse(
        '${Constant.getStudentMonthlyProgress}/${Constant.student!.id}',
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                StudentMonthlyTrack(studentTracks: jsonDecode(res.body)),
          ),
        );
      }
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      code = 401;
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future<int> getStudentRecalls(BuildContext context) async {
  int code = 200;
  await checkInternet(() async {
    http.Response res = await http.get(
      Uri.parse('${Constant.getStudentRecalls}/${Constant.student!.id}'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                StudentRecallsPage(studentRecalls: jsonDecode(res.body)),
          ),
        );
      }
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      code = 401;
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future<int> getStudentTest({
  required BuildContext context,
  required String testType,
  String? date,
}) async {
  int code = 200;
  await checkInternet(() async {
    http.Response res = await http.post(
      Uri.parse(Constant.getStudentMarks),
      body: jsonEncode({
        'studentId': Constant.student!.id,
        'testType': testType,
      }),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StudentTestPage(
              testType: testType,
              studentTests: jsonDecode(res.body),
            ),
          ),
        );
      }
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
      context.read<HomeBloc>().add(RefreshMainPage());
      code = 401;
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return code;
}

Future<Map?> getStudentWeaklyTrack(BuildContext context) async {
  Map? temp;
  DateTime startWeekDate = DateTime.now();
  for (;;) {
    if (startWeekDate.weekday == DateTime.friday) {
      break;
    }
    startWeekDate = startWeekDate.subtract(const Duration(days: 1));
  }
  await checkInternet(() async {
    var res = await http.post(
      Uri.parse(Constant.getStudentDailyProgress),
      body: jsonEncode({
        'sId': Constant.student!.id,
        'startDate': startWeekDate.toCustomString(),
      }),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 200) {
      temp = jsonDecode(res.body);
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
    } else {
      Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
    }
  }, context);
  return temp;
}

Future<bool> updateStudentTrackHomework({
  required BuildContext context,
  required int trackId,
  required int studentId,
  required String homework,
}) async {
  bool isSuccess = false;
  await checkInternet(() async {
    var res = await http.put(
      Uri.parse(Constant.updateStudentTrackHomework),
      body: jsonEncode({
        'id': trackId,
        'studentId': studentId,
        'homework': homework,
      }),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 201) {
      Toast.show('تم حفظ المعاهدة المنزلية', duration: Toast.lengthLong);
      isSuccess = true;
    } else if (res.statusCode == 405 || res.statusCode == 401) {
      await removeUnauthorizedUser();
    } else {
      final message =
          jsonDecode(res.body)['message'] ?? 'خطأ غير معروف حاول ثانية';
      Toast.show(message.toString(), duration: Toast.lengthLong);
    }
  }, context);
  return isSuccess;
}

Future<void> updateAdvertingImages(String images) async {
  try {
    Directory dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/advertingImage.txt');
    file.writeAsStringSync(images);
  } catch (e) {
    log(e.toString());
  }
}

Future<void> updateFile(String localPath, int id) async {
  String path = await getDatabasesPath();
  String filesDataBasePath = '$path/files.db';
  Database db = await openDatabase(filesDataBasePath);
  await db.rawUpdate(
    "update filesCollection set isDownloaded=1,localPath='$localPath' where id = $id",
  );
}

Future<void> updateStudentProfile(Map studentData) async {
  List studentsAccounts = await getStudentsAccount();
  for (var student in studentsAccounts) {
    StudentModel studentModel = StudentModel.fromMap(
      jsonDecode(student['data']),
    );
    StudentModel newStudentData = StudentModel.fromMap(
      jsonDecode(student['data']),
    );

    if (studentModel.id.toString() == studentData['studentId'].toString()) {
      if (studentData['studentName'] != null) {
        newStudentData.fName = studentData['studentName'];
      }
      if (studentData['className'] != null) {
        newStudentData.className = studentData['className'];
      }
    }
    await updateStudentAccount(studentModel, newStudentData);
    if (Constant.student?.id.toString() ==
        studentData['studentId'].toString()) {
      if (studentData['studentName'] != null) {
        Constant.student?.fName = studentData['studentName'];
      }
      if (studentData['className'] != null) {
        Constant.student?.className = studentData['className'];
      }
    }
  }
}

Future<void> updateStudentRanking({
  required String studentId,
  required String level,
  required String score,
  required String year,
  required String month,
  required String classStudentCount,
}) async {
  try {
    List students = await getStudentsAccount();

    for (var i = 0; i < students.length; i++) {
      StudentModel student = StudentModel.fromMap(
        jsonDecode(students[i]['data']),
      );
      if (student.id.toString() == studentId) {
        student.rankLevel = level;
        student.rankScore = score.toString();
        student.rankYear = year;
        student.rankMonth = month;
        student.classStudentCount = classStudentCount;
        String path = await getDatabasesPath();
        String usersPath = '$path/usersDataBase.db';
        Database db = await openDatabase(usersPath);
        await db.rawQuery("update users set data = ? where id = ?", [
          jsonEncode(student.toMap()),
          students[i]['id'],
        ]);
        if (Constant.student!.id.toString() == studentId) {
          Constant.student = student;
        }
        break;
      }
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> removeUnauthorizedUser() async {
  var res = await deleteStudentAccount(Constant.student!);
  Constant.studentsAccount = res;
  if (res.isEmpty) {
    Constant.student = null;
  }
}
