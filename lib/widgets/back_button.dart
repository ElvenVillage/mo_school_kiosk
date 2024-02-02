import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/style.dart';

class BackFloatingButton extends StatelessWidget {
  const BackFloatingButton({super.key, this.root = false});

  final bool root;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
          width: root ? 100 : 75,
          height: root ? 100 : 75,
          decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(48.0),
              border: Border.all(color: Colors.white)),
          child: Center(
              child: Text(
            root ? 'ГЛАВНАЯ' : 'НАЗАД',
          ))),
    );
  }
}
