import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/komplekt_base_card.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:mo_school_kiosk/widgets/top_five_card.dart';
import 'package:provider/provider.dart';

class TopFiveList extends StatelessWidget {
  const TopFiveList({
    super.key,
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
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(TopFivePage.route(caption: caption, indicator: indicator));
        },
        child: TopFiveCard(title: caption, data: [
          for (final school in sorted)
            (
              title: school.key.name,
              maxValue: maxValue ?? sorted.first.value!,
              value: school.value ?? 0,
              add: add
            ),
        ]),
      ),
    );
  }
}

class TopFivePage extends StatelessWidget {
  const TopFivePage({
    super.key,
    required this.caption,
    required this.indicator,
  });

  final String caption;
  final Indicator indicator;

  static Route route({required String caption, required Indicator indicator}) =>
      createRoute(
          (context) => TopFivePage(caption: caption, indicator: indicator));

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>().stats[indicator] ?? {};
    final sorted = data.entries.sorted(numCompare);

    final width = MediaQuery.of(context).size.width;

    final add = switch (indicator) { Indicator.plan => '%', _ => '' };

    return PageTemplate(
        title: caption,
        body: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 50,
              childAspectRatio: 5,
              children: sorted.mapIndexed((idx, db) {
                return Row(
                  children: [
                    if (idx.isEven) const Spacer(),
                    Expanded(
                      flex: 4,
                      child: KomplektCard(
                          db: db.key,
                          komplekt:
                              KomplektModel(null, null, null, db.value!, add)),
                    ),
                    if (idx.isOdd) const Spacer(),
                  ],
                );
              }).toList()),
        ));
  }
}
