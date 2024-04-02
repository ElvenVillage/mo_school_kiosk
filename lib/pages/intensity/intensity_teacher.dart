import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/settings.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/cropped_avatar.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';

typedef _IntensityTeacher = Map<String, ({String fio, String id})>;

class IntensityTeacher extends StatelessWidget {
  const IntensityTeacher({
    super.key,
    required this.school,
    required this.courseId,
    required this.courseName,
  });

  final School school;
  final String courseId;
  final String courseName;

  Future<_IntensityTeacher> _load() async {
    final data = await client.getStatsByTeachers(school.id, courseId);
    return data.answer.data.groupListsBy((e) => e.subValName).map(
        (key, value) =>
            MapEntry(key, (fio: value.first.subVal, id: value.first.subId)));
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
        subtitle: '',
        overlaySubtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 50,
                ),
                SchoolLogo(school: school),
                Text(school.name, style: context.headlineLarge),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50 + 64.0 * 2),
              child: Text(
                courseName,
                style: context.headlineMedium,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ReloadableFutureBuilder<_IntensityTeacher>(
              future: () => _load(),
              builder: (data) {
                return GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 4,
                    children: [
                      for (final subject in data.entries)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CroppedAvatar(
                                photoUrl: 'https://wq.lms-school.ru/'
                                    '?action=consolidated.photo'
                                    '&student=${subject.value.id}'
                                    '&login=${AppSettings.consolidatedLogin}'
                                    '&pass=${AppSettings.consolidatedPassword}'
                                    '&base=cons'),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(subject.key,
                                        style: context.headlineMedium),
                                    Text('${subject.value.fio}%',
                                        style: context.headlineLarge),
                                  ]),
                            ),
                          ],
                        ),
                    ]);
              }),
        ));
  }

  static Route route(School school, String courseId, String courseName) =>
      createRoute((_) => IntensityTeacher(
            school: school,
            courseId: courseId,
            courseName: courseName,
          ));
}
