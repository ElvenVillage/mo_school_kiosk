import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({super.key, this.onTap, required this.db});

  final void Function()? onTap;
  final School db;

  static final _images = <String, ImageProvider>{};

  static Future<ImageProvider> getBaseImage(School db) async {
    if (_images.containsKey(db.dbName)) {
      return _images[db.dbName]!;
    }
    try {
      final path = 'assets/logos/${db.dbName}.png';
      await rootBundle.load(path);
      _images[db.dbName] = AssetImage(path);
    } catch (_) {
      _images[db.dbName] = NetworkImage(db.imgUrl);
    }
    return _images[db.dbName]!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
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
                    child: FutureBuilder<ImageProvider>(
                        future: getBaseImage(db),
                        builder: (context, snapshot) {
                          return CircleAvatar(
                              radius: context.useMobileLayout ? 48.0 : 64.0,
                              backgroundColor: Colors.white,
                              foregroundImage:
                                  snapshot.hasData ? snapshot.data! : null);
                        }),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Text(db.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.useMobileLayout
                              ? context.headlineLarge.copyWith(fontSize: 24.0)
                              : context.headlineLarge),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
