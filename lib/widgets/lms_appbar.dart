import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/consts.dart';

import '../style.dart';

class LmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LmsAppBar(
      {super.key, required this.title, this.displayVersion = false});
  final String title;
  final bool displayVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      child: Row(
        children: [
          if (displayVersion)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 20.0),
                child: Text(
                  'v$kPackageVersion',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            )
          else
            const Spacer(),
          Text(title,
              style: const TextStyle(
                  fontSize: 48.0,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Image.asset('assets/lms_logo.png'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
