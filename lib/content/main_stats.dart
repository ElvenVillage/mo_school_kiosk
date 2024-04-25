import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_school.dart';
import 'package:mo_school_kiosk/pages/kadets/select_base.dart';
import 'package:mo_school_kiosk/pages/komplekt.dart';
import 'package:mo_school_kiosk/pages/news_screen.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/schedule/schedule.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:provider/provider.dart';

import 'section_card.dart';
import 'top_three_list.dart';

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

    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SectionCard(
                  'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
                  avgIntensity.toStringAsFixed(1),
                  'intensity.png',
                  const TopThreeList(
                    indicator: Indicator.intensity,
                  ),
                  onTap: () {
                    Navigator.of(context).push(IntensitySchool.route());
                  },
                  details: true,
                ),
              ),
              Flexible(
                child: SectionCard(
                  'УКОМПЛЕКТОВАННОСТЬ ПЕДРАБОТНИКАМИ',
                  avgKomplekt.toString(),
                  'komplekt.png',
                  const TopThreeList(
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
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SectionCard(
                  null,
                  null,
                  'personal.png',
                  _wrap(
                    Text('ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
                        style: context.headlineLarge
                            .copyWith(fontSize: width / 1980 * 36.0)),
                  ),
                  onTap: () {
                    Navigator.of(context).push(SelectBasePage.route());
                  },
                ),
              ),
              Flexible(
                child: SectionCard(
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
                child: SectionCard(
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
          ),
        )
      ],
    );
  }
}
