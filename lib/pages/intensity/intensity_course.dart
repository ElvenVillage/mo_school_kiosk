import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_teacher.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_card.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

typedef _Intensity = Map<(String, String), String>;

class IntensityCourse extends StatelessWidget {
  const IntensityCourse({super.key, required this.school});

  final School school;

  Future<_Intensity> _load() async {
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
            FutureBuilder(
              future: BaseCard.getBaseImage(school),
              builder: (context, snapshot) => CircleAvatar(
                foregroundImage: snapshot.data,
                backgroundColor: Colors.white,
                radius: 64.0,
              ),
            ),
            Text(school.name, style: context.headlineLarge),
          ],
        ),
        body: ReloadableFutureBuilder<_Intensity>(
            future: () => _load(),
            builder: (_Intensity data) {
              return SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (final subject in data.entries.sorted((a, b) =>
                        (num.parse(b.value) - num.parse(a.value)).sign.toInt()))
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 75,
                        child: InkWell(
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
                                      maxLines: 2,
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
                        ),
                      )
                  ],
                ),
              );
            }));
  }

  static Route route(School school) =>
      createRoute((_) => IntensityCourse(school: school));
}
