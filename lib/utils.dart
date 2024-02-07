import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mo_school_kiosk/api/schools.dart';

int numCompare(MapEntry<School, num?> a, MapEntry<School, num?> b) {
  return ((b.value ?? 0.0) - (a.value ?? 0.0)).sign.toInt();
}

Route createRoute(Widget Function(BuildContext context) builder) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, __) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

abstract class LmsAnswer {
  abstract final String message;
  abstract final String result;
  abstract final String code;
}

extension TimeOfDayFormat on TimeOfDay {
  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

extension ScheduleDataFormat on DateTime {
  static final _format = DateFormat.yMMMEd('ru_RU');
  String get scheduleDate => _format.format(this);
}
