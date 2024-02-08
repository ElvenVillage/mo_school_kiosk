import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/groups.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/api/student.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';

class StudentDetailsPage extends StatelessWidget {
  const StudentDetailsPage(
      {super.key, required this.school, required this.student});

  final School school;
  final Student student;

  static Route route(School school, Student student) =>
      createRoute((_) => StudentDetailsPage(school: school, student: student));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const LmsAppBar(title: 'ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ'),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background2.png'),
                fit: BoxFit.cover)),
        child: Stack(
          children: [
            Column(children: [
              Expanded(
                  child: ReloadableFutureBuilder<StudentDetailsResponse>(
                builder: (response) {
                  final data = response.answer.data;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Image.network(
                                    student.photoUrl('nnz', 'Sonyk12345678')),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                      radius: 64.0,
                                      backgroundImage:
                                          NetworkImage(school.imgUrl)),
                                  const SizedBox(
                                    height: 72.0,
                                  ),
                                  Text(
                                    student.fio,
                                    style: context.headlineMedium,
                                  )
                                ],
                              ),
                            )
                          ]),
                          _dataRow('Место рождения', data.info.first.birthplace,
                              context),
                          _dataRow(
                              'Дата рождения',
                              data.info.first.birthdate.substring(0, 10),
                              context),
                          _dataRow('Военный округ',
                              data.info.first.militaryDistrict, context),
                          _dataRow(
                              'Зачислен',
                              data.info.first.enterDate.substring(0, 10),
                              context),
                          _dataRow('Отец', data.info.first.father, context),
                          _dataRow('Мать', data.info.first.mother, context)
                        ]),
                      ),
                      Expanded(
                          flex: 2,
                          child: _GradesCard(
                            data: data,
                            key: Key(data.info.first.id),
                          )),
                    ],
                  );
                },
                future: () => client.getStudentDetails(school.id, student.id),
              )),
            ]),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20),
                child: Text(
                  school.name,
                  style: context.headlineLarge,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String title, String value, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$title: ',
                  style: context.headlineMedium
                      .copyWith(decoration: TextDecoration.underline)),
            ),
          ),
        ),
        Expanded(
            child: Text(
          value,
          style: context.headlineMedium.copyWith(fontSize: 18.0),
        ))
      ],
    );
  }
}

class _GradesCard extends StatelessWidget {
  const _GradesCard({
    super.key,
    required this.data,
  });

  final StudentDetais data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 150,
        ),
        Text(
          'Текущая успеваемость:',
          style: context.headlineLarge
              .copyWith(decoration: TextDecoration.underline),
        ),
        const SizedBox(
          height: 50,
        ),
        Expanded(
          child: ListView(
            children: [
              for (final subj in data.grades)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          subj.subject,
                          style: context.headlineMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          subj.grades.split(',').join(' '),
                          style: context.headlineMedium,
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
