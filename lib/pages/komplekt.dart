import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/komplekt_base_card.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:provider/provider.dart';

class KomplektPage extends StatelessWidget {
  const KomplektPage({super.key});

  static Route route() => createRoute((_) => const KomplektPage());

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>();
    final reports = data.reports.entries;

    final [totalTeachers, firstCat, hightCat] = [
      data.getReportData(ReportIndicator.totalTeachers),
      data.getReportData(ReportIndicator.firstCat),
      data.getReportData(ReportIndicator.highCat),
    ];

    return PageTemplate(
        title: 'УКОМПЛЕКТОВАННОСТЬ ПЕДРАБОТНИКАМИ',
        body: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 50,
            childAspectRatio: 5,
            children: reports.mapIndexed((idx, db) {
              return Row(
                children: [
                  if (idx.isEven) const Spacer(),
                  Expanded(
                    flex: 4,
                    child: KomplektCard(
                      komplekt: KomplektModel(totalTeachers[db.key],
                          firstCat[db.key], hightCat[db.key], 0),
                      db: db.key,
                    ),
                  ),
                  if (idx.isOdd) const Spacer(),
                ],
              );
            }).toList()));
  }
}
