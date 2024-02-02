import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';

import 'base_card.dart';

class BaseGrid extends StatelessWidget {
  const BaseGrid({super.key, required this.schools, this.onTap});

  final List<School> schools;
  final void Function(School school)? onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        crossAxisSpacing: 50,
        childAspectRatio: 5,
        children: schools.mapIndexed((idx, db) {
          return Row(
            children: [
              if (idx.isEven) const Spacer(),
              Expanded(
                flex: 4,
                child: Hero(
                  tag: db.dbName,
                  child: BaseCard(
                    db: db,
                    onTap: onTap == null ? null : () => onTap!(db),
                  ),
                ),
              ),
              if (idx.isOdd) const Spacer(),
            ],
          );
        }).toList());
  }
}
