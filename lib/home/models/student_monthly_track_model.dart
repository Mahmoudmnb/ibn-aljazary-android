import 'dart:convert';

class StudentMonthlyTrackModel {
  final String date;
  final int offDays;
  final int pointsCount;
  final int? rankPercent;
  final String rankValue;
  final int quranQuizCount;
  final int hadithQuizCount;
  final int onDays;
  final List<Progress> quranProgress;
  final List<Progress> hadithProgress;
  final String className;
  StudentMonthlyTrackModel({
    required this.date,
    required this.offDays,
    required this.pointsCount,
    required this.rankPercent,
    required this.rankValue,
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
        date: _stringValue(json["date"]),
        offDays: _intValue(json["offDays"]),
        pointsCount: _intValue(json["points_count"] ?? json["pointsCount"]),
        rankPercent: _nullableIntValue(
          json["rankPercent"] ?? json["rank_percentage"] ?? json["rank"],
        ),
        rankValue: _stringValue(json["rankValue"]),
        quranQuizCount: _intValue(json["quranQuizCount"]),
        hadithQuizCount: _intValue(json["hadithQuizCount"]),
        onDays: _intValue(json["onDays"]),
        quranProgress: _progressList(json["quranProgress"]),
        hadithProgress: _progressList(json["hadithProgress"]),
        className: _stringValue(json["className"]),
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

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableIntValue(dynamic value) {
    if (value == null || value == '') {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static List<int> _intList(dynamic value) {
    if (value is! List) {
      return [];
    }
    return value.map(_intValue).where((item) => item > 0).toList();
  }

  Map<String, dynamic> toJson() => {
    "date": date,
    "offDays": offDays,
    "points_count": pointsCount,
    "rankPercent": rankPercent,
    "rankValue": rankValue,
    "quranQuizCount": quranQuizCount,
    "hadithQuizCount": hadithQuizCount,
    "onDays": onDays,
    "quranProgress": List<dynamic>.from(quranProgress.map((x) => x.toJson())),
    "hadithProgress": List<dynamic>.from(hadithProgress.map((x) => x.toJson())),
    "className": className,
  };
}

class Progress {
  final String name;
  final int pagesNum;
  final List<int> pageNumbers;

  Progress({
    required this.name,
    required this.pagesNum,
    required this.pageNumbers,
  });

  factory Progress.fromRawJson(String str) =>
      Progress.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
    name: json["name"].toString(),
    pagesNum: StudentMonthlyTrackModel._intValue(json["pagesCount"]),
    pageNumbers: StudentMonthlyTrackModel._intList(
      json["pageNumbers"] ?? json["pagesNumbers"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "pagesCount": pagesNum,
    "pageNumbers": pageNumbers,
  };
}
