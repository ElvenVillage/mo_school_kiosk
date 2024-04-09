import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/content/school_details_page.dart';
import 'package:mo_school_kiosk/event_channel.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/widgets/school_logo.dart';
// ignore: depend_on_referenced_packages
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math.dart' show radians;
// import 'package:flutter_map/flutter_map.dart';
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
  late final StreamSubscription multitouchSub;

  late final Proj4Crs epsg3576crs;

  final proj4.Projection epsg3576 = proj4.Projection.get('EPSG:3576') ??
      proj4.Projection.add('EPSG:3576',
          '+proj=laea +lat_0=90 +lon_0=90 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs');

  bool _namedMarkers = false;
  final _zoomLevelStream = BehaviorSubject<bool>();
  static const zoomThreshold = 6;

  var _zoom = 1;

  void _handleZoom(double zoomValue) {
    final zoom = zoomValue.toInt();
    if (_zoom == zoom) return;
    _zoom = zoom;

    if (zoom >= zoomThreshold && !_namedMarkers) {
      _namedMarkers = true;

      _zoomLevelStream.sink.add(false);
    }

    if (zoom < zoomThreshold && _namedMarkers) {
      _namedMarkers = false;

      _zoomLevelStream.sink.add(true);
    }

    _updateMarkers();
  }

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
      if (event is MapEventMove) {
        _handleZoom(event.targetZoom);
        return;
      }
      _handleZoom(event.zoom);
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
            marker: _singularMarker(school, point), name: school.name);

        continue;
      }

      statefulMapController.addMarker(
          marker: _groupMarker(city, point), name: city.key);
    }
  }

  Marker _groupMarker(MapEntry<String, List<SchoolModel>> city, LatLng point) {
    return Marker(
        key: Key(city.key),
        width: 250,
        height: 250,
        point: point,
        builder: (_) => RadialMenu(
              schools: city.value,
              zoomLevelStream: _zoomLevelStream,
            ));
  }

  Marker _singularMarker(SchoolModel school, LatLng point) {
    return Marker(
        key: Key(school.id),
        width: _namedMarkers ? 512 : 64,
        height: _namedMarkers ? 90 : 64,
        point: point,
        builder: (_) {
          final model = School.fromSchoolModel(school);
          if (_namedMarkers) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(SchoolDetailsPage.route(model));
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
                    SchoolLogo(
                      school: model,
                      radius: 36.0,
                    ),
                    Expanded(
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
              Navigator.of(context).push(SchoolDetailsPage.route(model));
            },
            child: SchoolLogo(
              school: model,
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    initMap();
    _initMultitouch();
  }

  final _mapKey = GlobalKey<FlutterMapState>();

  void _initMultitouch() {
    multitouchSub =
        GtkMultitouchEventChannel.streamFromNative().listen((event) {
      // print('${event.runtimeType} $event');
      final scale = double.tryParse(event['scale'].toString()) ?? 1.0;
      // final x = double.tryParse(event['scale'].toString()) ?? 1.0;
      // final y = double.tryParse(event['scale'].toString()) ?? 1.0;

      if (scale == 1.0) return;

      final nZoom = (mapController.zoom * scale - mapController.zoom);

      mapController.move(
          mapController.center, mapController.zoom + nZoom * 0.2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: '${widget.data.count} ${widget.data.name}',
        body: Stack(
          children: [
            FlutterMap(
              key: _mapKey,
              options: MapOptions(
                  crs: epsg3576crs,
                  boundsOptions: const FitBoundsOptions(
                    forceIntegerZoomLevel: true,
                    inside: true,
                  ),
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
                            final nZoom = (_zoom + 1).toDouble();
                            final move =
                                mapController.move(mapController.center, nZoom);
                            if (move) _handleZoom(nZoom);
                          },
                          icon: const Icon(Icons.add)),
                      IconButton(
                          onPressed: () {
                            final nZoom = (_zoom - 1).toDouble();
                            final move =
                                mapController.move(mapController.center, nZoom);
                            if (move) _handleZoom(nZoom);
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
    _zoomLevelStream.close();
    multitouchSub.cancel();
    mapController.dispose();
    super.dispose();
  }
}

// https://github.com/fireship-io/170-flutter-animated-radial-menu

class RadialMenu extends StatefulWidget {
  const RadialMenu(
      {super.key, required this.schools, required this.zoomLevelStream});

  final List<SchoolModel> schools;

  // раскрытие при приближении
  final BehaviorSubject<bool> zoomLevelStream;

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
      zoomLevelStream: widget.zoomLevelStream,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RadialAnimation extends StatefulWidget {
  RadialAnimation({
    Key? key,
    required this.controller,
    required this.zoomLevelStream,
    required this.schools,
  })  : translation = Tween<double>(
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

  final BehaviorSubject<bool> zoomLevelStream;

  @override
  State<RadialAnimation> createState() => _RadialAnimationState();
}

class _RadialAnimationState extends State<RadialAnimation> {
  late final StreamSubscription<bool> _zoomSub;
  var _namedMarkers = false;

  @override
  void initState() {
    super.initState();
    if (widget.zoomLevelStream.valueOrNull ?? false) {
      final val = widget.zoomLevelStream.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _open(val);
      });
    }
    _zoomSub = widget.zoomLevelStream.listen((event) {
      setState(() {
        _open(event);
        _namedMarkers = !event;
      });
    });
  }

  @override
  void dispose() {
    _zoomSub.cancel();
    super.dispose();
  }

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
                        width: 12,
                        height: 12,
                        color: Colors.white,
                      ),
                    )),
                for (var i = 0; i < widget.schools.length; i++)
                  _buildButton(360 / widget.schools.length * i, onTap: () {
                    Navigator.of(context).push(SchoolDetailsPage.route(
                        School.fromSchoolModel(widget.schools[i])));
                  },
                      icon: SchoolLogo(
                          radius: 42.0,
                          school: School.fromSchoolModel(widget.schools[i]))),
                TapRegion(
                    onTapInside: (_) => _open(),
                    onTapOutside: _namedMarkers ? null : (_) => _open(true),
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        height: 90,
                        width: 90,
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
  }

  Widget _buildButton(double angle, {Widget? icon, void Function()? onTap}) {
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
