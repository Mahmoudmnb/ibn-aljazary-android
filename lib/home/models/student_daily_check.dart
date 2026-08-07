import 'dart:convert';

import 'student_monthly_track_model.dart';

class StudentDailyTrackModel {
  final DateTime date;
  final int withOrder;
  final int withoutOrder;
  final int behave;
  final int pointsCount;
  final int quranQuizCount;
  final int hadithQuizCount;
  final String quranProject;
  final List<Progress> quranProgress;
  final List<Progress> quranVocabProgress;
  final List<Progress> hadithProgress;
  final String className;
  final String nots;

  StudentDailyTrackModel({
    required this.date,
    required this.withOrder,
    required this.withoutOrder,
    required this.behave,
    required this.pointsCount,
    required this.quranQuizCount,
    required this.hadithQuizCount,
    required this.quranProgress,
    required this.quranVocabProgress,
    required this.hadithProgress,
    required this.className,
    required this.nots,
    required this.quranProject,
  });

  factory StudentDailyTrackModel.fromRawJson(String str) =>
      StudentDailyTrackModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentDailyTrackModel.fromJson(Map<String, dynamic> json) =>
      StudentDailyTrackModel(
        quranProject: _stringValue(json['quranProjectName']),
        nots: _stringValue(json['nots']),
        date: _dateValue(json["trackDate"]),
        withOrder: _boolIntValue(json["withOrder"]),
        withoutOrder: _boolIntValue(json["withoutOrder"]),
        behave: _intValue(json["behave"]),
        pointsCount: _intValue(json["points_count"] ?? json["pointsCount"]),
        quranQuizCount: _intValue(json["quranQuizCount"]),
        hadithQuizCount: _intValue(json["hadithQuizCount"]),
        quranVocabProgress: _progressList(json["quranVocabProgress"]),
        quranProgress: _progressList(json["quranProgress"]),
        hadithProgress: _progressList(json["hadithProgress"]),
        className: _stringValue(json["classMateName"]),
      );

  static List<Progress> _progressList(dynamic value) {
    if (value is! List) {
      return [];
    }
    return value
        .whereType<Map>()
        .map((x) => Progress.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }

  static int _boolIntValue(dynamic value) {
    return value == true || value == 1 || value == '1' ? 1 : 0;
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _dateValue(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  Map<String, dynamic> toJson() => {
    'nots': nots,
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "withOrder": withOrder,
    "withoutOrder": withoutOrder,
    "behave": behave,
    "points_count": pointsCount,
    "quranQuizCount": quranQuizCount,
    "hadithQuizCount": hadithQuizCount,
    "quranProgress": List<dynamic>.from(quranProgress.map((x) => x.toJson())),
    "hadithProgress": List<dynamic>.from(hadithProgress.map((x) => x.toJson())),
    "quranVocabProgress": List<dynamic>.from(
      quranVocabProgress.map((x) => x.toJson()),
    ),
    "classMateName": className,
    "quranProjectName": quranProject,
  };
}
