import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'logger.dart';

class PubDevApi {
  static Future<String?> getLatestVersionFromPackage(String package) async {
    final languageCode = Platform.localeName.split('_')[0];
    final pubSite = languageCode == 'zh'
        ? 'https://pub.flutter-io.cn/api/packages/$package'
        : 'https://pub.dev/api/packages/$package';
    var uri = Uri.parse(pubSite);
    try {
      var value = await get(uri);
      if (value.statusCode == 200) {
        final version = json.decode(value.body)['latest']['version'] as String?;
        return version;
      } else if (value.statusCode == 404) {
        LogService.info(
          'Package: $package not found in pub.dev',
          false,
          false,
        );
      }
      return null;
    } on Exception catch (err) {
      LogService.error(err.toString());
      return null;
    }
  }
}