import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:path_provider/path_provider.dart';

int numCompare(MapEntry<School, num?> a, MapEntry<School, num?> b) {
  return ((b.value ?? 0.0) - (a.value ?? 0.0)).sign.toInt();
}

Route createRoute(Widget Function(BuildContext context) builder) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
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

  bool isSameDay(DateTime other) =>
      other.day == day && other.month == month && other.year == year;
}

class ReloadableFutureBuilder<T> extends StatefulWidget {
  const ReloadableFutureBuilder(
      {super.key, required this.future, required this.builder});

  final Future<T> Function() future;
  final Widget Function(T data) builder;

  @override
  State<ReloadableFutureBuilder> createState() =>
      _ReloadableFutureBuilderState<T>();
}

class _ReloadableFutureBuilderState<T>
    extends State<ReloadableFutureBuilder<T>> {
  late Future<T> _future = widget.future();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data as T;
              final child = widget.builder(data);
              return child;
            }
            if (snapshot.hasError) {
              return Center(
                child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        _future = widget.future();
                      });
                    },
                    child: Text(
                      'Не удалось загрузить данные. \nПовторить попытку',
                      style: context.headlineMedium,
                      textAlign: TextAlign.center,
                    )),
              );
            }

          default:
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class LmsLogger {
  static LmsLogger? _instance;
  LmsLogger._internal();
  factory LmsLogger() => _instance ??= LmsLogger._internal();

  final log = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 6,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      printTime: true,
    ),
    output: _LogFileOutput(),
  );
}

class _LogFileOutput extends LogOutput {
  _LogFileOutput();

  File? file;

  @override
  void output(OutputEvent event) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    file ??= File('${directory.path}/.kiosk-dovuz.log');

    for (var line in event.lines) {
      await file?.writeAsString("${line.toString()}\n",
          mode: FileMode.writeOnlyAppend);
      debugPrint(line);
    }
  }
}
