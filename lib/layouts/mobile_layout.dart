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
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight, child: lmsAppBar),
          const MainStructure(direction: Axis.horizontal),
          SizedBox(height: size.height, child: const StudentsCount()),
          SizedBox(height: size.height, child: const MainStats()),
          SizedBox(
              height: size.height * 0.5,
              child: MainPageCarousel(controller: carouselController))
        ],
      ),
    );
  }
}
