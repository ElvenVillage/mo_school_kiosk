import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/groups.dart';
import 'package:mo_school_kiosk/api/schedule.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/schedule/schedule_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_grid.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../api/schools.dart';
import '../widgets/base_card.dart';
import '../widgets/group_grid.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static Route route() => createRoute((context) => const SchedulePage());

  @override
  Widget build(BuildContext context) {
    final schools = context.watch<StatsProvider>().schools;
    return PageTemplate(
        title: 'РАСПИСАНИЕ ЗАНЯТИЙ',
        subtitle: 'Выберите образовательную организацию',
        body: schools.isNotEmpty
            ? BaseGrid(
                schools: schools,
                onTap: (school) {
                  Navigator.of(context).push(ScheduleGroupsPage.route(school));
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

class ScheduleGroupsPage extends StatefulWidget {
  const ScheduleGroupsPage({super.key, required this.school});

  final School school;

  static Route route(School school) =>
      createRoute((context) => ScheduleGroupsPage(school: school));

  @override
  State<ScheduleGroupsPage> createState() => _ScheduleGroupsPageState();
}

class _ScheduleGroupsPageState extends State<ScheduleGroupsPage> {
  late final _dataSource = ScheduleProvider(
      scheduleType: ScheduleType.general,
      client: baseClient,
      dbName: widget.school.dbName);

  @override
  void initState() {
    super.initState();
    _dataSource.init();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'РАСПИСАНИЕ ЗАНЯТИЙ',
        subtitle: 'Выберите класс',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
                tag: widget.school.dbName, child: BaseCard(db: widget.school)),
          ),
          Expanded(
            child: StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final groups = snapshot.data!;

                  return GroupGrid(
                    groups: groups
                        .map((e) => Group(id: e.id, name: e.name, kurs: e.year))
                        .toList(),
                    school: widget.school,
                    onTap: (group) {
                      Navigator.of(context).push(ScheduleList.route(
                        school: widget.school,
                        group: group,
                        provider: _dataSource,
                      ));
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              stream: _dataSource.groups,
            ),
          ),
        ]));
  }
}

class ScheduleList extends StatefulWidget {
  const ScheduleList(
    this.school,
    this.group,
    this.provider, {
    super.key,
  });

  final School school;
  final Group group;

  final ScheduleProvider provider;

  static Route route(
          {required School school,
          required Group group,
          required ScheduleProvider provider}) =>
      createRoute((context) => ScheduleList(school, group, provider));

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  final _daysOfWeek = [for (var i = 1; i < 7; i++) i.toString()];
  var _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Расписание занятий',
        subtitle: widget.group.name,
        body: Row(
          children: [
            Expanded(
              child: GestureDetector(
                  onTap: _prev,
                  child: const Center(
                      child: Icon(
                    Icons.arrow_back,
                    size: 64.0,
                  ))),
            ),
            Expanded(
              flex: 3,
              child: StreamBuilder(
                  stream: widget.provider.periods,
                  builder: (context, periodSnapshot) {
                    if (!periodSnapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final periods = periodSnapshot.data!;
                    final allPeriods = periods.values
                        .expand((e) => e)
                        .groupListsBy((e) => e.name)
                        .keys
                        .toList();
                    return StreamBuilder(
                      stream: widget.provider.schedule,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = Map.fromEntries(_daysOfWeek.map((e) =>
                              MapEntry(
                                  e,
                                  snapshot.data![widget.group.id]
                                          ?.where((k) => k.dayOfWeek == e) ??
                                      [])));
                          final day =
                              data[_selectedDay.weekday.toString()] ?? [];

                          return Builder(
                            builder: (_) {
                              final lessons = day
                                  .sorted((a, b) =>
                                      int.parse(a.period) - int.parse(b.period))
                                  .groupListsBy((e) => e.period)
                                  .map((key, value) {
                                final newKey = periods[key]!.first.name;
                                return MapEntry(newKey, value);
                              });

                              if (lessons.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Нет занятий',
                                    style: context.headlineMedium,
                                  ),
                                );
                              }

                              return ListView(
                                children: [
                                  Text(
                                    _selectedDay.scheduleDate,
                                    style: context.headlineMedium,
                                  ),
                                  for (final period in allPeriods)
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 900),
                                      child: _LessonCard(
                                          key: Key(period),
                                          lessons: lessons,
                                          period: period,
                                          provider: widget.provider),
                                    )
                                ],
                              );
                            },
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }),
            ),
            Expanded(
              child: GestureDetector(
                  onTap: _next,
                  child: const Center(
                      child: Icon(
                    Icons.arrow_forward,
                    size: 64.0,
                  ))),
            ),
          ],
        ));
  }

  void _prev() {
    setState(() {
      final newDay = _selectedDay.subtract(const Duration(days: 1));
      if ((newDay.weekday - _selectedDay.weekday).abs() > 1) {
        widget.provider.prevWeek();
      }
      _selectedDay = newDay;
    });
  }

  void _next() {
    setState(() {
      final newDay = _selectedDay.add(const Duration(days: 1));
      if ((newDay.weekday - _selectedDay.weekday).abs() > 1) {
        widget.provider.nextWeek();
      }
      _selectedDay = newDay;
    });
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    super.key,
    required this.lessons,
    required this.period,
    required this.provider,
  });

  final Map<String, List<LessonData>> lessons;
  final String period;
  final ScheduleProvider provider;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final lesson = lessons[period]
              ?.groupListsBy((e) => e.id)
              .values
              .map((e) => e.first)
              .toList() ??
          [];

      final periodData = provider.periods.value.values
          .firstWhere((e) => e.first.name == period)
          .first;

      final teachers = provider.teachers.value.where(
          (teacher) => lesson.any((lesson) => lesson.teacher == teacher.id));

      final rooms = provider.rooms.value
          .where((room) => lesson.any((lesson) => lesson.room == room.id));

      if (lesson.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: lesson.isEmpty
              ? null
              : () {
                  final teachers = provider.teachers.value;
                  final rooms = provider.rooms.value;
                  _showLessonDialog(
                      context, lesson, teachers, rooms, periodData);
                },
          child: Card(
            color: AppColors.secondary.withAlpha(50),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.map((e) => e.title).join('/'),
                            style: context.body,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(teachers.map((e) => e.fio).join(' / '),
                                style: context.body),
                          )
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(color: Colors.grey),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            period,
                            style: context.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            periodData.periodFormatted,
                            style: context.body,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    rooms.map((e) => e.shortName).join(' / '),
                                    style: context.body,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showLessonDialog(BuildContext context, List<LessonData> lesson,
      List<TeacherData> teachers, List<RoomData> rooms, PeriodData periodData) {
    return showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: lesson.map((e) {
                  final teacher = teachers
                      .firstWhereOrNull((teacher) => teacher.id == e.teacher);
                  final room =
                      rooms.firstWhereOrNull((room) => room.id == e.room);
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Card(
                      color: AppColors.darkGreen,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CircleAvatar(
                                radius: 64.0,
                                backgroundImage: NetworkImage(
                                    'https://wq.lms-school.ru/?action=pub_image&person=${teacher?.id}&base=${provider.dbName}'),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      e.title,
                                      style: context.headlineMedium,
                                    ),
                                    trailing: Text(
                                      '${periodData.periodFormatted}\n${periodData.name}\n${room?.name}',
                                      style: context.body,
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '${teacher?.fio}\n${lesson.first.course}',
                                      style: context.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()),
          );
        });
  }
}
