import 'dart:convert';

class StudentTestModel {
  final String testSubject;
  final List<Datum> data;

  StudentTestModel({
    required this.testSubject,
    required this.data,
  });

  factory StudentTestModel.fromRawJson(String str) =>
      StudentTestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentTestModel.fromJson(Map<String, dynamic> json) =>
      StudentTestModel(
        testSubject: json["testSubject"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "testSubject": testSubject,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  final int id;
  final String testTypeName;
  final int attrId;
  final String attName;
  final String dataType;
  final int isRequired;
  final String mark;

  Datum({
    required this.id,
    required this.testTypeName,
    required this.attrId,
    required this.attName,
    required this.dataType,
    required this.isRequired,
    required this.mark,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        testTypeName: json["testTypeName"],
        attrId: json["attrId"],
        attName: json["attName"],
        dataType: json["dataType"],
        isRequired: json["isRequired"],
        mark: json["mark"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "testTypeName": testTypeName,
        "attrId": attrId,
        "attName": attName,
        "dataType": dataType,
        "isRequired": isRequired,
        "mark": mark,
      };
}
