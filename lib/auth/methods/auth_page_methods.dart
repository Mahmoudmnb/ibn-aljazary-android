import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';

import '../../core/constant.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/methods/home_page_methods.dart';
import '../../home/pages/main_page.dart';
import '../models/student_model.dart';

Future<bool> addStudentAccount(StudentModel student) async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);
    await db.rawUpdate("update users set isSelected=0");
    await db.rawInsert(
      "insert into users (data,isSelected)values('${jsonEncode(student.toMap())}',1)",
    );
    return true;
  } catch (e) {
    log(e.toString());
    return false;
  }
}

Future<bool> createFileDataBase(BuildContext context) async {
  bool isSuccess = false;
  String path = await getDatabasesPath();
  String filesDataBasePath = '$path/files.db';
  try {
    var tablesName = await getTablesNameInDataBase('files.db');
    if (tablesName.isEmpty) {
      var db = await openDatabase(filesDataBasePath);
      db.execute('''CREATE TABLE collection (
                id int(11) NOT NULL,
                name text DEFAULT NULL,
                superCollection int(11) REFERENCES collection(id) DEFAULT NULL ,
                type text DEFAULT NULL
              )
              ''');
      db.execute('''
                     CREATE TABLE filesCollection (
                                        id int(11) NOT NULL,
                                        name text DEFAULT NULL,
                                        url text DEFAULT NULL,
                                        collectionId int(11) REFERENCES collection(id) DEFAULT NULL,
                                        isDownloaded boolean DEFAULT 0,
                                        localPath text
                                      );
                   ''');
      log('files DataBase created');
      if (context.mounted) {
        isSuccess = await importFilesDataBase(context);
        if (!isSuccess) {
          await db.execute('''
                     DROP TABLE filesCollection
                   ''');
          await db.execute('''
                     DROP TABLE collection
                   ''');
        }
      }
    } else {
      isSuccess = true;
    }
  } catch (e) {
    log(e.toString());
  }
  return isSuccess;
}

Future<bool> createUsersTable(BuildContext context) async {
  bool isSuccess = false;
  String path = await getDatabasesPath();
  String filesDataBasePath = '$path/usersDataBase.db';
  try {
    var tableNames = await getTablesNameInDataBase("usersDataBase.db");
    if (tableNames.isEmpty) {
      var db = await openDatabase(filesDataBasePath);
      await db.execute('''CREATE TABLE users (
                id int primary key,
                data text DEFAULT NULL,
                isSelected boolean)
              ''');
    }
    isSuccess = true;
    log('users DataBase created');
  } catch (e) {
    log(e.toString());
  }
  return isSuccess;
}

Future<List> deleteStudentAccount(StudentModel student) async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);
    await db.rawDelete(
      "delete from users where data='${jsonEncode(student.toMap())}'",
    );
    removeToken(student.id.toString());
    var t = await getStudentsAccount();
    if (t.isNotEmpty) {
      await db.rawUpdate(
        "update users set isSelected=1 where data='${t.first['data']}'",
      );
      Constant.student = StudentModel.fromMap(jsonDecode(t.first['data']));
    }
    return await getStudentsAccount();
  } catch (e) {
    log(e.toString());
    return [];
  }
}

Future<void> storeToken({required String token, required String id}) async {
  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
  );
  storage.write(key: id, value: token);
}

Future<String?> getToken(String id) async {
  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
  );
  return storage.read(key: id);
}

Future removeToken(String id) async {
  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  FlutterSecureStorage storage = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
  );
  await storage.delete(key: id);
}

Future<StudentModel?> getCurrentStudentAccount() async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);
    List res = await db.rawQuery("select * from users where isSelected=1");
    if (res.isNotEmpty) {
      return StudentModel.fromMap(jsonDecode(res.first['data']));
    }
    return null;
  } catch (e) {
    log(e.toString());
    return null;
  }
}

Future<String?> getDeviceId() async {
  final _mobileDeviceIdentifier = await MobileDeviceIdentifier().getDeviceId();
  return _mobileDeviceIdentifier;
}

Future<List> getStudentsAccount() async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);
    List res = await db.rawQuery(
      "select * from users order by isSelected Desc",
    );
    return res;
  } catch (e) {
    log(e.toString());
    return [];
  }
}

