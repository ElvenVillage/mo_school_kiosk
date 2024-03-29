import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

part 'schedule.g.dart';

@JsonSerializable()
class GroupData {
  @JsonKey(name: 'ColID')
  final String id;
  @JsonKey(name: 'ColName')
  final String name;
  @JsonKey(name: 'ColYear')
  final String year;

  final String group;
  final String course;
  final String liter;
  final String isElective;

  factory GroupData.fromJson(Map<String, dynamic> json) =>
      _$GroupDataFromJson(json);

  GroupData(
      {required this.id,
      required this.name,
      required this.year,
      required this.group,
      required this.course,
      required this.liter,
      required this.isElective});
}

@JsonSerializable()
class PeriodData {
  final String period;
  @JsonKey(name: 'starttime')
  final String startTime;
  @JsonKey(name: 'stoptime')
  final String stopTime;
  @JsonKey(name: 'day_of_week')
  final String dayOfWeek;
  final String part;
  final String name;

  TimeOfDay get start {
    final totalMinutes = int.parse(startTime);
    final hours = totalMinutes ~/ TimeOfDay.minutesPerHour;
    return TimeOfDay(
        hour: hours, minute: totalMinutes - hours * TimeOfDay.minutesPerHour);
  }

  TimeOfDay get end {
    final totalMinutes = int.parse(stopTime);
    final hours = totalMinutes ~/ TimeOfDay.minutesPerHour;
    return TimeOfDay(
        hour: hours, minute: totalMinutes - hours * TimeOfDay.minutesPerHour);
  }

  String get periodFormatted => '${start.formatted} — ${end.formatted}';

  factory PeriodData.fromJson(Map<String, dynamic> json) =>
      _$PeriodDataFromJson(json);

  PeriodData(
      {required this.period,
      required this.startTime,
      required this.stopTime,
      required this.dayOfWeek,
      required this.part,
      required this.name});
}

@JsonSerializable()
class CourseData {
  final String course;
  final String name;
  final String level;

  factory CourseData.fromJson(Map<String, dynamic> json) =>
      _$CourseDataFromJson(json);

  CourseData({required this.course, required this.name, required this.level});
}

@JsonSerializable()
class TeacherData {
  @JsonKey(name: 'teacher')
  final String id;
  @JsonKey(name: 'FIO')
  final String fio;

  factory TeacherData.fromJson(Map<String, dynamic> json) =>
      _$TeacherDataFromJson(json);

  TeacherData({
    required this.id,
    required this.fio,
  });
}

@JsonSerializable()
class RoomData {
  @JsonKey(name: 'room')
  final String id;
  final String name;
  @JsonKey(name: 'short_name')
  final String shortName;

  factory RoomData.fromJson(Map<String, dynamic> json) =>
      _$RoomDataFromJson(json);

  RoomData({
    required this.id,
    required this.name,
    required this.shortName,
  });
}

@JsonSerializable()
class StudyStates {
  @JsonKey(name: 'study_state')
  final String id;
  final String name;

  factory StudyStates.fromJson(Map<String, dynamic> json) =>
      _$StudyStatesFromJson(json);

  StudyStates({required this.id, required this.name});
}

@JsonSerializable()
class LessonData {
  final String id;
  final String title;
  final String course;
  final String room;
  final String teacher;
  final String group;
  @JsonKey(name: 'day_of_week')
  final String dayOfWeek;
  final String period;
  @JsonKey(name: 'xp_part')
  final String xpPart;
  @JsonKey(name: 'study_state')
  final String studyState;
  @JsonKey(name: 'ColID')
  final String colId;

  factory LessonData.fromJson(Map<String, dynamic> json) =>
      _$LessonDataFromJson(json);

  LessonData(
      {required this.id,
      required this.title,
      required this.course,
      required this.room,
      required this.teacher,
      required this.group,
      required this.dayOfWeek,
      required this.period,
      required this.xpPart,
      required this.studyState,
      required this.colId});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ScheduleData {
  final List<GroupData> groups;
  final List<PeriodData> periods;
  final List<CourseData> courses;
  final List<TeacherData> teachers;
  final List<RoomData> rooms;
  final List<StudyStates> studyStates;
  final List<LessonData> schedule;

  factory ScheduleData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDataFromJson(json);

  ScheduleData(
      {required this.groups,
      required this.periods,
      required this.courses,
      required this.teachers,
      required this.rooms,
      required this.studyStates,
      required this.schedule});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ScheduleAnswer implements LmsAnswer {
  @override
  final String result;
  @override
  final String message;
  @override
  final String code;
  @JsonKey(name: 'Data_')
  final ScheduleData? data;

  factory ScheduleAnswer.fromJson(Map<String, dynamic> json) =>
      _$ScheduleAnswerFromJson(json);

  ScheduleAnswer(
      {required this.result,
      required this.message,
      required this.code,
      required this.data});
}

@JsonSerializable(fieldRename: FieldRename.pascal)
class ScheduleResponse {
  final ScheduleAnswer answer;

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseFromJson(json);

  ScheduleResponse({required this.answer});
}
