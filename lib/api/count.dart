import 'package:json_annotation/json_annotation.dart';

part 'count.g.dart';

@JsonSerializable()
class CountData {
  final String fact;
  final String plan;

  CountData({required this.fact, required this.plan});

  int get studentsFact => int.parse(fact);
  int get studentsPlan => int.parse(plan);
  int get diff => studentsPlan - studentsFact;

  factory CountData.fromJson(Map<String, dynamic> json) =>
      _$CountDataFromJson(json);
}

@JsonSerializable()
class CountDataAnswer {
  final List<CountData> classes;

  factory CountDataAnswer.fromJson(Map<String, dynamic> json) =>
      _$CountDataAnswerFromJson(json);

  CountDataAnswer({required this.classes});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class CountAnswer {
  final String result;
  final String message;
  final String code;
  @JsonKey(name: 'Data_')
  final CountDataAnswer data;

  factory CountAnswer.fromJson(Map<String, dynamic> json) =>
      _$CountAnswerFromJson(json);

  CountAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class CountReportResponse {
  final CountAnswer answer;

  factory CountReportResponse.fromJson(Map<String, dynamic> json) =>
      _$CountReportResponseFromJson(json);

  CountReportResponse({required this.answer});
}
