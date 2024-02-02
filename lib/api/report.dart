import 'package:json_annotation/json_annotation.dart';
import 'package:mo_school_kiosk/utils.dart';

part 'report.g.dart';

@JsonSerializable()
class ReportData {
  @JsonKey(name: 'value')
  final String val;

  @JsonKey(name: 'num')
  final String name;

  ReportData(this.name, this.val);
  num get value => num.parse(val.replaceAll(',', '.'));

  factory ReportData.fromJson(Map<String, dynamic> json) =>
      _$ReportDataFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ReportAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  final List<ReportData> data;

  factory ReportAnswer.fromJson(Map<String, dynamic> json) =>
      _$ReportAnswerFromJson(json);

  ReportAnswer(this.result, this.message, this.code, this.data);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ReportResponse {
  final ReportAnswer answer;

  factory ReportResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportResponseFromJson(json);

  ReportResponse(this.answer);
}
