import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/content/school_details_page.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/base_grid.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class _SchoolModel {
  final String name;
  final String assetName;
  final String id;

  factory _SchoolModel.fromJson(Map<String, dynamic> json) => _SchoolModel(
      json['name'], 'assets/logos/${json["logo"]}.png', json['id']);

  const _SchoolModel(this.name, this.assetName, this.id);
}

class _StructureModel {
  final String name;
  final String asset;
  final int count;

  static final _digitsRegex = RegExp(r'[^0-9]');

  final List<_SchoolModel>? schools;

  factory _StructureModel.fromJson(Map<String, dynamic> json) {
    final String title = json['title'];

    final match = _digitsRegex.firstMatch(title)!;

    final count = int.parse(title.substring(0, match.end).trim());

    final schools = (json['schools'] as List)
        .map<_SchoolModel>((e) => _SchoolModel.fromJson(e))
        .toList();

    return _StructureModel(title.replaceAll(count.toString(), "").trim(),
        'assets/schools/${json["logo"]}.png', count, schools);
  }

  const _StructureModel(this.name, this.asset, this.count, [this.schools]);
}

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
  Future<List<_StructureModel>>? _data;

  Future<List<_StructureModel>> _loadSchools(BuildContext context) async {
    final rawData =
        await DefaultAssetBundle.of(context).loadString('assets/schools.json');
    final data = (jsonDecode(rawData) as List)
        .map<_StructureModel>((e) => _StructureModel.fromJson(e))
        .toList();
    return [
      _StructureModel('образовательные организации', 'assets/schools/obrmo.png',
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

  final _StructureModel model;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (model.schools?.isNotEmpty ?? false)
            ? () {
                Navigator.of(context).push(_SchoolsListPage.route(model));
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

class _SchoolsListPage extends StatelessWidget {
  const _SchoolsListPage(this.data);

  final _StructureModel data;

  static Route route(_StructureModel data) =>
      createRoute((_) => _SchoolsListPage(data));

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: '${data.count} ${data.name}',
      body: BaseGrid(
        onTap: (school) {
          Navigator.of(context).push(SchoolDetailsPage.route(school));
        },
        schools: data.schools?.map((e) {
              final segments = e.assetName.split('/');
              final dbName = segments.last.replaceAll('.png', '');
              return School(id: e.id, name: e.name, dbName: dbName);
            }).toList() ??
            const [],
      ),
    );
  }
}
