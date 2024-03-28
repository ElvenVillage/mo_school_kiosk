import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/phonebook.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';
import 'package:provider/provider.dart';

class SchoolDetailsPage extends StatelessWidget {
  const SchoolDetailsPage({super.key, required this.school});
  final School school;

  static Route route(School school) =>
      createRoute((context) => SchoolDetailsPage(school: school));

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageTemplate(
            title: school.name,
            body: SizedBox(
                width: double.maxFinite,
                child: FutureBuilder(
                    future: Future.wait([
                      client.getPhonebookReport(school.id),
                      _getStudentsCount()
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final schoolData =
                            snapshot.data?.first as PhonebookResponse?;
                        final countData =
                            snapshot.data?.last as ({int fact, int plan});
                        return _schoolData(context, schoolData, countData);
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }))),
        Positioned(
          top: 32,
          left: 36,
          child: SchoolLogo(
            school: school,
            radius: 90.0,
          ),
        )
      ],
    );
  }

  Future<({int fact, int plan})> _getStudentsCount() async {
    final data = await client.getCountReport(school.id);

    final result = data.answer.data.classes.fold(
        (fact: 0, plan: 0),
        (prev, next) => (
              fact: prev.fact + next.studentsFact,
              plan: prev.plan + next.studentsPlan
            ));

    return result;
  }

  Widget _schoolData(BuildContext context, PhonebookResponse? schoolData,
      ({int fact, int plan}) countData) {
    final data = schoolData?.answer.data.schools.first;
    if (data == null) return const Text('Не удалось получить данные');

    final stats = context.watch<StatsProvider>().stats;

    final captions = [
      'Телефон',
      'E-mail',
      'Обучающихся',
      'Штатная численность',
      'Некомплект',
      'Укомплектованность педработниками',
      'Средний балл',
      'Интенсивность оценивания знаний',
      'Заполнение тематического планирования',
      'Комментарии к оценкам',
      'Занятия с электронными материалами',
      'Количество мероприятий за последние 7 дней',
    ];

    final values = [
      data.info.phone,
      data.info.phone,
      '${countData.fact}',
      '${countData.plan} человек',
      '${countData.plan - countData.fact} человек',
      '${stats[Indicator.komplekt]![school]}%',
      '${stats[Indicator.averageGrade]![school]}',
      '${stats[Indicator.intensity]![school]}%',
      '${stats[Indicator.plan]![school]}%',
      '${stats[Indicator.commentsGrades]![school]}%',
      '${stats[Indicator.elMaterials]![school]}%',
      '${stats[Indicator.events]![school]}',
    ];

    return Column(
      children: [
        Expanded(child: Text(data.info.address.replaceAll('\n', ''))),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: captions
                            .take(6)
                            .map((e) => Text(e, maxLines: 1))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 35),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: values
                            .take(6)
                            .map((e) => Text(e, maxLines: 1))
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: captions
                            .sublist(6)
                            .map((e) => Text(e, maxLines: 1))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 35),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: values
                            .sublist(6)
                            .map((e) => Text(e, maxLines: 1))
                            .toList(),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: _administrationGrid(data),
        )
      ],
    );
  }

  Widget _administrationGrid(PhonebookDataEntry data) {
    final administrationEntries = [
      'Начальник училища',
      'Заместитель НУ (по учебной работе)',
      'Заместитель НУ (по ИОТ)',
      'Заместитель НУ (по воспитательной работе)'
    ].map((e) => e.toLowerCase());

    final administration = data.phones
        .where((e) => administrationEntries.contains(e.bookEntry.toLowerCase()))
        .toList();

    return Row(
      children: [
        Expanded(
          child: Column(
              children: administration
                  .take(2)
                  .map((e) => Expanded(child: _administrationEntry(e)))
                  .toList()),
        ),
        Expanded(
          child: Column(
              children: administration
                  .sublist(2)
                  .map((e) => Expanded(child: _administrationEntry(e)))
                  .toList()),
        )
      ],
    );
  }

  Widget _administrationEntry(PhonebookContact e) {
    return Row(
      children: [
        CircleAvatar(
          radius: 64.0,
          backgroundImage: NetworkImage(
              'https://wq.lms-school.ru/?action=pub_image&person=${e.mid}&base=${school.dbName}'),
        ),
        Text('${e.bookEntry}\n${e.fio.split(' ').join('\n')}'),
      ],
    );
  }
}
