import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:mo_school_kiosk/content/top_five_list.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/style.dart';

class MainPageCarousel extends StatelessWidget {
  const MainPageCarousel({super.key, required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return InfiniteCarousel.builder(
      controller: controller,
      itemExtent: context.useMobileLayout ? width * 0.92 : width / 9 * 4,
      center: false,
      itemCount: 6,
      itemBuilder: (context, itemIndex, realIndex) {
        final stats = switch (itemIndex) {
          0 => const TopFiveList(
              caption: 'СРЕДНИЙ БАЛЛ',
              indicator: Indicator.averageGrade,
              maxValue: 5.0,
            ),
          1 => const TopFiveList(
              caption: 'ПРОЦЕНТ ЗАПОЛНЕНИЯ ТЕМАТИЧЕСКОГО ПЛАНИРОВАНИЯ',
              indicator: Indicator.plan,
              maxValue: 100.0,
              add: '% ',
            ),
          2 => const TopFiveList(
              caption: 'ПРОЦЕНТ КОММЕНТИРОВАНИЯ ВЫСТАВЛЕННЫХ ОЦЕНОК',
              indicator: Indicator.commentsGrades,
              add: '%',
            ),
          3 => const TopFiveList(
              caption: 'ПРОЦЕНТ ЗАНЯТИЙ С ЭЛЕКТРОННЫМИ МАТЕРИАЛАМИ',
              indicator: Indicator.elMaterials,
              add: '%',
            ),
          4 => const TopFiveList(
              caption: 'КОЛИЧЕСТВО СТОБАЛЛЬНИКОВ ПО ЕГЭ',
              indicator: Indicator.score100),
          _ => const TopFiveList(
              caption: 'КОЛИЧЕСТВО МЕРОПРИЯТИЙ ЗА ПОСЛЕДНИЕ 7 ДНЕЙ',
              indicator: Indicator.events,
            )
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: stats),
            if (!context.useMobileLayout) _gap()
          ],
        );
      },
    );
  }

  Container _gap() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.secondary,
      height: double.maxFinite,
      width: 1,
    );
  }
}
