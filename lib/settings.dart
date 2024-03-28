import 'dart:convert';
import 'dart:io';

class AppSettings {
  static String? consolidatedLogin;
  static String? consolidatedPassword;
  static String? baseLogin;
  static String? basePassword;

  static Map<String, String> toJson() => {
        'consolidatedLogin': consolidatedLogin ?? 'nnz',
        'consolidatedPassword': consolidatedPassword ?? 'Sonyk12345678',
        'baseLogin': baseLogin ?? 'nnz',
        'basePassword': basePassword ?? 'Sochi-2020'
      };

  static Future<void> load() async {
    String home;
    if (Platform.isWindows) {
      home = Platform.environment['USERPROFILE']!;
    } else {
      home = Platform.environment['HOME']!;
    }

    final settingsFile = File('$home/.kiosk-dovuz');
    final wasInitialized = await settingsFile.exists();

    if (wasInitialized) {
      await _loadFromFile(settingsFile);
    } else {
      await _saveToFile(settingsFile);
    }
  }

  static Future<void> _loadFromFile(File settingsFile) async {
    final data = await settingsFile.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(data);
    consolidatedLogin = jsonData['consolidatedLogin'];
    consolidatedPassword = jsonData['consolidatedPassword'];
    baseLogin = jsonData['baseLogin'];
    basePassword = jsonData['basePassword'];
  }

  static Future<void> _saveToFile(File settingsFile) async {
    await settingsFile.create();
    await settingsFile.writeAsString(jsonEncode(toJson()));
    await _loadFromFile(settingsFile);
  }
}
