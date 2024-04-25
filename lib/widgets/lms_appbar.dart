import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/consts/consts.dart';

import '../style.dart';

class LmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LmsAppBar(
      {super.key,
      required this.title,
      this.displayVersion = false,
      required this.useMobileLayout});
  final String title;
  final bool displayVersion;
  final bool useMobileLayout;

  @override
  Widget build(BuildContext context) {
    final collapseTitle = title.length > 50;

    final width = MediaQuery.of(context).size.width;

    final titleWidget = Text(title,
        maxLines: collapseTitle ? 2 : 1,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: width / 1980 * (collapseTitle ? 32.0 : 48.0),
            color: AppColors.primary,
            fontWeight: FontWeight.bold));

    return Container(
      color: AppColors.secondary,
      child: Row(
        children: [
          if (displayVersion)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text(
                  'v$kPackageVersion\n$kBuildDate',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16.0, color: AppColors.darkGreen),
                ),
              ),
            )
          else
            const Spacer(),
          if (collapseTitle)
            Expanded(
              flex: 4,
              child: titleWidget,
            )
          else
            titleWidget,
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
  Size get preferredSize => useMobileLayout
      ? const Size.fromHeight(kToolbarHeight)
      : const Size.fromHeight(kToolbarHeight * 2);
}
