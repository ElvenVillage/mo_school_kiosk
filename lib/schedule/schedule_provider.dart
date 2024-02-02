import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/schedule.dart';
import 'package:mo_school_kiosk/api/weeks.dart';
import 'package:rxdart/subjects.dart';

typedef ScheduleData = Map<String, List<LessonData>>;

enum ScheduleType {
  general('fullschedule'),
  extended('fulldoschedule'),
  out('fulloutschedule');

  final String action;
  const ScheduleType(this.action);
}

class ScheduleProvider extends ChangeNotifier {
  final ScheduleType scheduleType;

  final selectedWeek = BehaviorSubject<WeeksData>();

  final groups = BehaviorSubject<List<GroupData>?>();
  final schedule = BehaviorSubject<ScheduleData?>();
  final periods = BehaviorSubject<Map<String, List<PeriodData>>>();
  final teachers = BehaviorSubject<List<TeacherData>>();
  final rooms = BehaviorSubject<List<RoomData>>();

  final _scheduleMemCache = <WeeksData, ScheduleData>{};
  final _periodsMemCache = <WeeksData, Map<String, List<PeriodData>>>{};
  final _groupsMemCache = <WeeksData, List<GroupData>>{};
  final _teachersMemCache = <WeeksData, List<TeacherData>>{};
  final _roomsMemCache = <WeeksData, List<RoomData>>{};

  final List<WeeksData> weeks = [];

  Timer? _timer;

  void clear() {
    weeks.clear();
    _scheduleMemCache.clear();
    _periodsMemCache.clear();
    _groupsMemCache.clear();
    _teachersMemCache.clear();
    _roomsMemCache.clear();

    fetchWeeks();
  }

  final BaseClient client;
  final String dbName;

  static const updateTimeout = Duration(minutes: 20);
  static const debugUpdateTimeout = Duration(minutes: 10);

  StreamSubscription<WeeksData>? _sub;

  ScheduleProvider({
    required this.scheduleType,
    required this.client,
    required this.dbName,
  }) {
    init();

    _timer = Timer.periodic(kDebugMode ? debugUpdateTimeout : updateTimeout,
        (timer) {
      clear();
      update();
    });
  }

  void init() {
    fetchWeeks();

    _sub = selectedWeek.listen((week) async {
      schedule.add(null);

      try {
        if (_scheduleMemCache.containsKey(week)) {
          schedule.add(_scheduleMemCache[week]);
          periods.add(_periodsMemCache[week]!);
          groups.add(_groupsMemCache[week]!);
          teachers.add(_teachersMemCache[week]!);
          rooms.add(_roomsMemCache[week]!);
          return;
        }

        if ((week.doScheduleVariant.isEmpty &&
                scheduleType == ScheduleType.extended) ||
            (week.outScheduleVariant.isEmpty &&
                scheduleType == ScheduleType.out)) {
          schedule.add({});
          groups.add([]);
          teachers.add([]);
          rooms.add([]);
          periods.add({});

          return;
        }

        final data = await client.getFullSchedule(week.scheduleVariant, dbName);

        final groupedSchedule =
            data.answer.data!.schedule.groupListsBy((e) => e.colId);

        _scheduleMemCache[week] = groupedSchedule;
        schedule.add(groupedSchedule);

        final groupedPeriods =
            data.answer.data!.periods.groupListsBy((e) => e.period);
        periods.add(groupedPeriods);
        _periodsMemCache[week] = groupedPeriods;

        final groupedGroups = data.answer.data!.groups
            .groupListsBy((e) => e.id)
            .values
            .map((e) => e.first)
            .toList();

        groups.add(groupedGroups);
        _groupsMemCache[week] = groupedGroups;

        _teachersMemCache[week] = data.answer.data!.teachers
            .groupListsBy((e) => e.id)
            .entries
            .expand((e) => [e.value.first])
            .toList();
        teachers.add(_teachersMemCache[week]!);

        _roomsMemCache[week] = data.answer.data!.rooms;
        rooms.add(_roomsMemCache[week]!);
      } catch (e) {
        groups.addError(e);
        periods.addError(e);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();

    periods.close();
    selectedWeek.close();
    groups.close();
    schedule.close();
    rooms.close();

    super.dispose();
  }

  Future<void> fetchWeeks() async {
    try {
      groups.add(null);
      final fetchedWeeks = await client.getWeeks(dbName);

      weeks.addAll(fetchedWeeks.answer.data!);

      selectedWeek.add(weeks.firstWhere((e) => e.current == '1'));
    } catch (e) {
      groups.addError(e);
    }
  }

  void prevWeek() {
    final index = weeks.indexWhere((e) => e.week == selectedWeek.value.week);
    if (index > 0) {
      selectedWeek.add(weeks[index - 1]);
    }
  }

  void nextWeek() {
    final index = weeks.indexWhere((e) => e.week == selectedWeek.value.week);
    if (index < weeks.length - 1) {
      selectedWeek.add(weeks[index + 1]);
    }
  }

  void update() {
    schedule.add(null);
    selectedWeek.add(selectedWeek.value);
  }
}
