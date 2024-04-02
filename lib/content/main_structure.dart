import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/content/model.dart';
import 'package:mo_school_kiosk/content/schools_list_page.dart';
import 'package:mo_school_kiosk/style.dart';

class _StructureBaselinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.0;
    final w = size.width * 0.87;
    final h = size.height;

    for (var i = 0; i < 7; i++) {
      final hLine = h / 7 * i + h / 14 + 12;
      canvas.drawLine(Offset(w * 0.1, hLine), Offset(w, hLine), paint);
    }

    canvas.drawLine(
        Offset(w, h * 0.1), Offset(w, h / 7 * 6 + h / 14 + 12), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MainStructure extends StatefulWidget {
  const MainStructure({super.key});

  @override
  State<MainStructure> createState() => _MainStructureState();
}

class _MainStructureState extends State<MainStructure> {
  Future<List<StructureModel>>? _data;

  Future<List<StructureModel>> _loadSchools(BuildContext context) async {
    final bundle = DefaultAssetBundle.of(context);

    final rawData = await bundle.loadString('assets/schools.json');
    final data = (jsonDecode(rawData) as List)
        .map<StructureModel>((e) => StructureModel.fromJson(e))
        .toList();

    final rawCitiesData = await bundle.loadString('assets/cities.json');

    final cities = (jsonDecode(rawCitiesData) as Map).map((key, value) =>
        MapEntry(key.toString(), CityModel.fromJson(key, value)));

    for (final schoolList in data) {
      for (final school in schoolList.schools ?? <SchoolModel>[]) {
        if (cities.containsKey(school.city)) {
          school.coords = cities[school.city]!;
        }
      }
    }

    return [
      StructureModel('образовательные организации', 'assets/schools/obrmo.png',
          33, [...data.expand((e) => e.schools ?? [])]),
      ...data
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CustomPaint(
        painter: _StructureBaselinePainter(),
        child: FutureBuilder(
            future: _data ??= _loadSchools(context),
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                    child: Text(
                      'СТРУКТУРА',
                      style: context.headlineLarge.copyWith(
                        color: AppColors.secondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.secondary,
                      ),
                    ),
                  ),
                  ...snapshot.data?.map((e) => _StructureCard(e)) ?? const []
                ],
              );
            }),
      ),
    );
  }
}

class _StructureCard extends StatelessWidget {
  const _StructureCard(this.model);

  final StructureModel model;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (model.schools?.isNotEmpty ?? false)
            ? () {
                Navigator.of(context).push(SchoolsListPage.route(model));
              }
            : null,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              Image.asset(model.asset),
              Positioned.fill(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(model.count.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 4.0),
                              child: Text(model.name,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          )
                        ],
                      )))
            ])),
      ),
    );
  }
}
