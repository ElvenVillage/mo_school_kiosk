import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mo_school_kiosk/api/api.dart';
import 'package:mo_school_kiosk/layouts/desktop_layout.dart';
import 'package:mo_school_kiosk/layouts/mobile_layout.dart';
import 'package:mo_school_kiosk/providers/data_provider.dart';
import 'package:mo_school_kiosk/settings.dart';

import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/widgets/back_button.dart';
import 'package:mo_school_kiosk/widgets/lms_appbar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  HttpOverrides.global = MyHttpOverrides();

  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      fullScreen: true,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  await AppSettings.load();
  consolidatedDio.interceptors.add(ConsolidatedInterceptor(
      login: AppSettings.consolidatedLogin!,
      password: AppSettings.consolidatedPassword!));

  runApp(const App());
}

class NavigatorListener extends ChangeNotifier {
  var depth = 0;
  void update(int event) {
    depth += event;
    notifyListeners();
  }
}

class MyNavigatorObserver extends RouteObserver<PageRoute> {
  final NavigatorListener listener;

  MyNavigatorObserver(this.listener);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    listener.update(-1);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    listener.update(1);
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigator = GlobalKey<NavigatorState>();
  final _listener = NavigatorListener();

  final _carouselController = InfiniteScrollController();

  Timer? _timer;

  @override
  void initState() {
    _setupTimer();
    super.initState();

    _carouselController.addListener(_setupTimer);
  }

  void _setupTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _carouselController.nextItem();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lmsAppBar = LmsAppBar(
        useMobileLayout: context.useMobileLayout,
        displayVersion: true,
        title: 'ДОВУЗОВСКОЕ ВОЕННОЕ ОБРАЗОВАНИЕ В ЦИФРАХ');
    return ChangeNotifierProvider(
      lazy: false,
      create: (context) => StatsProvider()
        ..load()
        ..setupTimer(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            MaterialApp(
              navigatorObservers: [MyNavigatorObserver(_listener)],
              navigatorKey: _navigator,
              scrollBehavior: CustomScrollBehavior(),
              theme: ThemeData.dark().copyWith(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  platform: TargetPlatform.macOS,
                  highlightColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  progressIndicatorTheme:
                      const ProgressIndicatorThemeData(color: Colors.white),
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: AppColors.primary)),
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                appBar: context.useMobileLayout ? null : lmsAppBar,
                body: Builder(builder: (context) {
                  return Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/background.png'),
                            fit: BoxFit.cover)),
                    child: Builder(builder: (context) {
                      if (context.useMobileLayout) {
                        return MobileLayoutMainPage(
                            carouselController: _carouselController);
                        // return SingleChildScrollView(
                        //   child: Column(
                        //     children: [
                        //       SizedBox(
                        //           height: kToolbarHeight, child: lmsAppBar),
                        //       SizedBox(
                        //         height: MediaQuery.of(context).size.height,
                        //         child: topPart,
                        //       ),
                        //       SizedBox(
                        //           height:
                        //               MediaQuery.of(context).size.height * 0.4,
                        //           child: bottomPart)
                        //     ],
                        //   ),
                        // );
                      }

                      return DesktopLayout(
                          carouselController: _carouselController);
                    }),
                  );
                }),
              ),
            ),
            Builder(builder: (context) {
              final provider = context.watch<StatsProvider>();

              if (provider.stats.isEmpty) {
                return Container(
                  color: Colors.grey.withAlpha(100),
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.error.isNotEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text('Не удалось загрузить данные'),
                              ],
                            ),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )),
                );
              }
              return const SizedBox.shrink();
            }),
            if (!context.useMobileLayout)
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: BackFloatingButton(_navigator, _listener))
          ],
        ),
      ),
    );
  }
}
