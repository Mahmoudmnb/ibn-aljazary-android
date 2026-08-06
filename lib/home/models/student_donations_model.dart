import 'dart:convert';

class StudentDonationsModel {
  final int id;
  final int rowIgnore;
  final String donationDate;
  final String payDate;
  final int amount;
  final String nots;
  final int donationAmount;
  final String monthLast;
  final int totalDonation;
  final int numOfMonths;
  final String totalLast;
  final double donations;

  StudentDonationsModel({
    required this.id,
    required this.donations,
    required this.rowIgnore,
    required this.donationDate,
    required this.payDate,
    required this.amount,
    required this.nots,
    required this.donationAmount,
    required this.monthLast,
    required this.totalDonation,
    required this.numOfMonths,
    required this.totalLast,
  });

  factory StudentDonationsModel.fromRawJson(String str) =>
      StudentDonationsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory StudentDonationsModel.fromJson(Map<String, dynamic> json) =>
      StudentDonationsModel(
        donations: json['donations'] + 0.0,
        id: json["id"],
        rowIgnore: json["rowIgnore"],
        donationDate: json["donationDate"],
        payDate: json["payDate"] ?? '',
        amount: json["amount"],
        nots: json["nots"] ?? '',
        donationAmount: json["donationAmount"]??0,
        monthLast: json["mothLast"].toString(),
        totalDonation: json["totalDonation"] ?? -1,
        numOfMonths: json["countOfMonths"] ?? -1,
        totalLast: json["totalLast"].toString(),
      );

  Map<String, dynamic> toJson() => {
        'donations': donations,
        "id": id,
        "rowIgnore": rowIgnore,
        "donationDate": donationDate,
        "payDate": payDate,
        "amount": amount,
        "nots": nots,
        "donationAmount": donationAmount,
        "mothLast": monthLast,
        "totalDonation": totalDonation,
        "countOfMonths": numOfMonths,
        "totalLast": totalLast,
      };
}
