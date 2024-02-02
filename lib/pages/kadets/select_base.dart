import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/pages/kadets/select_group.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_grid.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:provider/provider.dart';

class SelectBasePage extends StatelessWidget {
  const SelectBasePage({super.key});

  static Route route() => createRoute((_) => const SelectBasePage());

  @override
  Widget build(BuildContext context) {
    final schools = context.watch<StatsProvider>().schools;
    return PageTemplate(
        title: 'ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
        subtitle: 'Выберите образовательную организацию',
        body: schools.isNotEmpty
            ? BaseGrid(
                schools: schools,
                onTap: (db) {
                  Navigator.of(context).push(SelectGroupPage.route(db));
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
