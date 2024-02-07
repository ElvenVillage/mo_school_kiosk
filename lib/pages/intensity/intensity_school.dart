import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_course.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:provider/provider.dart';

class IntensitySchool extends StatelessWidget {
  const IntensitySchool({super.key});

  static Route route() => createRoute((_) => const IntensitySchool());

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[Indicator.intensity]!;
    final sorted = data.entries.sorted(numCompare);

    return PageTemplate(
        title: 'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
        body: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 50,
          mainAxisSpacing: 50,
          childAspectRatio: 20,
          children: [
            for (final school in sorted)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(IntensityCourse.route(school.key));
                },
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      text: '${school.value}% ',
                      style: context.headlineLarge,
                      children: [
                        TextSpan(
                            text: school.key.name,
                            style: context.headlineMedium)
                      ]),
                ),
              )
          ],
        ));
  }
}
