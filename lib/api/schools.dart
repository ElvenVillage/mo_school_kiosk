import 'package:json_annotation/json_annotation.dart';
import 'package:mo_school_kiosk/content/model.dart';
import 'package:mo_school_kiosk/utils.dart';

part 'schools.g.dart';

@JsonSerializable()
class School {
  @JsonKey(name: 'idOrganization')
  final String id;
  @JsonKey(name: 'orgName')
  final String name;
  @JsonKey(name: 'server_id')
  final String dbName;

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  @override
  int get hashCode => Object.hash(id, name);

  School({required this.id, required this.name, required this.dbName});

  String get imgUrl =>
      'https://wq.lms-school.ru/?action=kiosklogo&base=$dbName';
  String get pngUrl =>
      'https://wq.lms-school.ru/?action=kiosklogopng&base=$dbName';

  factory School.fromSchoolModel(SchoolModel model) =>
      School(id: model.id, name: model.name, dbName: model.assetName);

  @override
  bool operator ==(Object other) => other is School && id == other.id;
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SchoolsAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  final List<School> data;

  factory SchoolsAnswer.fromJson(Map<String, dynamic> json) =>
      _$SchoolsAnswerFromJson(json);

  SchoolsAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class SchoolsResponse {
  final SchoolsAnswer answer;

  factory SchoolsResponse.fromJson(Map<String, dynamic> json) =>
      _$SchoolsResponseFromJson(json);

  SchoolsResponse({required this.answer});
}
