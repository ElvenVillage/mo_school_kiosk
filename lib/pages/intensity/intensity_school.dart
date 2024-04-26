import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_course.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/komplekt_base_card.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:provider/provider.dart';

class IntensitySchool extends StatelessWidget {
  const IntensitySchool({super.key});

  static Route route() => createRoute((_) => const IntensitySchool());

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[Indicator.intensity]!;
    final valSorted = data.entries.sorted(numCompare);

    final bool useMobileLayout = context.useMobileLayout;

    return PageTemplate(
        title: 'СРЕДНЯЯ ИНТЕНСИВНОСТЬ ОЦЕНИВАНИЯ ЗНАНИЙ',
        body: GridView.count(
            crossAxisCount: useMobileLayout ? 1 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 50,
            childAspectRatio: useMobileLayout ? 6 : 4,
            children: valSorted.mapIndexed((idx, db) {
              return Row(
                children: [
                  if (idx.isEven || useMobileLayout) const Spacer(),
                  Expanded(
                    flex: useMobileLayout ? 8 : 4,
                    child: KomplektCard(
                      onTap: () {
                        Navigator.of(context)
                            .push(IntensityCourse.route(db.key));
                      },
                      komplekt:
                          KomplektModel(null, null, null, db.value ?? 0.0, '%'),
                      db: db.key,
                    ),
                  ),
                  if (idx.isOdd || useMobileLayout) const Spacer(),
                ],
              );
            }).toList()));
  }
}
