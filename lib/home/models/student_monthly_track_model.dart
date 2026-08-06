import 'dart:convert';

class StudentMonthlyTrackModel {
  final String date;
  final int offDays;
  final double behave;
  final int quranQuizCount;
  final int hadithQuizCount;
  final int onDays;
  final List<Progress> quranProgress;
  final List<Progress> hadithProgress;
  final String className;
  StudentMonthlyTrackModel({
    required this.date,
    required this.offDays,
    required this.behave,
    required this.quranQuizCount,
    required this.hadithQuizCount,
    required this.onDays,
    required this.quranProgress,
    required this.hadithProgress,
    required this.className,
  });

  factory StudentMonthlyTrackModel.fromRawJson(String str) =>
      StudentMonthlyTrackModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentMonthlyTrackModel.fromJson(Map<String, dynamic> json) =>
      StudentMonthlyTrackModel(
        date: json["date"],
        offDays: json["offDays"],
        behave: json["behave"] * 1.0,
        quranQuizCount: json["quranQuizCount"],
        hadithQuizCount: json["hadithQuizCount"],
        onDays: json["onDays"],
        quranProgress: List<Progress>.from(
            json["quranProgress"].map((x) => Progress.fromJson(x))),
        hadithProgress: List<Progress>.from(
            json["hadithProgress"].map((x) => Progress.fromJson(x))),
        className: json["className"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "offDays": offDays,
        "behave": behave,
        "quranQuizCount": quranQuizCount,
        "hadithQuizCount": hadithQuizCount,
        "onDays": onDays,
        "quranProgress":
            List<dynamic>.from(quranProgress.map((x) => x.toJson())),
        "hadithProgress":
            List<dynamic>.from(hadithProgress.map((x) => x.toJson())),
        "className": className,
      };
}

class Progress {
  final String name;
  final int pagesNum;

  Progress({
    required this.name,
    required this.pagesNum,
  });

  factory Progress.fromRawJson(String str) =>
      Progress.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        name: json["name"].toString(),
        pagesNum: json["pagesCount"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "pagesCount": pagesNum,
      };
}
