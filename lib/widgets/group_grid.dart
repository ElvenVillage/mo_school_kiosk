import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../api/groups.dart';
import '../api/schools.dart';
import '../style.dart';

class _GroupButton extends StatelessWidget {
  const _GroupButton({
    super.key,
    required this.school,
    required this.group,
    this.onTap,
  });

  final School school;
  final Group group;
  final void Function(Group group)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(group),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.darkGreen,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(64.0)),
          child: Text(
            group.name,
          ),
        ),
      ),
    );
  }
}

class GroupGrid extends StatelessWidget {
  const GroupGrid(
      {super.key, required this.groups, required this.school, this.onTap});

  final List<Group> groups;
  final School school;
  final void Function(Group group)? onTap;

  @override
  Widget build(BuildContext context) {
    final rows = groups.groupListsBy((e) => e.kurs);
    return Column(
      children: rows.values
          .map((row) => Row(
                children: row
                    .map((group) => _GroupButton(
                          key: Key(group.id),
                          school: school,
                          group: group,
                          onTap: onTap,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