Future<List> getTablesNameInDataBase(String dataBaseName) async {
  List data = [];
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/$dataBaseName';
    Database db = await openDatabase(usersPath);
    data = await db.rawQuery("""
              SELECT name FROM sqlite_master WHERE type='table' and name !='android_metadata';
              """);
  } catch (e) {
    log(e.toString());
  }
  return data;
}

Future<String?> getFirebaseTokenToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  return token;
}

Future<bool> importFilesDataBase(BuildContext context) async {
  ToastContext().init(context);
  bool isSuccess = false;
  await checkInternet(() async {
    http.Response res = await http.get(
      Uri.parse(Constant.exportFileDataBase),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
    if (res.statusCode == 200) {
      String path = await getDatabasesPath();
      String filesDataBasePath = '$path/files.db';
      Database db = await openDatabase(filesDataBasePath);
      var body = jsonDecode(res.body);
      var collection = body['collectionTable'];
      var filesCollection = body['filesCollectionTable'];
      await db.transaction((txn) async {
        for (var element in collection) {
          String value =
              "${element['id']},'${element['name']}',${element['superCollection']},'${element['type']}'";
          await txn.rawInsert("insert into collection values($value)");
        }
        for (var element in filesCollection) {
          String value =
              "${element['id']},'${element['name']}','${element['url']}',${element['collectionId']},0,null";
          await txn.rawInsert("insert into filesCollection values($value)");
        }
      });
      SharedPreferences sh = await SharedPreferences.getInstance();
      await sh.setString(
        'lastUpdateDate',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
      isSuccess = true;
    } else {
      Toast.show('حصل خظأ غير متوقع', duration: Toast.lengthLong);
    }
  }, context);
  return isSuccess;
}

Future<void> login({
  required GlobalKey<FormState> formKey,
  required String id,
  required String email,
  required String password,
  required BuildContext context,
}) async {
  if (formKey.currentState!.validate()) {
    ToastContext().init(context);
    await checkInternet(() async {
      List currentStudentAccounts =
          context.mounted && Navigator.of(context).canPop()
          ? await getStudentsAccount()
          : [];
      if (currentStudentAccounts.isNotEmpty) {
        for (var element in currentStudentAccounts) {
          if (StudentModel.fromMap(jsonDecode(element['data'])).id.toString() ==
              id) {
            Toast.show(
              'هذا الطالب مسجل مسبقاً في هذا التطبيق',
              duration: Toast.lengthLong,
            );
            return false;
          }
        }
      }
      String? deviceId = await getDeviceId();
      String? firebaseToken = await getFirebaseTokenToken();
      http.Response res = await http.post(
        Uri.parse(Constant.studentLogIn),
        body: jsonEncode({
          'id': id,
          'email': email,
          'password': password,
          'deviceId': deviceId,
          'firebaseToken': firebaseToken,
        }),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      if (context.mounted) {
        if (res.statusCode == 200) {
          var names = await getTablesNameInDataBase('files.db');
          bool isFileTableCreatedSuccessfully = context.mounted && names.isEmpty
              ? await createFileDataBase(context)
              : true;
          bool isUsersTableCreatedSuccessfully =
              context.mounted && names.isEmpty
              ? await createUsersTable(context)
              : true;
          if (isFileTableCreatedSuccessfully &&
              isUsersTableCreatedSuccessfully) {
            final responseData = jsonDecode(res.body);
            final token = responseData['token']?.toString();
            if (token == null || token.isEmpty) {
              Toast.show(
                'حصل خظأ غير متوقع',
                duration: Toast.lengthLong,
              );
              log('Login response did not include a token: ${res.body}');
              return false;
            }
            Constant.student = StudentModel.fromMap(responseData);
            await storeToken(
              token: token,
              id: Constant.student!.id.toString(),
            );
            await addStudentAccount(Constant.student!);
            String urls = '';
            final imgUrls = responseData['imgUrls'];
            if (imgUrls is List) {
              for (var element in imgUrls) {
                urls += '\n$element';
              }
              urls = urls.replaceFirst('\n', '');
              await updateAdvertingImages(urls);
            }
            Constant.studentsAccount = await getStudentsAccount();
            SharedPreferences sh = await SharedPreferences.getInstance();
            await sh.setBool('isFirstTime', false);
            if (context.mounted) {
              Navigator.of(context).canPop()
                  ? Navigator.of(context).pop()
                  : Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => HomeBloc(),
                          child: Builder(
                            builder: (context) {
                              return MainPage(student: Constant.student!);
                            },
                          ),
                        ),
                      ),
                    );
            }
          } else {
            Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
          }
        } else if (res.statusCode == 400) {
          Toast.show(
            jsonDecode(res.body)['message'],
            duration: Toast.lengthLong,
          );
        } else {
          Toast.show('خطأ غير معروف حاول ثانية', duration: Toast.lengthLong);
        }
      }
    }, context);
  }
}

