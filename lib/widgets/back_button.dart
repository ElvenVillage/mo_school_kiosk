import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/main.dart';
import 'package:mo_school_kiosk/style.dart';

class BackFloatingButton extends StatelessWidget {
  const BackFloatingButton(this.navigator, this.listener, {super.key});

  final GlobalKey<NavigatorState> navigator;
  final NavigatorListener listener;

  static const _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: listener,
        builder: (context, _) {
          final depth = listener.depth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  navigator.currentState?.pop();
                },
                child: AnimatedOpacity(
                  opacity: depth > 2 ? 1.0 : 0.0,
                  duration: _duration,
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      width: depth > 2 ? 75 : 0,
                      height: depth > 2 ? 75 : 0,
                      decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(48.0),
                          border: Border.all(color: Colors.white)),
                      child: const Center(
                          child: Text(
                        'НАЗАД',
                      ))),
                ),
              ),
              GestureDetector(
                onTap: () {
                  navigator.currentState?.popUntil((route) => route.isFirst);
                },
                child: AnimatedOpacity(
                  opacity: depth > 1 ? 1.0 : 0.0,
                  duration: _duration,
                  child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.all(8.0),
                      width: depth > 1 ? 100 : 0,
                      height: depth > 1 ? 100 : 0,
                      decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          borderRadius: BorderRadius.circular(48.0),
                          border: Border.all(color: Colors.white)),
                      child: const Center(
                          child: Text(
                        'ГЛАВНАЯ',
                      ))),
                ),
              ),
            ],
          );
        });
  }
}
