import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teacher_schedule.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class TeacherJournalApiResponse {
  final TeacherJournalApiAnswer answer;

  factory TeacherJournalApiResponse.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalApiResponseFromJson(json);

  TeacherJournalApiResponse({required this.answer});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TeacherJournalApiAnswer {
  final String message;

  final String code;
  @JsonKey(name: 'Data_')
  final TeacherJournalData? data;

  factory TeacherJournalApiAnswer.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalApiAnswerFromJson(json);

  TeacherJournalApiAnswer(
      {required this.message, required this.code, required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TeacherJournalData {
  final List<TeacherJournalDate> dates;
  final List<TeacherJournalStudent> students;
  final String termName;
  final List<TeacherJournalTerm> terms;
  final List<TeacherJournalGrade> grades;
  final List<TeacherJournalGradeType> gradeTypes;
  final List<TeacherJournalLessonType> lessonTypes;
  final String closeDate;

  factory TeacherJournalData.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalDataFromJson(json);

  TeacherJournalData(
      {required this.dates,
      required this.students,
      required this.termName,
      required this.terms,
      required this.gradeTypes,
      required this.grades,
      required this.lessonTypes,
      required this.closeDate});
}

@JsonSerializable()
class TeacherJournalLessonType {
  @JsonKey(name: 'I')
  final String id;
  @JsonKey(name: 'N')
  final String name;

  factory TeacherJournalLessonType.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalLessonTypeFromJson(json);

  TeacherJournalLessonType({required this.id, required this.name});
}

@JsonSerializable()
class TeacherJournalTerm {
  @JsonKey(name: 'ID')
  final String id;
  @JsonKey(name: 'T')
  final String name;

  TeacherJournalTerm({required this.id, required this.name});

  factory TeacherJournalTerm.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalTermFromJson(json);
}

@JsonSerializable()
class TeacherJournalDate {
  @JsonKey(name: 'SI')
  final String scheduleID;
  @JsonKey(name: 'I')
  final String weekID;
  @JsonKey(name: 'D')
  final String date;
  @JsonKey(name: 'ID')
  final String lessonID;
  @JsonKey(name: 'T')
  final String lessonType;
  @JsonKey(name: 'TI')
  final String lessonTypeID;
  @JsonKey(name: 'HW')
  final String homework;
  @JsonKey(name: 'Tt')
  final String theme;
  @JsonKey(name: 'TtI')
  final String themeID;

  factory TeacherJournalDate.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalDateFromJson(json);

  DateTime get startDate => DateFormat('dd.MM.yyyy').parse(date);

  TeacherJournalDate(
      {required this.scheduleID,
      required this.lessonType,
      required this.weekID,
      required this.date,
      required this.lessonID,
      required this.lessonTypeID,
      required this.homework,
      required this.theme,
      required this.themeID});
}

@JsonSerializable()
class TeacherJournalStudent {
  @JsonKey(name: 'M')
  final String id;
  @JsonKey(name: 'N')
  final String name;
  @JsonKey(name: 'G')
  final String grades;

  factory TeacherJournalStudent.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalStudentFromJson(json);

  TeacherJournalStudent(
      {required this.id, required this.name, required this.grades});
}

@JsonSerializable()
class TeacherJournalGrade {
  @JsonKey(name: 'M')
  final String studentID;
  @JsonKey(name: 'I')
  final String lessonID;
  @JsonKey(name: 'G')
  final String grade;
  @JsonKey(name: 'C')
  final String comment;
  @JsonKey(name: 'D')
  final String date;
  @JsonKey(name: 'TI')
  final String teacherID;
  @JsonKey(name: 'T')
  final String teacherName;

  factory TeacherJournalGrade.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalGradeFromJson(json);

  factory TeacherJournalGrade.empty() {
    return TeacherJournalGrade(
        studentID: '',
        lessonID: '',
        grade: '',
        comment: '',
        date: '',
        teacherID: '',
        teacherName: '');
  }

  TeacherJournalGrade(
      {required this.studentID,
      required this.lessonID,
      required this.grade,
      required this.comment,
      required this.date,
      required this.teacherID,
      required this.teacherName});
}

@JsonSerializable()
class TeacherJournalGradeType {
  @JsonKey(name: 'G')
  final String grade;
  @JsonKey(name: 'N')
  final String description;
  @JsonKey(name: 'I')
  final String isGrade;

  factory TeacherJournalGradeType.fromJson(Map<String, dynamic> json) =>
      _$TeacherJournalGradeTypeFromJson(json);

  TeacherJournalGradeType(
      {required this.grade, required this.description, required this.isGrade});
}
