import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/style.dart';

class TopFiveCard extends StatelessWidget {
  const TopFiveCard({super.key, required this.title, required this.data});

  final String title;
  final List<({num value, String title, num maxValue, String add})> data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: AppColors.secondary),
          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold)),
              )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.asset('assets/icons/star.png'),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Column(children: [
          for (final entry in data)
            Row(
              children: [
                Expanded(
                    child: Text(
                  entry.value.toString().replaceAll('.', ',') + entry.add,
                  style: context.body.copyWith(color: AppColors.secondary),
                )),
                Expanded(
                    child: LinearProgressIndicator(
                  minHeight: 20,
                  value: entry.value / entry.maxValue,
                  backgroundColor: Colors.transparent,
                  color: AppColors.secondary,
                )),
                Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18.0),
                      ),
                    ))
              ],
            )
        ])
      ],
    );
  }
}
