import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:mo_school_kiosk/widgets/school_value_card.dart';
import 'package:provider/provider.dart';

class IntensitySchool extends StatelessWidget {
  const IntensitySchool({super.key});

  static Route route() => createRoute((_) => const IntensitySchool());

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[Indicator.intensity]!;
    final sorted = data.entries.sorted(numCompare);

    final width = MediaQuery.of(context).size.width;

    return PageTemplate(
        title: 'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.05),
              child: Wrap(
                children: [
                  for (final school in sorted)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SchoolValueCard(
                        school: school.key,
                        value: school.value,
                        add: '%',
                      ),
                    )
                ],
              ),
            ),
          ),
        ));
  }
}
