import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';

class KomplektModel {
  final num? total;
  final num? first;
  final num? highest;
  final num value;
  final String add;

  int get firstNum => (total ?? 0) * (first ?? 0) ~/ 100;
  int get highestNum => (total ?? 0) * (highest ?? 0) ~/ 100;

  KomplektModel(this.total, this.first, this.highest, this.value, this.add);
}

class KomplektCard extends StatelessWidget {
  const KomplektCard(
      {super.key, this.onTap, required this.db, required this.komplekt});

  final void Function()? onTap;
  final School db;
  final KomplektModel komplekt;

  Widget _dataRow(String val, String title, BuildContext context) {
    return Row(children: [
      Text(val, style: context.body.copyWith(fontWeight: FontWeight.bold)),
      Text(' $title', style: context.body),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.darkGreen,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(64.0)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SchoolLogo(school: db),
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: Text(
                              db.name,
                              style: context.body.copyWith(
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (komplekt.total != null)
                                _dataRow(komplekt.total.toString(),
                                    'всего педработников', context),
                              if (komplekt.first != null)
                                _dataRow(komplekt.firstNum.toString(),
                                    'первой категории', context),
                              if (komplekt.highest != null)
                                _dataRow(komplekt.highestNum.toString(),
                                    'высшей категории', context),
                            ],
                          ),
                          if (komplekt.total != null) const Spacer(flex: 3),
                          if (komplekt.value > 0.0)
                            Text(
                              '${komplekt.value}${komplekt.add}',
                              style: context.headlineLarge,
                            ),
                          const Spacer(),
                        ],
                      ),
                    )
                  ],
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
