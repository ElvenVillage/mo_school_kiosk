import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_school.dart';
import 'package:mo_school_kiosk/pages/komplekt.dart';
import 'package:mo_school_kiosk/pages/news_screen.dart';
import 'package:mo_school_kiosk/pages/kadets/select_base.dart';
import 'package:mo_school_kiosk/schedule/schedule.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';

import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';
import 'package:mo_school_kiosk/widgets/top_five_card.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'content/main_structure.dart';
import 'content/students_count.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(fullScreen: true);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const App());
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(this.title, this.value, this.backgroundAsset, this.child,
      {this.onTap});

  final String? title;
  final String? value;
  final String backgroundAsset;
  final void Function()? onTap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              'assets/sections/$backgroundAsset',
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(title ?? '',
                                  maxLines: null,
                                  style: context.headlineLarge.copyWith(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(value ?? '',
                                style: context.headlineLarge.copyWith(
                                    fontSize: 46.0,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: AppColors.secondary.withAlpha(200),
                      child: child,
                    ),
                  ),
                  const Spacer()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => StatsProvider()..load(),
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: const LmsAppBar(
              title: 'ДОВУЗОВСКОЕ ВОЕННОЕ ОБРАЗОВАНИЕ В ЦИФРАХ'),
          body: Builder(builder: (context) {
            return Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  const Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(child: MainStructure()),
                        Expanded(child: StudentsCount()),
                        Expanded(
                          flex: 4,
                          child: MainStats(),
                        )
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Divider(
                      color: AppColors.secondary,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset('assets/top5.png'),
                        ),
                        const Expanded(
                          child: _TopFiveList(
                            caption: 'СРЕДНИЙ БАЛЛ',
                            indicator: Indicator.averageGrade,
                          ),
                        ),
                        _gap(),
                        const Expanded(
                          child: _TopFiveList(
                            caption:
                                'ПРОЦЕНТ ЗАПОЛНЕНИЯ ТЕМАТИЧЕСКОГО ПЛАНИРОВАНИЯ',
                            indicator: Indicator.plan,
                            add: '% ',
                          ),
                        ),
                        _gap(),
                        const Expanded(
                          child: _TopFiveList(
                            caption:
                                'КОЛИЧЕСТВО МЕРОПРИЯТИЙ ЗА ПОСЛЕДНИЕ 7 ДНЕЙ',
                            indicator: Indicator.events,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Container _gap() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.secondary,
      height: double.maxFinite,
      width: 1,
    );
  }
}

class _TopFiveList extends StatelessWidget {
  const _TopFiveList(
      {required this.caption, required this.indicator, this.add = ''});

  final String caption;
  final Indicator indicator;
  final String add;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[indicator] ?? {};
    final sorted = data.entries.sorted(numCompare).take(5);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TopFiveCard(title: caption, data: [
        for (final school in sorted)
          (
            title: school.key.name,
            maxValue: 29,
            value: school.value ?? 0,
            add: add
          ),
      ]),
    );
  }
}

class _TopThreeList extends StatelessWidget {
  const _TopThreeList({required this.indicator});
  final Indicator indicator;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[indicator] ?? {};
    final sorted = data.entries.sorted(numCompare).take(3);

    return Column(
      children: [
        for (final school in sorted)
          RichText(
              text: TextSpan(style: context.body, children: [
            TextSpan(text: school.value.toString()),
            TextSpan(text: school.key.name),
          ]))
      ],
    );
  }
}

class MainStats extends StatelessWidget {
  const MainStats({super.key});

  static Widget _wrap(Widget child) {
    return Row(children: [
      Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: child))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>().stats;
    final intensities = stats[Indicator.intensity]
            ?.entries
            .where((e) => e.value != null)
            .map((e) => e.value!)
            .toList() ??
        [0.0];

    final komplekts = stats[Indicator.komplekt]
            ?.entries
            .where((e) => e.value != null)
            .map((e) => e.value!)
            .toList() ??
        [0.0];

    final avgIntensity = intensities.isNotEmpty ? intensities.average : 0.0;
    final avgKomplekt = komplekts.isNotEmpty ? komplekts.average : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _SectionCard(
                'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
                avgIntensity.toString(),
                'intensity.png',
                const _TopThreeList(
                  indicator: Indicator.intensity,
                ),
                onTap: () {
                  Navigator.of(context).push(IntensitySchool.route());
                },
              ),
            ),
            Flexible(
              child: _SectionCard(
                'УКОМПЛЕКТОВАННОСТЬ ПЕДРАБОТНИКАМИ',
                avgKomplekt.toString(),
                'komplekt.png',
                const _TopThreeList(
                  indicator: Indicator.komplekt,
                ),
                onTap: () {
                  Navigator.of(context).push(KomplektPage.route());
                },
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _SectionCard(
                null,
                null,
                'personal.png',
                _wrap(
                  Text('ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
                      style: context.headlineLarge.copyWith(fontSize: 36.0)),
                ),
                onTap: () {
                  Navigator.of(context).push(SelectBasePage.route());
                },
              ),
            ),
            Flexible(
              child: _SectionCard(
                null,
                null,
                'schedule.png',
                _wrap(
                  Text(
                    'РАСПИСАНИЕ ЗАНЯТИЙ',
                    style: context.headlineLarge,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(SchedulePage.route());
                },
              ),
            ),
            Flexible(
              child: _SectionCard(
                null,
                null,
                'newsfeed.png',
                _wrap(
                  Text('НОВОСТИ', style: context.headlineLarge),
                ),
                onTap: () {
                  Navigator.of(context).push(NewsScreen.route());
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
