import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';

import 'base_card.dart';

class BaseGrid extends StatelessWidget {
  const BaseGrid({super.key, required this.schools, this.onTap});

  final List<School> schools;
  final void Function(School school)? onTap;

  @override
  Widget build(BuildContext context) {
    final useMobileLayout = context.useMobileLayout;

    return GridView.count(
        crossAxisCount: useMobileLayout ? 1 : 2,
        shrinkWrap: true,
        crossAxisSpacing: 50,
        childAspectRatio: useMobileLayout ? 6 : 4,
        children: schools.mapIndexed((idx, db) {
          return Row(
            children: [
              if (idx.isEven || useMobileLayout) const Spacer(),
              Expanded(
                flex: useMobileLayout ? 8 : 4,
                child: Hero(
                  tag: db.dbName,
                  child: BaseCard(
                    db: db,
                    onTap: onTap == null ? null : () => onTap!(db),
                  ),
                ),
              ),
              if (idx.isOdd || useMobileLayout) const Spacer(),
            ],
          );
        }).toList());
  }
}
