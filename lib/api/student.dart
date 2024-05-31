import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mo_school_kiosk/utils.dart';

part 'student.g.dart';

@JsonSerializable()
class StudentInfo {
  @JsonKey(name: 'mid')
  final String id;
  final String lastname;
  final String patronymic;
  final String birthday;
  final String birthplace;
  @JsonKey(name: 'enter_date')
  final String enterDate;
  @JsonKey(name: 'MilitaryDistrictArrival')
  final String militaryDistrict;
  final String mother;
  final String father;

  String get imageUrl =>
      'https://wq.lms-school.ru/?action=consolidated.photo&student=$id';

  factory StudentInfo.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoFromJson(json);

  StudentInfo({
    required this.id,
    required this.lastname,
    required this.patronymic,
    required this.birthday,
    required this.birthplace,
    required this.enterDate,
    required this.militaryDistrict,
    required this.mother,
    required this.father,
  });
}

@JsonSerializable()
class StudentGrade {
  @JsonKey(name: 'sub_ind')
  final String subject;
  @JsonKey(name: 'sub_value')
  final String grades;

  factory StudentGrade.fromJson(Map<String, dynamic> json) =>
      _$StudentGradeFromJson(json);

  StudentGrade({required this.subject, required this.grades});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentDetailsAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  @JsonKey(name: 'Data_')
  final StudentDetais data;

  factory StudentDetailsAnswer.fromJson(Map<String, dynamic> json) =>
      _$StudentDetailsAnswerFromJson(json);

  StudentDetailsAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentAward {
  final String date;
  final String isPenalty;
  final String kind;
  final String reason;

  static final _dateFormat = DateFormat('dd.MM.yyyy h:mm:ss');
  static final _displayFormat = DateFormat('dd.MM.yyyy');

  StudentAward({
    required this.date,
    required this.isPenalty,
    required this.kind,
    required this.reason,
  });

  DateTime get awardDate => _dateFormat.parse(date);
  String get displayDate => _displayFormat.format(awardDate);

  factory StudentAward.fromJson(Map<String, dynamic> json) =>
      _$StudentAwardFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentDetais {
  final List<StudentInfo> info;
  final List<StudentGrade> grades;
  final List<StudentAward> awards;

  factory StudentDetais.fromJson(Map<String, dynamic> json) =>
      _$StudentDetaisFromJson(json);

  StudentDetais({
    required this.info,
    required this.grades,
    required this.awards,
  });
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentDetailsResponse {
  final StudentDetailsAnswer answer;

  factory StudentDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentDetailsResponseFromJson(json);

  StudentDetailsResponse({required this.answer});
}
