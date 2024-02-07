import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_teacher.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class IntensityCourse extends StatelessWidget {
  const IntensityCourse({super.key, required this.school});

  final School school;

  Future<Map<(String, String), String>> _load() async {
    final data = await client.getStatsForSchool(school.id);
    return data.answer.data
        .where((e) => e.indicatorKey == Indicator.intensitySubject.value)
        .groupListsBy((e) => e.subId)
        .map((key, value) {
      return MapEntry(
          (value.first.subValName, value.first.subId), value.first.subVal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
        subtitle: '',
        overlaySubtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              width: 50,
            ),
            CircleAvatar(
              backgroundImage: NetworkImage(school.imgUrl),
              radius: 64.0,
            ),
            Text(school.name, style: context.headlineLarge),
          ],
        ),
        body: FutureBuilder(
            future: _load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final data = snapshot.data!;
              return GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 10,
                children: [
                  for (final subject in data.entries.sorted((a, b) =>
                      (num.parse(b.value) - num.parse(a.value)).sign.toInt()))
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(IntensityTeacher.route(
                            school, subject.key.$2, subject.key.$1));
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                      text: '${subject.value}% ',
                                      children: [
                                        TextSpan(
                                            text: subject.key.$1,
                                            style: context.headlineMedium)
                                      ],
                                      style: context.headlineLarge)),
                            ),
                          )
                        ],
                      ),
                    )
                ],
              );
            }));
  }

  static Route route(School school) =>
      createRoute((_) => IntensityCourse(school: school));
}
