import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/pages/kadets/select_student.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_card.dart';
import 'package:mo_school_kiosk/widgets/group_grid.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class SelectGroupPage extends StatelessWidget {
  const SelectGroupPage(this.school, {super.key});

  final School school;

  static Route route(School base) => createRoute((_) => SelectGroupPage(base));

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'ЛИЧНЫЕ ДЕЛА ОБУЧАЮЩИХСЯ',
        subtitle: 'Выберите класс',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(tag: school.dbName, child: BaseCard(db: school)),
          ),
          Expanded(
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final groups = snapshot.data!.answer.data;
                  return GroupGrid(
                    groups: groups,
                    school: school,
                    onTap: (group) {
                      Navigator.of(context)
                          .push(SelectStudentPage.route(school, group));
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              future: client.getGroups(school.id),
            ),
          ),
        ]));
  }
}
