import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/content/school_details_page.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';
// ignore: depend_on_referenced_packages
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math.dart' show radians;
import 'package:flutter_map/flutter_map.dart';
import 'package:map_controller_plus/map_controller_plus.dart';
import 'package:mo_school_kiosk/content/model.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class SchoolsListPage extends StatefulWidget {
  const SchoolsListPage(this.data, {super.key});

  final StructureModel data;

  static Route route(StructureModel data) =>
      createRoute((_) => SchoolsListPage(data));

  @override
  State<SchoolsListPage> createState() => _SchoolsListPageState();
}

class _SchoolsListPageState extends State<SchoolsListPage> {
  late final MapController mapController;
  late final StatefulMapController statefulMapController;
  late final StreamSubscription<StatefulMapControllerStateChange> sub;
  late final StreamSubscription<MapEvent> zoomSub;

  late final Proj4Crs epsg3576crs;

  final proj4.Projection epsg3576 = proj4.Projection.get('EPSG:3576') ??
      proj4.Projection.add('EPSG:3576',
          '+proj=laea +lat_0=90 +lon_0=90 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs');

  bool namedMarkers = false;

  Future<void> initMap() async {
    epsg3576crs = Proj4Crs.fromFactory(
        code: 'EPSG:3576',
        proj4Projection: epsg3576,
        resolutions: <double>[
          32768,
          16384,
          8192,
          4096,
          2048,
          1024,
          512,
          256,
          128,
          64,
          32,
          16,
          8,
          4,
        ]);

    mapController = MapController();

    zoomSub = mapController.mapEventStream.listen((event) {
      if (event.zoom > 5 && !namedMarkers) {
        setState(() {
          namedMarkers = true;
        });
        _updateMarkers();
      }

      if (event.zoom < 5 && namedMarkers) {
        setState(() {
          namedMarkers = false;
        });
        _updateMarkers();
      }
    });
    statefulMapController = StatefulMapController(mapController: mapController);

    sub = statefulMapController.changeFeed.listen((_) {
      setState(() {});
    });

    final data =
        await DefaultAssetBundle.of(context).loadString("assets/map.geojson");

    await statefulMapController.fromGeoJson(data,
        borderColor: const Color.fromARGB(255, 202, 234, 235),
        borderWidth: 0.5,
        color: AppColors.secondary,
        isFilled: true);

    _updateMarkers();
    mapController.move(LatLng(70, 90), 2.5);
  }

  var _toggled = false;

  void _updateMarkers() {
    final schoolsByCities =
        (widget.data.schools ?? <SchoolModel>[]).groupListsBy((e) => e.city);
    final entries = schoolsByCities.entries
        .sorted((a, b) => a.value.length - b.value.length);

    for (final city in entries) {
      final schools = city.value;

      if (schools.isEmpty) continue;

      final point =
          LatLng(schools.first.coords!.lat, schools.first.coords!.lon);

      if (schools.length == 1) {
        final school = schools.first;

        statefulMapController.addMarker(
            marker: Marker(
                key: Key(school.id),
                width: namedMarkers ? 512 : 64,
                height: namedMarkers ? 90 : 64,
                point: point,
                builder: (_) {
                  final model = School.fromSchoolModel(school);
                  if (namedMarkers) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(SchoolDetailsPage.route(model));
                      },
                      child: Container(
                        width: 512,
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(32.0)),
                        child: Row(
                          children: [
                            Expanded(
                                child: SchoolLogo(
                              school: model,
                              radius: 32,
                            )),
                            Expanded(
                              flex: 3,
                              child: Text(
                                model.name,
                                style: const TextStyle(
                                  color: AppColors.darkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(SchoolDetailsPage.route(model));
                    },
                    child: SchoolLogo(
                      school: model,
                    ),
                  );
                }),
            name: school.name);

        continue;
      }

      statefulMapController.addMarker(
          marker: Marker(
              key: Key(city.key),
              width: 250,
              height: 250,
              point: point,
              builder: (_) => RadialMenu(
                    schools: city.value,
                    onToggle: () {
                      // убрать остальные маркеры с числами
                      // (ниже по z-уровню)
                      if (!_toggled) {
                        statefulMapController.removeMarkers(
                            names: entries
                                .where((e) => e.key != city.key)
                                .map((e) => e.key)
                                .toList());
                      } else {
                        _updateMarkers();
                      }
                      _toggled = !_toggled;
                    },
                  )),
          name: city.key);
    }
  }

  @override
  void initState() {
    super.initState();
    initMap();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: '${widget.data.count} ${widget.data.name}',
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                  crs: epsg3576crs,
                  keepAlive: true,
                  zoom: 2.0,
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                  minZoom: 2.0,
                  maxZoom: 6.0),
              mapController: mapController,
              children: [
                PolygonLayer(
                    polygons: statefulMapController.polygons,
                    paintLabel: false),
                MarkerLayer(markers: statefulMapController.markers),
              ],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            mapController.move(
                                mapController.center, mapController.zoom + 1);
                          },
                          icon: const Icon(Icons.add)),
                      IconButton(
                          onPressed: () {
                            mapController.move(
                                mapController.center, mapController.zoom - 1);
                          },
                          icon: const Icon(Icons.minimize))
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    sub.cancel();
    zoomSub.cancel();
    mapController.dispose();
    super.dispose();
  }
}

