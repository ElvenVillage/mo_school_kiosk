import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/groups.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/api/student.dart';
import 'package:mo_school_kiosk/settings.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';

class StudentDetailsPage extends StatelessWidget {
  const StudentDetailsPage(
      {super.key, required this.school, required this.student});

  final School school;
  final Student student;

  static Route route(School school, Student student) =>
      createRoute((_) => StudentDetailsPage(school: school, student: student));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: LmsAppBar(
        title: 'ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
        useMobileLayout: context.useMobileLayout,
      ),
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

                  final userAvatar = Image.network(student.photoUrl(
                      AppSettings.consolidatedLogin!,
                      AppSettings.consolidatedPassword!));

                  final fio = Text(
                    student.fio,
                    style: context.useMobileLayout
                        ? context.headlineMedium.copyWith(fontSize: 24.0)
                        : context.headlineMedium,
                  );

                  final dataRows = [
                    _dataRow(
                        'Место рождения', data.info.first.birthplace, context),
                    _dataRow('Дата рождения',
                        data.info.first.birthday.substring(0, 10), context),
                    _dataRow('Военный округ', data.info.first.militaryDistrict,
                        context),
                    _dataRow('Зачислен',
                        data.info.first.enterDate.substring(0, 10), context),
                    _dataRow('Отец', data.info.first.father, context),
                    _dataRow('Мать', data.info.first.mother, context)
                  ];

                  if (context.useMobileLayout) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: size.height - kToolbarHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      userAvatar,
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: fio,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: dataRows))
                              ],
                            ),
                          ),
                          _GradesCard(data: data)
                        ],
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: userAvatar,
                              ),
                            ),
                            if (!context.useMobileLayout)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SchoolLogo(school: school),
                                    const SizedBox(
                                      height: 72.0,
                                    ),
                                    fio
                                  ],
                                ),
                              )
                            else
                              const Spacer(),
                          ]),
                          ...dataRows
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
            if (!context.useMobileLayout)
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
    final headlineMedium = context.useMobileLayout
        ? context.headlineMedium.copyWith(fontSize: 20.0)
        : context.headlineMedium;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('$title: ',
                  style: headlineMedium.copyWith(
                      decoration: TextDecoration.underline)),
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

  Widget _row(String text, BuildContext context, TextStyle style) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (context.useMobileLayout) const SizedBox(width: 35),
            Expanded(
              child: Text(
                text,
                style: style,
              ),
            ),
            const SizedBox(width: 45)
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final useMobileLayout = context.useMobileLayout;
    final headlineMedium = useMobileLayout
        ? context.headlineMedium.copyWith(fontSize: 16.0)
        : context.headlineMedium;

    final headlineLarge = useMobileLayout
        ? context.headlineLarge.copyWith(fontSize: 20.0)
        : context.headlineLarge;

    final rewards = data.awards.where((e) => e.isPenalty == '0');
    // final penalties = data.awards.where((e) => e.isPenalty != '0');

    final grades = [
      Text(
        'Текущая успеваемость:',
        style: headlineLarge.copyWith(decoration: TextDecoration.underline),
      ),
      for (final subj in data.grades)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (useMobileLayout) const SizedBox(width: 35),
              Expanded(
                child: Text(
                  subj.subject,
                  style: headlineMedium,
                ),
              ),
              Expanded(
                child: Text(
                  subj.grades.split(',').join(' '),
                  style: headlineMedium,
                ),
              )
            ],
          ),
        ),
      const SizedBox(height: 25),
      Text(
        'Поощрения:',
        style: headlineLarge.copyWith(decoration: TextDecoration.underline),
      ),
      for (final award in rewards)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _row(award.reason, context, headlineMedium),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!useMobileLayout) ...[
          const SizedBox(
            height: 50,
          ),
        ],
        const SizedBox(
          height: 50,
        ),
        if (context.useMobileLayout)
          Column(children: grades)
        else
          Expanded(
            child: ListView(
              children: grades,
            ),
          )
      ],
    );
  }
}
