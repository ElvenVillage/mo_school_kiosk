import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';

class KomplektModel {
  final num? total;
  final num? first;
  final num? highest;
  final double value;

  int get firstNum => (total ?? 0) * (first ?? 0) ~/ 100;
  int get highestNum => (total ?? 0) * (highest ?? 0) ~/ 100;

  KomplektModel(this.total, this.first, this.highest, this.value);
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
                  child: CircleAvatar(
                      radius: 64.0, backgroundImage: NetworkImage(db.imgUrl)),
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      db.name,
                      style: context.body
                          .copyWith(decoration: TextDecoration.underline),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dataRow(komplekt.total.toString(),
                                  'всего педработников', context),
                              _dataRow(komplekt.firstNum.toString(),
                                  'первой категории', context),
                              _dataRow(komplekt.highestNum.toString(),
                                  'высшей категории', context),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${komplekt.value}%',
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
