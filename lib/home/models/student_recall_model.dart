import 'dart:convert';

class StudentRecallModel {
  final int id;
  final String cause;
  final DateTime recallDate;
  final int isChecked;
  final String checkDate;
  final String checkerName;
  final String nots;
  final int studentId;

  StudentRecallModel({
    required this.id,
    required this.cause,
    required this.recallDate,
    required this.isChecked,
    required this.checkDate,
    required this.checkerName,
    required this.nots,
    required this.studentId,
  });

  factory StudentRecallModel.fromRawJson(String str) =>
      StudentRecallModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentRecallModel.fromJson(Map<String, dynamic> json) =>
      StudentRecallModel(
        id: json["id"],
        cause: json["cause"],
        recallDate: DateTime.parse(json["recallDate"]),
        isChecked: json["isChecked"],
        checkDate: json["checkDate"] ?? '',
        checkerName: json["checkerName"]??'',
        nots: json["nots"]??'',
        studentId: json["studentId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cause": cause,
        "recallDate":
            "${recallDate.year.toString().padLeft(4, '0')}-${recallDate.month.toString().padLeft(2, '0')}-${recallDate.day.toString().padLeft(2, '0')}",
        "isChecked": isChecked,
        "checkDate": checkDate,
        "checkerName": checkerName,
        "nots": nots,
        "studentId": studentId,
      };
}
