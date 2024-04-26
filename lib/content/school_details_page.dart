import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/phonebook.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/kadets/select_group.dart';
import 'package:mo_school_kiosk/pages/news_screen.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/schedule/schedule.dart';
import 'package:mo_school_kiosk/settings.dart';
import 'package:mo_school_kiosk/style.dart';
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
            title: widget.school.name.toUpperCase(),
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
        if (!context.useMobileLayout)
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

  String _formatValue(num? value, {String? add, int? digits}) {
    if (value == null) return 'Нет данных';
    if (digits != null) {
      return '${value.toStringAsFixed(digits).replaceAll(".", ",")}${add ?? ""}';
    }
    return '${value.toString().replaceAll(".", ",")}${add ?? ""}';
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
      data.info.email ?? '',
      countData.fact.studentsPlural,
      countData.plan.studentsPlural,
      (countData.plan - countData.fact).studentsPlural,
      _formatValue(stats[Indicator.komplekt]![widget.school], add: '%'),
      _formatValue(stats[Indicator.averageGrade]![widget.school], digits: 2),
      _formatValue(stats[Indicator.intensity]![widget.school], add: '%'),
      _formatValue(stats[Indicator.plan]![widget.school], add: '%'),
      _formatValue(stats[Indicator.commentsGrades]![widget.school], add: '%'),
      _formatValue(stats[Indicator.elMaterials]![widget.school], add: '%'),
      _formatValue(stats[Indicator.events]![widget.school]),
    ];

    final style = Theme.of(context).textTheme.titleLarge;
    final addressWidget = Text(
      data.info.address.replaceAll('\n', ''),
      style: style,
    );

    final size = MediaQuery.of(context).size;
    final schoolDataWidget = Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _dataColumn(captions.take(6).toList(), style,
                  values.take(6).toList(), true),
              _dataColumn(captions.sublist(6), style, values.sublist(6), true)
            ],
          ),
        ],
      ),
    );

    if (context.useMobileLayout) {
      return SingleChildScrollView(
        physics: const PageScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: size.height - kToolbarHeight,
              child: Column(
                children: [addressWidget, Expanded(child: schoolDataWidget)],
              ),
            ),
            SizedBox(
              height: size.height - kToolbarHeight,
              child: _administrationGrid(data),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        addressWidget,
        schoolDataWidget,
        Expanded(
          flex: 2,
          child: _administrationGrid(data),
        )
      ],
    );
  }

  Expanded _dataColumn(
      List<String> captions, TextStyle? style, List<String> values, bool left) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: left ? 2 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: captions
                  .map((e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$e:', maxLines: 1, style: style),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 35),
          Expanded(
            flex: left ? 1 : 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: values
                  .map((e) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          e,
                          maxLines: 1,
                          style: style,
                        ),
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
      'Заместитель НУ (по ИОТ)',
      'Заместитель НУ (по учебной работе)',
      'Заместитель НУ (по воспитательной работе)'
    ].map((e) => e.toLowerCase());

    final adminContacts = data.phones.where(
        (e) => administrationEntries.contains(e.bookEntry.toLowerCase()));

    final administration = [
      ...adminContacts,
      for (var i = 0; i < 4 - adminContacts.length; i++) null
    ];

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
        if (!context.useMobileLayout)
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _RoundButton(
                  caption: 'НОВОСТИ',
                  size: 95,
                  onTap: () {
                    Navigator.of(context).push(NewsScreen.route(widget.school));
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RoundButton(
                      caption: 'РАСПИСАНИЕ',
                      size: 120,
                      onTap: () {
                        Navigator.of(context)
                            .push(ScheduleGroupsPage.route(widget.school));
                      },
                    ),
                    const SizedBox(width: 15),
                    _RoundButton(
                      caption: 'ЛИЧНЫЕ ДЕЛА',
                      size: 85,
                      onTap: () {
                        Navigator.of(context)
                            .push(SelectGroupPage.route(widget.school));
                      },
                    ),
                  ],
                )
              ],
            ),
          ))
      ],
    );
  }

  Widget _administrationEntry(PhonebookContact? e) {
    if (e == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CroppedAvatar(
                photoUrl: 'https://wq.lms-school.ru/?action=consolidated.photo'
                    '&base=cons'
                    '&login=${AppSettings.consolidatedLogin!}'
                    '&pass=${AppSettings.consolidatedPassword}'
                    '&student=${e.mid}'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    e.bookEntry,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      e.fio.split(' ').join('\n'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    e.workPhone.isEmpty ? e.mobilePhone : e.workPhone,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.caption,
    required this.onTap,
    required this.size,
  });

  final String caption;
  final void Function() onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 219, 219, 219)),
          child: Center(
              child: Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.darkGreen),
          )),
        ),
      ),
    );
  }
}
