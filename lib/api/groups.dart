import 'package:json_annotation/json_annotation.dart';
import 'package:mo_school_kiosk/utils.dart';

part 'groups.g.dart';

@JsonSerializable()
class Group {
  @JsonKey(name: 'gid')
  final String id;
  final String name;
  final String kurs;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Group({required this.id, required this.name, required this.kurs});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class GroupAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  final List<Group> data;

  factory GroupAnswer.fromJson(Map<String, dynamic> json) =>
      _$GroupAnswerFromJson(json);

  GroupAnswer({
    required this.result,
    required this.message,
    required this.code,
    required this.data,
  });
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class GroupsResponse {
  final GroupAnswer answer;

  factory GroupsResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupsResponseFromJson(json);

  GroupsResponse({required this.answer});
}

@JsonSerializable()
class Student {
  @JsonKey(name: 'mid')
  final String id;
  @JsonKey(name: 'lastname')
  final String lastName;
  @JsonKey(name: 'firstname')
  final String firstName;
  final String patronymic;
  final String birthday;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Student({
    required this.id,
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    required this.birthday,
  });

  String get fio => '$lastName\n$firstName\n$patronymic';

  String photoUrl(String login, String password) => 'https://wq.lms-school.ru/'
      '?action=consolidated.photo'
      '&base=cons'
      '&login=$login'
      '&pass=$password'
      '&student=$id';
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentListAnswer {
  final String result;
  final String message;
  final String code;
  final List<Student>? data;

  factory StudentListAnswer.fromJson(Map<String, dynamic> json) =>
      _$StudentListAnswerFromJson(json);

  StudentListAnswer({
    required this.result,
    required this.message,
    required this.code,
    required this.data,
  });
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StudentsListResponse {
  final StudentListAnswer answer;

  factory StudentsListResponse.fromJson(Map<String, dynamic> json) =>
      _$StudentsListResponseFromJson(json);

  StudentsListResponse({required this.answer});
}
