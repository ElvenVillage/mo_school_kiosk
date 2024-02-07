import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:provider/provider.dart';

class StudentsCount extends StatelessWidget {
  const StudentsCount({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StatsProvider>();

    final countM = (data.stats[Indicator.countM] ?? {})
        .entries
        .fold(0.0, (prev, next) => prev + (next.value ?? 0))
        .toInt();

    final countF = (data.stats[Indicator.countF] ?? {})
        .entries
        .fold(0.0, (prev, next) => prev + (next.value ?? 0))
        .toInt();

    final medals = (data.stats[Indicator.medals] ?? {})
        .entries
        .where((e) => e.value != null)
        .toList()
        .sorted(numCompare)
        .take(3);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'ЧИСЛЕННОСТЬ',
              style: context.headlineLarge.copyWith(color: AppColors.secondary),
            ),
          ),
          Column(
            children: [
              Text(
                'Всего обучающихся',
                style: context.body.copyWith(fontSize: 26.0),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: '${countF + countM}', style: context.headlineLarge),
                TextSpan(text: ' человек', style: context.body)
              ])),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/more/boy.png',
                            height: 85,
                          ),
                          Text(
                            '$countM\nчел.',
                            style: context.body,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/more/girl.png',
                          height: 85,
                        ),
                        Text(
                          '$countF\nчел.',
                          textAlign: TextAlign.center,
                          style: context.body,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: AppColors.secondary),
          const _MaxAdmission(),
          const Divider(color: AppColors.secondary),
          Column(children: [
            Row(
              children: [
                Image.asset('assets/icons/medal.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 36.0),
                  child: Text('УДОСТОЕНЫ МЕДАЛИ\n«ЗА ОСОБЫЕ\n УСПЕХИ В УЧЕНИИ»',
                      textAlign: TextAlign.right,
                      style: context.body.copyWith(
                          color: AppColors.secondary, fontSize: 14.0)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'ТОП 3',
                style: context.body.copyWith(color: AppColors.secondary),
              ),
            ),
            Column(
              children: [
                for (final medal in medals)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          medal.key.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '${medal.value}',
                                  style: context.headlineMedium,
                                ),
                                const TextSpan(text: '\nчел')
                              ])),
                        ),
                      )
                    ],
                  )
              ],
            )
          ])
        ],
      ),
    );
  }
}

class _MaxAdmission extends StatelessWidget {
  const _MaxAdmission();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>().stats;
    final (mStats, fStats) = (
      stats[Indicator.admissionM]?.entries.sorted(numCompare),
      stats[Indicator.admissionF]?.entries.sorted(numCompare)
    );

    final (maxM, maxF) = (mStats?.first, fStats?.first);
    final maximum = (maxM?.value ?? 0) > (maxF?.value ?? 0) ? maxM : maxF;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'МАКСИМАЛЬНЫЙ КОНКУРС',
          style: context.body.copyWith(
              fontSize: 18.0,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  maximum?.key.name ?? '',
                  maxLines: null,
                  style: context.body,
                ),
              ),
              if (maximum?.key.imgUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(maximum!.key.imgUrl),
                  radius: 36.0,
                )
            ],
          ),
        ),
        if (maxF?.value != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  maxF?.value.toString().replaceAll('.', ',') ?? '0',
                  style: context.headlineMedium,
                ),
              ),
              const Expanded(
                child: Text(
                  'человек/место\nдевочки',
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        if (maxM?.value != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  maxM?.value.toString().replaceAll('.', ',') ?? '0',
                  style: context.headlineMedium,
                ),
              ),
              const Expanded(
                child: Text(
                  'человек/место\nмальчики',
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
      ],
    );
  }
}
