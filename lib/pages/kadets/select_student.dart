import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/groups.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/kadets/student_details.dart';
import 'package:mo_school_kiosk/settings.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_card.dart';
import 'package:mo_school_kiosk/widgets/cropped_avatar.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class SelectStudentPage extends StatelessWidget {
  const SelectStudentPage(this.school, this.group, {super.key});

  final School school;
  final Group group;

  static Route route(School school, Group group) =>
      createRoute((_) => SelectStudentPage(school, group));

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
        subtitle: 'Выберите обучающегося',
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BaseCard(db: school),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      group.name,
                      style: context.headlineLarge,
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: ReloadableFutureBuilder<StudentsListResponse>(
                builder: (data) {
                  final students = data.answer.data;
                  return GridView.count(
                    crossAxisCount: 5,
                    childAspectRatio: 2.2,
                    children: [
                      for (final student in students ?? const [])
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                                StudentDetailsPage.route(school, student));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                    height: 128,
                                    width: 128,
                                    child: CroppedAvatar(
                                        photoUrl: student.photoUrl(
                                            AppSettings.consolidatedLogin!,
                                            AppSettings
                                                .consolidatedPassword!))),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      24.0, 0.0, 8.0, 36.0),
                                  child: Text(
                                    student.fio,
                                    style: context.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  );
                },
                future: () => client.getStudents(school.id, group.id),
              ),
            ),
          ],
        ));
  }
}
