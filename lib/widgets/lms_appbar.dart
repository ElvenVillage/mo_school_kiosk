import 'package:flutter/material.dart';

import '../style.dart';

class LmsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LmsAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      child: Row(
        children: [
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
