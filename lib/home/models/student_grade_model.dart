import 'dart:convert';

class StudentGradeModel {
  final int id;
  final String gradeName;
  final DateTime originalDate;
  final int mark;
  final String result;
  final int isReceived;
  final DateTime? givenDate;
  final String nots;
  final String gradeType;
  final String gradeBranch;
  final int studentId;
  final String fName;
  final String lName;

  StudentGradeModel({
    required this.id,
    required this.gradeName,
    required this.originalDate,
    required this.mark,
    required this.result,
    required this.isReceived,
    required this.givenDate,
    required this.nots,
    required this.gradeType,
    required this.gradeBranch,
    required this.studentId,
    required this.fName,
    required this.lName,
  });

  factory StudentGradeModel.fromRawJson(String str) =>
      StudentGradeModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentGradeModel.fromJson(Map<String, dynamic> json) =>
      StudentGradeModel(
        id: json["id"],
        gradeName: json["name"],
        originalDate: DateTime.parse(json["originalDate"]),
        mark: json["mark"],
        result: json["result"],
        isReceived: json["isReceived"] ?? 0,
        givenDate: json["givenDate"] == null
            ? null
            : DateTime.parse(json["givenDate"]),
        nots: json["nots"] ?? '',
        gradeType: json["gradeTypeName"],
        gradeBranch: json["gradeBranchName"],
        studentId: json["studentId"],
        fName: json["fName"],
        lName: json["lName"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": gradeName,
        "originalDate":
            "${originalDate.year.toString().padLeft(4, '0')}-${originalDate.month.toString().padLeft(2, '0')}-${originalDate.day.toString().padLeft(2, '0')}",
        "mark": mark,
        "result": result,
        "isReceived": isReceived,
        "givenDate":
            "${givenDate?.year.toString().padLeft(4, '0')}-${givenDate?.month.toString().padLeft(2, '0')}-${givenDate?.day.toString().padLeft(2, '0')}",
        "nots": nots,
        "gradeTypeName": gradeType,
        "gradeBranchName": gradeBranch,
        "studentId": studentId,
        "fName": fName,
        "lName": lName,
      };
}
