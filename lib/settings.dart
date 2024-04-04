import 'dart:io';

import 'package:flutter/foundation.dart';

class AppSettings {
  static String? consolidatedLogin;
  static String? consolidatedPassword;
  static String? baseLogin;
  static String? basePassword;

  static Future<Directory?> getAppDirectory() async {
    if (kIsWeb) return null;

    String home;
    if (Platform.isWindows) {
      home = Platform.environment['USERPROFILE']!;
    } else {
      home = Platform.environment['HOME']!;
    }

    final dir = Directory('$home/.kiosk_dovuz/');
    await dir.create(recursive: true);
    return dir;
  }

  static Map<String, String> toJson() => {
        'consolidatedLogin': consolidatedLogin ?? 'nnz',
        'consolidatedPassword': consolidatedPassword ?? 'Sonyk12345678',
        'baseLogin': baseLogin ?? 'nnz',
        'basePassword': basePassword ?? 'Sochi-2020'
      };

  static Future<void> load() async {
    final directory = await getAppDirectory();
    if (directory == null) {
      final val = toJson();
      consolidatedLogin = val['consolidatedLogin'];
      consolidatedPassword = val['consolidatedPassword'];
      baseLogin = val['baseLogin'];
      basePassword = val['basePassword'];
      return;
    }
    final settingsFile = File('${directory.path}/settings.ini');

    final wasInitialized = await settingsFile.exists();

    if (wasInitialized) {
      await _loadFromFile(settingsFile);
    } else {
      await _saveToFile(settingsFile);
    }
  }

  static Future<void> _loadFromFile(File settingsFile) async {
    final lines = await settingsFile.readAsLines();
    final settings = <String, String>{};

    for (final line in lines) {
      final pair = line.split('=');
      settings[pair.first] = pair.last;
    }

    consolidatedLogin = settings['consolidatedLogin'];
    consolidatedPassword = settings['consolidatedPassword'];
    baseLogin = settings['baseLogin'];
    basePassword = settings['basePassword'];
  }

  static Future<void> _saveToFile(File settingsFile) async {
    await settingsFile.create(recursive: true);

    await settingsFile.writeAsString(
        toJson().entries.map((e) => '${e.key}=${e.value}').join('\n'));
    await _loadFromFile(settingsFile);
  }
}
