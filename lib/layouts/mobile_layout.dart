import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/content/main_page_carousel.dart';
import 'package:mo_school_kiosk/content/main_stats.dart';
import 'package:mo_school_kiosk/content/main_structure.dart';
import 'package:mo_school_kiosk/content/students_count.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';

class MobileLayoutMainPage extends StatelessWidget {
  const MobileLayoutMainPage({super.key, required this.carouselController});
  final ScrollController carouselController;

  @override
  Widget build(BuildContext context) {
    final lmsAppBar = LmsAppBar(
        useMobileLayout: context.useMobileLayout,
        displayVersion: true,
        title: 'ДОВУЗОВСКОЕ ВОЕННОЕ ОБРАЗОВАНИЕ В ЦИФРАХ');
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const PageScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight, child: lmsAppBar),
          SizedBox(
              height: size.height - kToolbarHeight,
              child: const MainStructure(direction: Axis.horizontal)),
          SizedBox(height: size.height, child: const StudentsCountPage()),
          SizedBox(height: size.height, child: const MainStats()),
          SizedBox(
              height: size.height,
              child: Column(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      const SizedBox(
                        width: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset('assets/top5.png'),
                      ),
                    ],
                  )),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: MainPageCarousel(controller: carouselController),
                      )),
                ],
              ))
        ],
      ),
    );
  }
}
