import 'package:flutter/material.dart';
import 'package:mo_school_kiosk/style.dart';

class SectionCard extends StatelessWidget {
  const SectionCard(this.title, this.value, this.backgroundAsset, this.child,
      {super.key, this.onTap, this.details = false});

  final String? title;
  final String? value;
  final String backgroundAsset;
  final void Function()? onTap;
  final bool details;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(width / 1980 * 32.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              'assets/sections/$backgroundAsset',
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(title ?? '',
                                maxLines: null,
                                style: context.headlineLarge.copyWith(
                                    fontSize: width / 1980 * 20.0,
                                    fontWeight: FontWeight.bold))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              (value?.isEmpty ?? true)
                                  ? ''
                                  : (num.tryParse(value ?? '0.0') ?? 0.0)
                                      .toDouble()
                                      .toStringAsFixed(1)
                                      .replaceAll('.', ','),
                              style: context.headlineLarge.copyWith(
                                fontSize: width / 1980 * 85.0,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.secondary.withAlpha(200),
                    child: child,
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 24.0, bottom: 16.0),
                          child: Text(details ? 'подробнее' : '',
                              style: context.headlineMedium.copyWith(
                                decoration: TextDecoration.underline,
                              )),
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
