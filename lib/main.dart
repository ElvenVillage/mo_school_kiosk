import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
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
import 'package:mo_school_kiosk/widgets/back_button.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';
import 'package:mo_school_kiosk/widgets/top_five_card.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'content/main_structure.dart';
import 'content/students_count.dart';

class CustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      fullScreen: true,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const App());
}

class NavigatorListener extends ChangeNotifier {
  var depth = 0;
  void update(int event) {
    depth += event;
    notifyListeners();
  }
}

class MyNavigatorObserver extends RouteObserver<PageRoute> {
  final NavigatorListener listener;

  MyNavigatorObserver(this.listener);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    listener.update(-1);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    listener.update(1);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(this.title, this.value, this.backgroundAsset, this.child,
      {this.onTap, this.details = false});

  final String? title;
  final String? value;
  final String backgroundAsset;
  final void Function()? onTap;
  final bool details;

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
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                          child: Text((value ?? '').replaceAll('.', ','),
                              style: context.headlineLarge.copyWith(
                                fontSize: 85.0,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.secondary.withAlpha(200),
                    child: child,
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 24.0, bottom: 16.0),
                          child: Text(details ? 'подробнее' : '',
                              style: context.headlineMedium.copyWith(
                                decoration: TextDecoration.underline,
                              )),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigator = GlobalKey<NavigatorState>();
  final _listener = NavigatorListener();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => StatsProvider()..load(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            MaterialApp(
              navigatorObservers: [MyNavigatorObserver(_listener)],
              navigatorKey: _navigator,
              scrollBehavior: CustomScrollBehavior(),
              theme: ThemeData.dark().copyWith(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  platform: TargetPlatform.macOS,
                  highlightColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  progressIndicatorTheme:
                      const ProgressIndicatorThemeData(color: Colors.white),
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: AppColors.primary)),
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
                                  maxValue: 5.0,
                                ),
                              ),
                              _gap(),
                              const Expanded(
                                child: _TopFiveList(
                                  caption:
                                      'ПРОЦЕНТ ЗАПОЛНЕНИЯ ТЕМАТИЧЕСКОГО ПЛАНИРОВАНИЯ',
                                  indicator: Indicator.plan,
                                  maxValue: 100.0,
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
            Builder(builder: (context) {
              final data = context.watch<StatsProvider>().stats;
              if (data.isEmpty) {
                return Container(
                  color: Colors.grey.withAlpha(100),
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: const Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  )),
                );
              }
              return const SizedBox.shrink();
            }),
            Positioned(
                bottom: 0,
                right: 0,
                child: BackFloatingButton(_navigator, _listener))
          ],
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
  const _TopFiveList({
    required this.caption,
    required this.indicator,
    this.add = '',
    this.maxValue,
  });

  final String caption;
  final Indicator indicator;
  final String add;
  final double? maxValue;

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
            maxValue: maxValue ?? sorted.first.value!,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Builder(builder: (context) {
                  final value = switch (indicator) {
                    Indicator.komplekt =>
                      '${(school.value ?? 0.0).toStringAsFixed(0)}%',
                    _ => '${((school.value ?? 0.0) / 100).toStringAsFixed(2)} '
                  };

                  return Expanded(
                    child: Text(value.replaceAll('.', ','),
                        style: context.headlineMedium
                            .copyWith(fontWeight: FontWeight.bold)),
                  );
                }),
                Expanded(
                    flex: 6,
                    child: Text(
                      school.key.name,
                      style: context.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            ),
          )
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
                avgIntensity.toStringAsFixed(1),
                'intensity.png',
                const _TopThreeList(
                  indicator: Indicator.intensity,
                ),
                onTap: () {
                  Navigator.of(context).push(IntensitySchool.route());
                },
                details: true,
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
                details: true,
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
                  Text('НОВОСТИ\n', style: context.headlineLarge),
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
