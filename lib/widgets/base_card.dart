import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({super.key, this.onTap, required this.db});

  final void Function()? onTap;
  final School db;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.darkGreen,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(64.0)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      radius: 64.0, backgroundImage: NetworkImage(db.imgUrl)),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Text(db.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.headlineLarge),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
