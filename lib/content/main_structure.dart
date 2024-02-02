import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/style.dart';

class _StructureModel {
  final String name;
  final String asset;
  final int count;

  const _StructureModel(this.name, this.asset, this.count);
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

class MainStructure extends StatelessWidget {
  const MainStructure({super.key});

  final _structs = const [
    _StructureModel('образовательные организаций', 'obrmo.png', 32),
    _StructureModel('президентских\nкадетских\nучилищ', 'pku.png', 7),
    _StructureModel('суворовских\nвоенных\nучилищ', 'svu.png', 10),
    _StructureModel(
        'Нахимовское военно-морское училище\n+4 филиала', 'nvmu.png', 1),
    _StructureModel('кадетских\nвоенных\nкорпусов', 'kvk.png', 6),
    _StructureModel('школы для одаренных\nдетей при ВВУЗах', 'shod.png', 3),
    _StructureModel('Московское\nвоенно-музыкальное\nучилище', 'muz.png', 1)
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CustomPaint(
        painter: _StructureBaselinePainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 12.0),
              child: Text(
                'СТРУКТУРА',
                style:
                    context.headlineLarge.copyWith(color: AppColors.secondary),
              ),
            ),
            ..._structs.map((e) => _StructureCard(e)).toList()
          ],
        ),
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
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(children: [
            Image.asset('assets/schools/${model.asset}'),
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
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Text(model.name,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        )
                      ],
                    )))
          ])),
    );
  }
}
