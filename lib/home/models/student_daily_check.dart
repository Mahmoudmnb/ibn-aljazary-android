import 'dart:convert';

import 'student_monthly_track_model.dart';

class StudentDailyTrackModel {
  final DateTime date;
  final int withOrder;
  final int withoutOrder;
  final int behave;
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
        quranProject: json['quranProjectName'],
        nots: json['nots'] ?? '',
        date: DateTime.parse(json["trackDate"]),
        withOrder: json["withOrder"],
        withoutOrder: json["withoutOrder"],
        behave: json["behave"] ?? 0,
        quranQuizCount: json["quranQuizCount"] ?? 0,
        hadithQuizCount: json["hadithQuizCount"] ?? 0,
        quranVocabProgress: List<Progress>.from(
            json["quranVocabProgress"].map((x) => Progress.fromJson(x))),
        quranProgress: List<Progress>.from(
            json["quranProgress"].map((x) => Progress.fromJson(x))),
        hadithProgress: List<Progress>.from(
            json["hadithProgress"].map((x) => Progress.fromJson(x))),
        className: json["classMateName"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'nots': nots,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "withOrder": withOrder,
        "withoutOrder": withoutOrder,
        "behave": behave,
        "quranQuizCount": quranQuizCount,
        "hadithQuizCount": hadithQuizCount,
        "quranProgress":
            List<dynamic>.from(quranProgress.map((x) => x.toJson())),
        "hadithProgress":
            List<dynamic>.from(hadithProgress.map((x) => x.toJson())),
        "quranVocabProgress":
            List<dynamic>.from(quranVocabProgress.map((x) => x.toJson())),
        "classMateName": className,
        "quranProjectName": quranProject,
      };
}