Future<bool> logout({required int id, required BuildContext context}) async {
  bool isSuccess = false;
  await checkInternet(() async {
    String? deviceId = await getDeviceId();
    http.Response res = await http.post(
      Uri.parse(Constant.studentLogout),
      body: jsonEncode({'id': id, 'deviceId': deviceId}),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization":
            "Bearer ${await (getToken(Constant.student!.id.toString()))}",
      },
    );
    if (res.statusCode == 201) {
      removeToken(id.toString());
      isSuccess = true;
    } else {
      ToastContext().init(context);
      Toast.show('حصل خطأ غير متوقع', duration: Toast.lengthLong);
    }
  }, context);
  return isSuccess;
}

Future<bool> setCurrentUser(StudentModel student) async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);
    await db.rawDelete("update users set isSelected=0");
    await db.rawDelete(
      "update users set isSelected=1 where data='${jsonEncode(student.toMap())}'",
    );
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> skipLogIn(BuildContext context) async {
  var names = await getTablesNameInDataBase('files.db');
  SharedPreferences sh = await SharedPreferences.getInstance();
  if (names.isEmpty) {
    bool res = await createFileDataBase(context);
    bool res1 = await createUsersTable(context);
    if (res && res1) {
      await sh.setBool('isFirstTime', false);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    }
  } else {
    await sh.setBool('isFirstTime', false);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
  }
}

Future<void> updateFilesDataBase(Map data) async {
  try {
    String path = await getDatabasesPath();
    String filesDataBasePath = '$path/files.db';
    Database db = await openDatabase(filesDataBasePath);
    if (data['type'] == 'file') {
      if (data['method'] == 'add') {
        await db.rawInsert("""
            insert into filesCollection values (${data['id']},'${data['name']}','${data['url']}',${data['collectionId']},0,null)
                """);
      } else if (data['method'] == 'update') {
        List<Map<String, Object?>> row = await db.query(
          'filesCollection',
          where: 'id=${data['id']}',
        );
        if (row.first['url'] != data['url'] && row.first['localPath'] != null) {
          await File(row.first['localPath'].toString()).delete();
          db.rawUpdate(
            "UPDATE filesCollection set name='${data['name']}',url='${data['url']}',isDownloaded=0,localPath=null WHERE id=${data['id']}",
          );
        } else {
          db.rawUpdate(
            "UPDATE filesCollection set name='${data['name']}',url='${data['url']}' WHERE id=${data['id']}",
          );
        }
      } else if (data['method'] == 'delete') {
        await db.delete('filesCollection', where: 'id=${data['id']}');
      }
    } else {
      if (data['method'] == 'add') {
        String? superCollection = data['superCollection'] == ''
            ? null
            : data['superCollection'];
        String? type = data['collectionType'] == ''
            ? null
            : "'" + data['collectionType'] + "'";

        await db.rawInsert("""
             insert into collection values (${data['id']},'${data['name']}',$superCollection,$type)
                  """);
      } else if (data['method'] == 'update') {
        db.rawUpdate(
          "UPDATE collection set name='${data['name']}' WHERE id=${data['id']}",
        );
      } else if (data['method'] == 'delete') {
        await db.delete('collection', where: 'id=${data['id']}');
      }
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<bool> updateStudentAccount(
  StudentModel student,
  StudentModel newStudentData,
) async {
  try {
    String path = await getDatabasesPath();
    String usersPath = '$path/usersDataBase.db';
    Database db = await openDatabase(usersPath);

    await db.rawUpdate(
      "UPDATE users SET data='${jsonEncode(newStudentData.toMap())}'  where data='${jsonEncode(student.toMap())}'",
    );
    return true;
  } catch (e) {
    log(e.toString());
    return false;
  }
}
