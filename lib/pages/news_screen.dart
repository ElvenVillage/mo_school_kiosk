import 'package:dart_rss/dart_rss.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:mo_school_kiosk/style.dart';
import 'package:mo_school_kiosk/utils.dart';
import 'package:mo_school_kiosk/widgets/page_template.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

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

  static Route route() => createRoute((_) => const NewsScreen());

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  Future<List<RssItem>>? _future;

  Future<List<RssItem>> _fetchNews() async {
    final dio = Dio(BaseOptions(responseType: ResponseType.plain));
    final result = <RssItem>[];

    for (final school in NewsScreen.rssUrls.values) {
      try {
        result.addAll(RssFeed.parse((await dio.get(school)).data).items);
      } catch (_) {}
    }
    return result..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'НОВОСТИ',
        body: FutureBuilder(
          future: _future ??= _fetchNews(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return GridView.count(
                crossAxisCount: 3,
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(NewsDetailsScreen.route(item));
      },
      child: Container(
        decoration: BoxDecoration(
            image: item.enclosure?.type != null
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
                              style: context.body,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item.formattedDate),
                          ),
                        )
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}

extension ParseDate on RssItem {
  static final _format = DateFormat('E, d MMM yyyy HH:mm:ss zzz', 'en_US');
  static final _displayFormat = DateFormat('d MMMM yyyy, hh:mm', 'ru_RU');

  DateTime get date => _format.parse(pubDate!);
  String get formattedDate => _displayFormat.format(date);
}

class NewsDetailsScreen extends StatelessWidget {
  const NewsDetailsScreen(this.item, {super.key});

  final RssItem item;
  static Route route(RssItem item) =>
      createRoute((context) => NewsDetailsScreen(item));

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Новости',
        body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.enclosure?.url != null) Image.network(item.enclosure!.url!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: HtmlWidget(
                item.description ?? '',
                textStyle: context.body,
              ),
            ),
          ),
        ]));
  }
}
