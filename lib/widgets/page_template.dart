import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/style.dart';

import 'lms_appbar.dart';

class PageTemplate extends StatelessWidget {
  const PageTemplate({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.overlaySubtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? overlaySubtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: LmsAppBar(title: title),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (subtitle != null)
                Expanded(
                    child: Center(
                        child: Text(subtitle!, style: context.headlineLarge)))
              else
                const SizedBox(height: kToolbarHeight),
              Expanded(flex: 9, child: body),
            ]),
          ),
        ),
        if (overlaySubtitle != null)
          Positioned(
            top: kToolbarHeight * 0.5,
            child: overlaySubtitle!,
          ),
      ],
    );
  }
}
