import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:provider/provider.dart';

class TopThreeList extends StatelessWidget {
  const TopThreeList({super.key, required this.indicator});
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ))
              ],
            ),
          )
      ],
    );
  }
}
