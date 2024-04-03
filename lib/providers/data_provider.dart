import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/report.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/api/stats.dart';
import 'package:mo_school_kiosk/utils.dart';

enum Indicator {
  // cредний балл в учебном заведении
  averageGrade('1'),
  // процент заполнения тем. плана
  plan('2'),
  // укомплектованность педработниками
  komplekt('3'),
  // интенсивность оценивания знаний
  intensity('4'),
  // число обучающихся удостоенных медали "за особые успехи в учении"
  medals('5'),
  // количество мероприятий за последние 7 дней
  events('7'),
  // конкурс при поступлении (мальчики)
  admissionM('6', '10'),
  // конкурс при поступлении (девочки)
  admissionF('6', '11'),
  // число обучающихся (мальчики)
  countM('13', '14'),
  // число обучающихся (девочки)
  countF('13', '15'),
  // интенсивность оценивания по предметам
  intensitySubject('8'),
  // процент комментирования выставленных оценок
  commentsGrades('16'),
  // процент занятий с электронными материалами
  elMaterials('17'),
  // количество стобалльников по ЕГЭ
  score100('18');

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
  Timer? _timer;

  var _loading = false;

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
  var error = "";

  final schools = <School>[];
  final reports = <School, List<ReportData>>{};

  void setupTimer() {
    _timer = Timer.periodic(const Duration(minutes: 30), (_) {
      stats.clear();
      notifyListeners();
      load();
    });
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;

    while (true) {
      try {
        LmsLogger().log.i('loading consolidated.statistic');
        final data = await client.getStats();

        final dataBySchools = data.answer.data.groupListsBy((e) => School(
            id: e.orgId,
            name: e.orgName.replaceAll('\n', ' '),
            dbName: e.dbName ?? ''));

        LmsLogger().log.i('loaded data for ${dataBySchools.length} schools');

        for (final indicator in Indicator.values) {
          stats[indicator] = getData(dataBySchools, indicator);
        }

        schools
          ..clear()
          ..addAll(dataBySchools.keys);

        error = '';

        break;
      } on DioException catch (e) {
        error = e.error?.toString() ?? 'Не удалось загрузить данные';
        LmsLogger()
            .log
            .e('Could not fetch consolidated_statistic, retrying...', error: e);
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        error = e.toString();
        LmsLogger()
            .log
            .e('Could not fetch consolidated_statistic, retrying...', error: e);
        await Future.delayed(const Duration(seconds: 5));
      } finally {
        _loading = false;
        notifyListeners();
      }
    }

    await loadReports();
  }

  Future<void> loadReports() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (final school in schools) {
      while (true) {
        try {
          LmsLogger().log.i('loading GeneralStatisticOne for ${school.dbName}');
          final response = await client.getReport(school.id, date);
          reports[school] = response.answer.data;

          break;
        } on DioException catch (e) {
          error = e.error?.toString() ?? 'Не удалось загрузить данные';
          LmsLogger().log.e(
              'Could not fetch GeneralStatisticOne for ${school.dbName}, retrying...',
              error: e);
          await Future.delayed(const Duration(seconds: 5));
        } catch (e) {
          LmsLogger().log.e(
              'Could not fetch GeneralStatisticOne for ${school.dbName}, retrying...',
              error: e);
          error = e.toString();
          await Future.delayed(const Duration(seconds: 5));
        } finally {
          notifyListeners();
        }
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
