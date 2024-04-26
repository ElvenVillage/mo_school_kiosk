import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_card.dart';
import 'package:provider/provider.dart';

class StudentsCountPage extends StatelessWidget {
  const StudentsCountPage({super.key});

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

    final width = MediaQuery.of(context).size.width;

    final useMobileLayout = context.useMobileLayout;

    final pageTitle = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'ЧИСЛЕННОСТЬ',
        style: context.headlineLarge.copyWith(
          color: AppColors.secondary,
          fontSize: width / 1980 * 32.0,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.secondary,
        ),
      ),
    );
    final studentsCountColumn = _StudentsCountColumn(
        context: context, width: width, countF: countF, countM: countM);
    final medalsCountColumn = _MedalsCountColumn(width: width, medals: medals);

    if (useMobileLayout) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: studentsCountColumn),
                const VerticalDivider(color: AppColors.secondary),
                const Expanded(
                  child: _MaxAdmission(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.secondary),
          Expanded(
            child: medalsCountColumn,
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          if (!useMobileLayout) pageTitle,
          studentsCountColumn,
          const Divider(color: AppColors.secondary),
          const _MaxAdmission(),
          const Divider(color: AppColors.secondary),
          medalsCountColumn
        ],
      ),
    );
  }
}

class _MedalsCountColumn extends StatelessWidget {
  const _MedalsCountColumn({
    required this.width,
    required this.medals,
  });

  final double width;
  final Iterable<MapEntry<School, num?>> medals;

  @override
  Widget build(BuildContext context) {
    final medalsAssets = [
      Expanded(child: Image.asset('assets/icons/medal.png')),
      Expanded(
        flex: 4,
        child: Text('УДОСТОЕНЫ МЕДАЛИ\n«ЗА ОСОБЫЕ\n УСПЕХИ В УЧЕНИИ»',
            textAlign: TextAlign.right,
            style: context.body.copyWith(
                color: AppColors.secondary, fontSize: width / 1980 * 14.0)),
      )
    ];

    final medalsList = [
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
    ];

    if (context.useMobileLayout) {
      return Row(
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: medalsAssets,
          )),
          Expanded(flex: 2, child: Column(children: medalsList))
        ],
      );
    }
    return Column(children: [
      Row(
        children: medalsAssets,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'ТОП 3',
          style: context.body.copyWith(color: AppColors.secondary),
        ),
      ),
      Column(
        children: medalsList,
      )
    ]);
  }
}

class _StudentsCountColumn extends StatelessWidget {
  const _StudentsCountColumn({
    required this.context,
    required this.width,
    required this.countF,
    required this.countM,
  });

  final BuildContext context;
  final double width;
  final int countF;
  final int countM;

  @override
  Widget build(BuildContext context) {
    final useMobileLayout = context.useMobileLayout;

    final body =
        useMobileLayout ? context.body.copyWith(fontSize: 18.0) : context.body;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Всего обучающихся',
              style: context.body.copyWith(
                  fontSize: width / 1980 * (useMobileLayout ? 24.0 : 24.0)),
              textAlign: TextAlign.center,
              maxLines: 1),
        ),
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '${countF + countM}',
              style: useMobileLayout
                  ? context.headlineLarge.copyWith(fontSize: 24.0)
                  : context.headlineLarge),
          TextSpan(
              text: ' человек',
              style: useMobileLayout
                  ? context.body.copyWith(fontSize: 20.0)
                  : context.body)
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
                      height: width / 1980 * (useMobileLayout ? 160 : 85),
                    ),
                    Text(
                      '$countM\nчел.',
                      style: body,
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
                    height: width / 1980 * (useMobileLayout ? 160 : 85),
                  ),
                  Text(
                    '$countF\nчел.',
                    textAlign: TextAlign.center,
                    style: body,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MaxAdmission extends StatelessWidget {
  const _MaxAdmission();

  List<Widget> _getMaxCountColumn(num? val, bool useMobileLayout,
          TextStyle headlineMedium, TextStyle body, String title) =>
      [
        Expanded(
          child: Text(
            val?.toStringAsPrecision(3).replaceAll('.', ',') ?? '0',
            style: headlineMedium.copyWith(
                fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ),
        Expanded(
          child: Text(
            'человек/место\n$title',
            style: body,
            textAlign: useMobileLayout ? TextAlign.center : TextAlign.right,
          ),
        )
      ];

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>().stats;
    final (mStats, fStats) = (
      stats[Indicator.admissionM]?.entries.sorted(numCompare),
      stats[Indicator.admissionF]?.entries.sorted(numCompare)
    );

    final (maxM, maxF) = (mStats?.first, fStats?.first);
    final maximum = (maxM?.value ?? 0) > (maxF?.value ?? 0) ? maxM : maxF;

    final width = MediaQuery.of(context).size.width;

    final useMobileLayout = context.useMobileLayout;
    final body =
        useMobileLayout ? context.body.copyWith(fontSize: 16.0) : context.body;

    final headlineMedium = useMobileLayout
        ? context.headlineMedium.copyWith(fontSize: 16.0)
        : context.headlineMedium;

    final maxFWidgets = _getMaxCountColumn(
        maxF?.value, useMobileLayout, headlineMedium, body, 'девочки');

    final maxMWidgets = _getMaxCountColumn(
        maxM?.value, useMobileLayout, headlineMedium, body, 'мальчики');

    var schoolLogoBuilder = FutureBuilder(
      future: maximum == null
          ? Future.value(null)
          : BaseCard.getBaseImage(maximum.key),
      builder: (context, snapshot) => CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: snapshot.data,
        radius: width / 1980 * (useMobileLayout ? 72.0 : 36.0),
      ),
    );
    return Column(
      crossAxisAlignment: useMobileLayout
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            useMobileLayout ? 'Максимальный конкурс' : 'МАКСИМАЛЬНЫЙ КОНКУРС',
            style: context.body.copyWith(
                fontSize: width / 1980 * (useMobileLayout ? 24.0 : 18.0),
                color: useMobileLayout ? Colors.white : AppColors.secondary,
                fontWeight: useMobileLayout ? null : FontWeight.bold),
            maxLines: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (useMobileLayout) ...[
                schoolLogoBuilder,
                const SizedBox(width: 15)
              ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    maximum?.key.name ?? '',
                    maxLines: null,
                    style: body,
                  ),
                ),
              ),
              if (!useMobileLayout) schoolLogoBuilder
            ],
          ),
        ),
        if (useMobileLayout)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: maxFWidgets,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: maxMWidgets,
                  ),
                ),
              ],
            ),
          )
        else ...[
          if (maxF?.value != null)
            Row(
              children: maxFWidgets,
            ),
          if (maxM?.value != null)
            Row(
              children: maxMWidgets,
            ),
        ]
      ],
    );
  }
}
