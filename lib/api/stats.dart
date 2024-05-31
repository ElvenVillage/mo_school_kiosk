import 'package:json_annotation/json_annotation.dart';
import 'package:mo_school_kiosk/utils.dart';

part 'stats.g.dart';

@JsonSerializable()
class StatsData {
  @JsonKey(name: 'idOrganization')
  final String orgId;
  @JsonKey(name: 'orgname')
  final String orgName;
  @JsonKey(name: 'ind')
  final String name;
  @JsonKey(name: 'server_id')
  final String? dbName;
  @JsonKey(name: 'ind_id')
  final String indicatorKey;
  @JsonKey(name: 'value')
  final String? val;
  @JsonKey(name: 'sub_id')
  final String subId;
  @JsonKey(name: 'sub_value')
  final String subVal;
  @JsonKey(name: 'sub_ind')
  final String subValName;

  num? get value =>
      num.tryParse((subId.isEmpty ? val : subVal)?.replaceAll(',', '.') ?? '');

  factory StatsData.fromJson(Map<String, dynamic> json) =>
      _$StatsDataFromJson(json);

  StatsData(this.orgId, this.orgName, this.name, this.dbName, this.indicatorKey,
      this.val, this.subId, this.subVal, this.subValName);
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StatsAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  final List<StatsData> data;

  factory StatsAnswer.fromJson(Map<String, dynamic> json) =>
      _$StatsAnswerFromJson(json);

  StatsAnswer({
    required this.result,
    required this.message,
    required this.code,
    required this.data,
  });
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class StatsResponse {
  final StatsAnswer answer;

  factory StatsResponse.fromJson(Map<String, dynamic> json) =>
      _$StatsResponseFromJson(json);

  StatsResponse({required this.answer});
}