// https://github.com/fireship-io/170-flutter-animated-radial-menu

class RadialMenu extends StatefulWidget {
  const RadialMenu({super.key, required this.schools, required this.onToggle});

  final List<SchoolModel> schools;
  final void Function() onToggle;

  @override
  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(
        controller: controller,
        schools: widget.schools,
        toggle: widget.onToggle);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RadialAnimation extends StatefulWidget {
  RadialAnimation(
      {Key? key,
      required this.controller,
      required this.schools,
      required this.toggle})
      : translation = Tween<double>(
          begin: 0.0,
          end: 100.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        ),
        scale = Tween<double>(
          begin: 1.0,
          end: 25.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        super(key: key);

  final AnimationController controller;
  final Animation<double> translation;
  final Animation<double> scale;

  final List<SchoolModel> schools;

  final void Function() toggle;

  @override
  State<RadialAnimation> createState() => _RadialAnimationState();
}

class _RadialAnimationState extends State<RadialAnimation> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: const SizedBox.shrink(),
                ),
                Transform.scale(
                    scale: widget.scale.value,
                    child: ClipOval(
                      child: Container(
                        width: 11,
                        height: 11,
                        color: Colors.white,
                      ),
                    )),
                for (var i = 0; i < widget.schools.length; i++)
                  _buildButton(360 / widget.schools.length * i,
                      color: Colors.red, onTap: () {
                    Navigator.of(context).push(SchoolDetailsPage.route(
                        School.fromSchoolModel(widget.schools[i])));
                  },
                      icon: SchoolLogo(
                          radius: 36.0,
                          school: School.fromSchoolModel(widget.schools[i]))),
                TapRegion(
                    onTapInside: (_) => _open(),
                    onTapOutside: (_) => _open(true),
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        height: 80,
                        width: 80,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: ClipOval(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration:
                                const BoxDecoration(color: AppColors.darkGreen),
                            child: Center(
                              child: Text(
                                widget.schools.length.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ]);
        });
  }

  var _wasOpened = true;

  void _open([bool? value]) {
    final val = value ?? !_wasOpened;
    if (!val) {
      widget.controller.forward();
    } else {
      widget.controller.reverse();
    }

    _wasOpened = val;
    widget.toggle();
  }

  Widget _buildButton(double angle,
      {Color? color, Widget? icon, void Function()? onTap}) {
    final double rad = radians(angle);
    return Transform(
        transform: Matrix4.identity()
          ..translate((widget.translation.value) * cos(rad),
              (widget.translation.value) * sin(rad)),
        child: GestureDetector(
            onTap: () {
              if (onTap != null) onTap();
              _open(!_wasOpened);
            },
            child: icon));
  }
}
