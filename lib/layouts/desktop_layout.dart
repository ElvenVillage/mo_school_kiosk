import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/content/main_page_carousel.dart';
import 'package:mo_school_kiosk/content/main_stats.dart';
import 'package:mo_school_kiosk/content/main_structure.dart';
import 'package:mo_school_kiosk/content/students_count.dart';
import 'package:mo_school_kiosk/style.dart';

class DesktopLayout extends StatelessWidget {
  final ScrollController carouselController;
  const DesktopLayout({super.key, required this.carouselController});

  @override
  Widget build(BuildContext context) {
    const topPart = Row(
      children: [
        Expanded(
            child: MainStructure(
          direction: Axis.vertical,
        )),
        Expanded(child: StudentsCountPage()),
        Expanded(
          flex: 4,
          child: MainStats(),
        )
      ],
    );

    final bottomPart = Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset('assets/top5.png'),
          ),
        ),
        Expanded(
            flex: 8,
            child: MainPageCarousel(
              controller: carouselController,
            )),
      ],
    );
    return Column(
      children: [
        const Expanded(
          flex: 4,
          child: topPart,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Divider(
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: bottomPart,
        )
      ],
    );
  }
}
