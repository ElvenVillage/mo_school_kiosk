import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';

import 'base_card.dart';

class SchoolLogo extends StatelessWidget {
  const SchoolLogo({super.key, required this.school, this.radius = 64.0});

  final School school;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: BaseCard.getBaseImage(school),
        builder: (context, snapshot) {
          return CircleAvatar(
              backgroundColor: Colors.white,
              radius: radius,
              foregroundImage: snapshot.data);
        });
  }
}
