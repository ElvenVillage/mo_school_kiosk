import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/intensity/intensity_course.dart';
import 'package:mo_school_kiosk/style.dart';

class SchoolValueCard extends StatelessWidget {
  const SchoolValueCard(
      {super.key, required this.school, required this.value, this.add = ''});

  final School school;
  final num? value;
  final String add;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 120,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(IntensityCourse.route(school));
        },
        child: RichText(
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
              text: value != null ? '$value$add ' : '',
              style: context.headlineLarge,
              children: [
                TextSpan(text: school.name, style: context.headlineMedium)
              ]),
        ),
      ),
    );
  }
}
