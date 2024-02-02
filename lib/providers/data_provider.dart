import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/report.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/api/stats.dart';

enum Indicator {
  // cредний балл в учебном заведении
  averageGrade('1'),
  // процент заполнения тем. плана
  plan('2'),
  // укомплектованность педработниками
  komplekt('3'),
  // интенсивность оценивания знаний
  intensity('4'),
  // количество мероприятий за последние 7 дней
  events('7'),
  // конкурс при поступлении (мальчики)
  admissionM('6', '10'),
  // конкурс при поступлении (девочки)
  admissionF('6', '11'),
  // интенсивность оценивания по предметам
  intensitySubject('8');

  final String value;
  final String? subID;
  const Indicator(this.value, [this.subID]);
}

enum ReportIndicator {
  totalStudent('1'),
  totalTeachers('69'),
  firstCat('71'),
  highCat('72');

  final String name;
  const ReportIndicator(this.name);
}

class StatsProvider extends ChangeNotifier {
  Map<School, num?> getData(Map<School, List<StatsData>> data, Indicator ind) {
    return data.map((key, value) => MapEntry(
        key,
        value.firstWhereOrNull((e) {
          if (ind.subID == null) {
            return e.indicatorKey == ind.value;
          }
          return e.indicatorKey == ind.value && e.subId == ind.subID;
        })?.value));
  }

  Map<School, num?> getReportData(ReportIndicator ind) {
    return reports.map((key, value) => MapEntry(
        key,
        value.firstWhereOrNull((e) {
          return e.name == ind.name;
        })?.value));
  }

  Map<Indicator, Map<School, num?>> stats = {};

  final schools = <School>[];
  final reports = <School, List<ReportData>>{};

  Future<void> load() async {
    final data = await client.getStats();

    final dataBySchools = data.answer.data.groupListsBy((e) => School(
        id: e.orgId,
        name: e.orgName.replaceAll('\n', ' '),
        dbName: e.dbName ?? ''));

    for (final indicator in Indicator.values) {
      stats[indicator] = getData(dataBySchools, indicator);
    }

    schools
      ..clear()
      ..addAll(dataBySchools.keys);

    await loadReports();

    notifyListeners();
  }

  Future<void> loadReports() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (final school in schools) {
      try {
        final response = await client.getReport(school.id, date);
        reports[school] = response.answer.data;
        notifyListeners();
      } catch (_) {}
    }
  }
}
