import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

part 'weeks.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class WeeksData {
  final String week;
  final String name;
  final String weekStart;
  final String weekEnd;
  final String scheduleVariant;
  final String doScheduleVariant;
  final String outScheduleVariant;
  final String current;

  @override
  int get hashCode => week.hashCode;

  factory WeeksData.fromJson(Map<String, dynamic> json) =>
      _$WeeksDataFromJson(json);

  WeeksData(
      {required this.week,
      required this.name,
      required this.weekStart,
      required this.weekEnd,
      required this.scheduleVariant,
      required this.doScheduleVariant,
      required this.outScheduleVariant,
      required this.current});

  @override
  bool operator ==(Object other) {
    if (other is WeeksData) {
      return week == other.week;
    }
    return false;
  }
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class WeeksAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  final List<WeeksData>? data;

  factory WeeksAnswer.fromJson(Map<String, dynamic> json) =>
      _$WeeksAnswerFromJson(json);

  WeeksAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class WeeksResponse {
  final WeeksAnswer answer;

  factory WeeksResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeksResponseFromJson(json);

  WeeksResponse({required this.answer});
}
