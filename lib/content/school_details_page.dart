import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/phonebook.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/settings.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/cropped_avatar.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';
import 'package:provider/provider.dart';

class SchoolDetailsPage extends StatefulWidget {
  const SchoolDetailsPage({super.key, required this.school});
  final School school;

  static Route route(School school) =>
      createRoute((context) => SchoolDetailsPage(school: school));

  @override
  State<SchoolDetailsPage> createState() => _SchoolDetailsPageState();
}

class _SchoolDetailsPageState extends State<SchoolDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageTemplate(
            title: widget.school.name,
            body: SizedBox(
                width: double.maxFinite,
                child: FutureBuilder(
                    future: Future.wait([
                      client.getPhonebookReport(widget.school.id),
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
            school: widget.school,
            radius: 90.0,
          ),
        )
      ],
    );
  }

  Future<({int fact, int plan})> _getStudentsCount() async {
    final data = await client.getCountReport(widget.school.id);

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
      '${stats[Indicator.komplekt]![widget.school]}%',
      '${stats[Indicator.averageGrade]![widget.school]}',
      '${stats[Indicator.intensity]![widget.school]}%',
      '${stats[Indicator.plan]![widget.school]}%',
      '${stats[Indicator.commentsGrades]![widget.school]}%',
      '${stats[Indicator.elMaterials]![widget.school]}%',
      '${stats[Indicator.events]![widget.school]}',
    ];

    final style = Theme.of(context).textTheme.bodyLarge;

    return Column(
      children: [
        Text(
          data.info.address.replaceAll('\n', ''),
          style: style,
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  _dataColumn(captions.take(6).toList(), style,
                      values.take(6).toList()),
                  _dataColumn(captions.sublist(6), style, values.sublist(6))
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _administrationGrid(data),
        )
      ],
    );
  }

  Expanded _dataColumn(
      List<String> captions, TextStyle? style, List<String> values) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: captions
                  .map((e) => Text('$e:', maxLines: 1, style: style))
                  .toList(),
            ),
          ),
          const SizedBox(width: 35),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: values
                  .map((e) => Text(
                        e,
                        maxLines: 1,
                        style: style,
                      ))
                  .toList(),
            ),
          )
        ],
      ),
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
        ),
        const Expanded(
          child: SizedBox(),
        )
      ],
    );
  }

  Widget _administrationEntry(PhonebookContact e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CroppedAvatar(
              photoUrl: 'https://wq.lms-school.ru/?action=consolidated.photo'
                  '&base=cons'
                  '&login=${AppSettings.consolidatedLogin!}'
                  '&pass=${AppSettings.consolidatedPassword}'
                  '&student=${e.mid}'),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              '${e.bookEntry}\n${e.fio.split(' ').join('\n')}\n${e.workPhone.isEmpty ? e.mobilePhone : e.workPhone}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
