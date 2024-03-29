import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terms.g.dart';

@JsonSerializable(fieldRename: FieldRename.pascal)
class TermsApiResponse {
  final TermsApiAnswer answer;

  factory TermsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$TermsApiResponseFromJson(json);

  TermsApiResponse({required this.answer});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TermsApiAnswer {
  final String message;

  final String code;
  final List<TermsApiData>? data;

  factory TermsApiAnswer.fromJson(Map<String, dynamic> json) =>
      _$TermsApiAnswerFromJson(json);

  TermsApiAnswer(
      {required this.message, required this.code, required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class TermsApiData {
  @JsonKey(name: 'ID')
  final String id;
  final String name;
  final String dateBegin;
  final String dateEnd;
  final String current;
  final String year;
  final String yearName;
  final String termType;
  final String termTypeName;

  DateTime? _start;
  DateTime? _end;

  DateTime get start =>
      _start ?? DateFormat('dd.MM.yyyy').parse(dateBegin.substring(0, 10));
  DateTime get end =>
      _end ?? DateFormat('dd.MM.yyyy').parse(dateEnd.substring(0, 10));

  factory TermsApiData.fromJson(Map<String, dynamic> json) =>
      _$TermsApiDataFromJson(json);

  TermsApiData(
      {required this.id,
      required this.name,
      required this.dateBegin,
      required this.dateEnd,
      required this.current,
      required this.year,
      required this.yearName,
      required this.termType,
      required this.termTypeName});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class YearTermsApiResponse {
  final YearTermsApiAnswer answer;

  factory YearTermsApiResponse.fromJson(Map<String, dynamic> json) =>
      _$YearTermsApiResponseFromJson(json);

  YearTermsApiResponse({required this.answer});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class YearTermsApiAnswer {
  final String code;

  final String message;

  final List<YearTermsApiData> data;

  factory YearTermsApiAnswer.fromJson(Map<String, dynamic> json) =>
      _$YearTermsApiAnswerFromJson(json);

  YearTermsApiAnswer(
      {required this.code, required this.message, required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class YearTermsApiData {
  @JsonKey(name: 'ID')
  final String id;
  final String title;
  final String schoolYear;
  final String dateBegin;
  final String dateEnd;
  final String description;
  final String shortName;

  DateTime? get start => DateFormat('dd.MM.yyyy').parse(dateBegin);
  DateTime? get end => DateFormat('dd.MM.yyyy').parse(dateEnd);

  factory YearTermsApiData.fromJson(Map<String, dynamic> json) =>
      _$YearTermsApiDataFromJson(json);

  YearTermsApiData(
      {required this.id,
      required this.title,
      required this.schoolYear,
      required this.dateBegin,
      required this.dateEnd,
      required this.description,
      required this.shortName});
}
