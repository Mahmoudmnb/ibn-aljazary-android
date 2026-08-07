class StudentModel {
  int id;
  List<dynamic> lastInstitutes;
  String studentStatues;
  String fName;
  String fatherWork;
  String fatherStudy;
  String fatherPhoneNumber;
  String motherFName;
  String motherLName;
  String motherWork;
  String motherStudy;
  String motherPhoneNumber;
  String fatherWhatsNumber;
  String motherWhatsNumber;
  String studyLevel;
  String schoolName;
  String bornPlace;
  String progressInInstitute;
  String lName;
  String fatherName;
  String homeNumber;
  String mobileNumber;
  String address;
  String nots;
  String birthDay;
  String startDate;
  String? endDate;
  bool isStudent;
  String donations;
  String className;
  String classSubject;
  String teachers;

  String? rankYear;
  String? rankMonth;
  String? rankLevel;
  String? rankScore;
  String? classStudentCount;

  StudentModel({
    required this.donations,
    required this.address,
    required this.birthDay,
    required this.bornPlace,
    required this.endDate,
    required this.fName,
    required this.fatherName,
    required this.fatherPhoneNumber,
    required this.fatherStudy,
    required this.fatherWhatsNumber,
    required this.fatherWork,
    required this.homeNumber,
    required this.id,
    required this.isStudent,
    required this.lName,
    required this.lastInstitutes,
    required this.mobileNumber,
    required this.motherFName,
    required this.motherLName,
    required this.motherPhoneNumber,
    required this.motherStudy,
    required this.motherWhatsNumber,
    required this.motherWork,
    required this.nots,
    required this.progressInInstitute,
    required this.schoolName,
    required this.startDate,
    required this.studentStatues,
    required this.studyLevel,
    required this.className,
    required this.classSubject,
    required this.teachers,
    this.rankYear,
    this.rankMonth,
    this.rankLevel,
    this.rankScore,
    this.classStudentCount,
  });
  factory StudentModel.fromMap(Map<String, dynamic> data) {
    return StudentModel(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id']?.toString() ?? '') ?? 0,
      fName: _stringValue(data['fName']),
      lName: _stringValue(data['lName']),
      donations: _stringValue(data['donation']),
      address: data['address'] ?? '',
      bornPlace: _stringValue(data['bornPlace']),
      fatherName: _stringValue(data['fatherName']),
      fatherPhoneNumber: data['fatherPhoneNumber'] ?? '',
      fatherStudy: data['fatherStudy'] ?? '',
      fatherWhatsNumber: data['fatherWhatsAppNumber'] ?? '',
      fatherWork: data['fatherWork'] ?? "",
      homeNumber: data['homeNumber'] ?? '',
      isStudent: data['isStudent'] == true || data['isStudent'] == 1,
      lastInstitutes: data['institutes'] ?? [],
      mobileNumber: data['mobileNumber'] ?? "",
      motherFName: _stringValue(data['motherFName']),
      motherLName: _stringValue(data['motherLName']),
      motherPhoneNumber: data['motherPhoneNumber'] ?? '',
      motherStudy: data['motherStudy'] ?? '',
      motherWhatsNumber: data['motherWhatsAppNumber'] ?? '',
      motherWork: data['motherWork'] ?? '',
      nots: data['nots'] ?? '',
      progressInInstitute: data['progressInInstitute'] ?? '',
      schoolName: data['schoolName'] ?? "",
      startDate: _stringValue(data['startDate']),
      endDate: data['endDate'],
      birthDay: _stringValue(data['birthDay']),
      studentStatues: _stringValue(data['statues']),
      studyLevel: data['studyLevel'] ?? '',
      className: data['className'] ?? '',
      classSubject: data['classSubject'] ?? '',
      teachers: data['teachers'] ?? '',
      rankYear: _nullableStringValue(data['rankYear']),
      rankMonth: _nullableStringValue(data['rankMonth']),
      rankLevel: _nullableStringValue(data['rankLevel']),
      rankScore: _nullableStringValue(data['rankScore']),
      classStudentCount: _nullableStringValue(data['classStudentCount']),
    );
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static String? _nullableStringValue(dynamic value) {
    return value == null ? null : value.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donation': donations,
      "lastInstitutes": lastInstitutes,
      "statues": studentStatues,
      "fName": fName,
      "fatherWork": fatherWork,
      "fatherStudy": fatherStudy,
      "fatherPhoneNumber": fatherPhoneNumber,
      "motherFName": motherFName,
      "motherLName": motherLName,
      "motherWork": motherWork,
      "motherStudy": motherStudy,
      "motherPhoneNumber": motherPhoneNumber,
      "fatherWhatsAppNumber": fatherWhatsNumber,
      "motherWhatsAppNumber": motherWhatsNumber,
      "studyLevel": studyLevel,
      "schoolName": schoolName,
      "bornPlace": bornPlace,
      "progressInInstitute": progressInInstitute,
      "lName": lName,
      "fatherName": fatherName,
      "homeNumber": homeNumber,
      "mobileNumber": mobileNumber,
      "address": address,
      "nots": nots,
      "birthDay": birthDay,
      "startDate": startDate,
      "endDate": endDate != null && endDate!.isEmpty ? null : endDate,
      "isStudent": true,
      'className': className,
      'classSubject': classSubject,
      'teachers': teachers.toString(),
      'rankYear': rankYear.toString(),
      'rankMonth': rankMonth.toString(),
      'rankLevel': rankLevel.toString(),
      'rankScore': rankScore.toString(),
      'classStudentCount': classStudentCount,
    };
  }
}
