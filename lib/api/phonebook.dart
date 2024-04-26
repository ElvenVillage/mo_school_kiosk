import 'package:json_annotation/json_annotation.dart';

part 'phonebook.g.dart';

@JsonSerializable()
class PhonebookInfo {
  final String school;
  @JsonKey(name: 'school_name')
  final String schoolName;
  final String address;
  final String phone;
  final String? email;
  final String fax;
  final String order;
  final String founded;

  factory PhonebookInfo.fromJson(Map<String, dynamic> json) =>
      _$PhonebookInfoFromJson(json);

  PhonebookInfo(
      {required this.school,
      required this.schoolName,
      required this.address,
      required this.phone,
      required this.email,
      required this.fax,
      required this.order,
      required this.founded});
}

@JsonSerializable()
class PhonebookContact {
  final String mid;
  final String fio;
  @JsonKey(name: 'Birthday')
  final String birthday;
  final String mobilePhone;
  final String workPhone;
  final String bookEntry;

  factory PhonebookContact.fromJson(Map<String, dynamic> json) =>
      _$PhonebookContactFromJson(json);

  PhonebookContact(
      {required this.mid,
      required this.fio,
      required this.birthday,
      required this.mobilePhone,
      required this.workPhone,
      required this.bookEntry});
}

@JsonSerializable()
class PhonebookData {
  final List<PhonebookDataEntry> schools;

  factory PhonebookData.fromJson(Map<String, dynamic> json) =>
      _$PhonebookDataFromJson(json);

  PhonebookData({required this.schools});
}

@JsonSerializable()
class PhonebookDataEntry {
  final PhonebookInfo info;
  final List<PhonebookContact> phones;

  factory PhonebookDataEntry.fromJson(Map<String, dynamic> json) =>
      _$PhonebookDataEntryFromJson(json);

  PhonebookDataEntry({required this.info, required this.phones});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PhonebookAnswer {
  final String result;
  final String message;
  final String code;
  @JsonKey(name: 'Data_')
  final PhonebookData data;

  factory PhonebookAnswer.fromJson(Map<String, dynamic> json) =>
      _$PhonebookAnswerFromJson(json);

  PhonebookAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class PhonebookResponse {
  final PhonebookAnswer answer;

  factory PhonebookResponse.fromJson(Map<String, dynamic> json) =>
      _$PhonebookResponseFromJson(json);

  PhonebookResponse({required this.answer});
}
