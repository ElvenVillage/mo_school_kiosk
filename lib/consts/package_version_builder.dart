import 'dart:async';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:build/build.dart';

bool _wroteBuildTimestamp = false;
String _outputFilePath = 'lib/consts/consts.g.dart';

Builder packageVersionFactory(BuilderOptions options) {
  if (!_wroteBuildTimestamp) {
    // ignore: avoid_print
    print("timestamp builder");
    final buildDateContents =
        'const kBuildDate = \'${DateTime.now().toString().substring(5, 10).replaceAll('-', '.')}\';\r\n';

    final pubspec = File('pubspec.yaml').readAsLinesSync();
    String? versionNumber;

    for (final line in pubspec) {
      if (line.startsWith('version')) {
        versionNumber = line.split(': ')[1];
      }
    }

    versionNumber ??= '1.0.0';

    final versionNumberContents =
        'const kPackageVersion = \'$versionNumber\';\r\n';
    const partOfContents = 'part of \'consts.dart\';\r\n';

    File(_outputFilePath).writeAsStringSync(
        partOfContents + versionNumberContents + buildDateContents,
        flush: true);

    _wroteBuildTimestamp = true;
  }

  return PackageVersionBuilder();
}

class PackageVersionBuilder extends Builder {
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {}

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      '.dart': ['.dart_whatever']
    };
  }
}
