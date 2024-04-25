import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:mo_school_kiosk/api/schools.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.school});

  final School? school;

  static const rssUrls = {
    'akkde': 'http://adekkk.mil.ru/More/Novosti/rss',
    'esvu': 'http://eksvu.mil.ru/more/Novosti/rss',
    'kisvvs': 'https://vva.mil.ru/more/Novosti/rss',
    'ksitvas': 'http://itschool.mil.ru/more/Novosti/rss',
    'kskvifk': 'http://vifk.mil.ru/more/Novosti/rss',
    'ksvu': 'http://kzsvu.mil.ru/More/Novosti/rss',
    'kemerovo': 'http://kempku.mil.ru/more/Novosti/rss',
    'kpku': 'http://kpku.mil.ru/More/Novosti/rss',
    'kmkk': 'http://kmkk.mil.ru/more/Novosti/rss',
    'kizil': 'http://kzpku.mil.ru/More/Novosti/rss',
    'mvmu': 'http://mvmu.mil.ru/More/Novosti/rss',
    'msvu': 'http://msvu.mil.ru/more/Novosti/rss',
    'nvmu': 'http://nvmu.mil.ru/Media/Novosti/rss',
    'vlpku': 'http://vlnvmu.mil.ru/more/Novosti/rss',
    'mnvmu': 'http://mrnvmu.mil.ru/Ob_uchilische/Novosti/rss',
    'sevastopol': 'http://sevnvmu.mil.ru/More/Novosti/rss',
    'okk': 'https://okvk.mil.ru/More/Novosti/rss',
    'opku': 'http://opku.mil.ru/dop.stranicy/Novosti/rss',
    'pansion': 'http://pansion.mil.ru/more/Novosti/rss',
    'permsvu': 'http://psvu.mil.ru/more/Novosti/rss',
    'ppku': 'http://petrpku.mil.ru/more/Novosti/rss',
    'spbkk': 'http://spbkk.mil.ru/more/Novosti/rss',
    'spbsvu': 'http://spbsvu.mil.ru/more/Novosti/rss',
    'sksvu': 'http://sksvu.mil.ru/more/Novosti/rss',
    'stpku': 'http://stpku.mil.ru/Novosti/rss',
    'tlsvu': 'http://tlsvu.mil.ru/Novosti/rss',
    'tsvu': 'https://tvsvu.mil.ru/More/Novosti/rss',
    'tpku': 'http://tpku.mil.ru/more/Novosti/rss',
    'ulsvu': 'http://ulgsvu.mil.ru/more/Novosti/rss',
    'usvu': 'http://ussvu.mil.ru/More/Novosti/rss',
    'pansion2': 'http://spb.pansion.mil.ru/more/Novosti/rss',
  };

  static Route route([School? school]) =>
      createRoute((_) => NewsScreen(school: school));

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  SharedPreferences? _prefs;

  Stream<List<RssItem>> _fetchNews() async* {
    _prefs ??= await SharedPreferences.getInstance();

    final savedSchools = widget.school == null
        ? NewsScreen.rssUrls.keys
        : [widget.school!.dbName];

    final cachedResult = <RssItem>[];

    for (final key in savedSchools) {
      final data = _prefs?.getString(key);
      if (data != null) {
        cachedResult.addAll(RssFeed.parse(data).items);
      }
    }

    if (cachedResult.isNotEmpty) {
      yield cachedResult..sort((a, b) => b.date.compareTo(a.date));
    }

    final dio = Dio(BaseOptions(responseType: ResponseType.plain));

    final result = <RssItem>[];

    for (final school in savedSchools) {
      try {
        final response = (await dio.get(NewsScreen.rssUrls[school]!)).data;
        result.addAll(RssFeed.parse(response).items);
        await _prefs?.setString(school, response.toString());
      } catch (_) {}
    }
    yield result..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    final useMobileLayout = context.useMobileLayout;

    return PageTemplate(
        title: 'НОВОСТИ',
        body: StreamBuilder(
          stream: _fetchNews(),
          builder: (context, snapshot) {
            if (snapshot.data?.isNotEmpty ?? false) {
              final data = snapshot.data!;
              return GridView.count(
                crossAxisCount: useMobileLayout ? 2 : 3,
                childAspectRatio: 2,
                crossAxisSpacing: 50,
                mainAxisSpacing: 50,
                children: [
                  for (final newsItem in data)
                    _NewsCard(
                      newsItem,
                      key: Key(newsItem.title!),
                    )
                ],
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard(this.item, {super.key});
  final RssItem item;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.useMobileLayout
        ? context.body.copyWith(fontSize: 12)
        : context.body;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(NewsDetailsScreen.route(item));
      },
      child: FutureBuilder(
          future: NewsDetailsScreen.parseNewspage(item),
          builder: (context, snapshot) {
            return Container(
              decoration: BoxDecoration(
                  image: snapshot.data?.isNotEmpty ?? false
                      ? DecorationImage(
                          image: NetworkImage(snapshot.data!.first),
                          fit: BoxFit.cover)
                      : item.enclosure?.url != null
                          ? DecorationImage(
                              image: NetworkImage(item.enclosure!.url!),
                              fit: BoxFit.cover)
                          : null),
              child: Column(
                children: [
                  const Spacer(),
                  Expanded(
                      child: Container(
                          color: AppColors.secondary.withAlpha(200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item.title ?? '',
                                    style: bodyStyle,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Источник: ${Uri.parse(item.link!).host}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.formattedDate,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ))),
                ],
              ),
            );
          }),
    );
  }
}

extension ParseDate on RssItem {
  static final _format = DateFormat('E, d MMM yyyy HH:mm:ss zzz', 'en_US');
  static final _displayFormat = DateFormat('d MMMM yyyy', 'ru_RU');

  DateTime get date => _format.parse(pubDate!).toLocal();
  String get formattedDate => _displayFormat.format(date);
}

class NewsDetailsScreen extends StatelessWidget {
  const NewsDetailsScreen(this.item, {super.key});

  final RssItem item;
  static Route route(RssItem item) =>
      createRoute((context) => NewsDetailsScreen(item));

  static final _figures = <String, List<String>>{};

  static final _dio = Dio();
  // ..interceptors.add(QueuedInterceptorsWrapper(
  //   onRequest: (options, handler) async {
  //     // await Future.delayed(const Duration(seconds: 1));
  //   },
  // ));

  static Future<List<String>> parseNewspage(RssItem item) async {
    if (item.link == null) return const [];
    final url = item.link!;

    if (_figures.containsKey(url)) return _figures[url]!;

    final data = (await _dio.get(url)).data.toString();

    final htmlDom = parse(data);
    final figures = htmlDom.getElementsByClassName('b-preview-img');

    final host = 'https://${Uri.parse(item.link!).host}';

    _figures[url] = figures
        .map((e) => host + (e.nodes[3].attributes['href'] ?? ''))
        .toList();
    return _figures[url]!;
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Новости',
        body: ReloadableFutureBuilder<List<String>>(
            future: () => parseNewspage(item),
            builder: (data) {
              return SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            height: 400.0, viewportFraction: 0.3),
                        items: data.mapIndexed((idx, url) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(GalleryPage.route(data, idx));
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Image.network(url)),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HtmlWidget(
                          item.description ?? '',
                          textStyle: context.headlineMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 16.0, bottom: 16.0),
                        child: Text(
                          'Источник: ${Uri.parse(item.link!).host}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: 17.0),
                        ),
                      )
                    ]),
              );
            }));
  }
}

class GalleryPage extends StatelessWidget {
  const GalleryPage(this.urls, this.idx, {super.key});

  final List<String> urls;
  final int idx;

  static Route route(List<String> urls, int idx) =>
      createRoute((context) => GalleryPage(urls, idx));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider(
        options: CarouselOptions(
            initialPage: idx,
            height: MediaQuery.of(context).size.height - kToolbarHeight,
            viewportFraction: 1.0),
        items: urls.mapIndexed((idx, url) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.network(url));
            },
          );
        }).toList(),
      ),
    );
  }
}
