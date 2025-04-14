import 'dart:io';
import 'package:version/version.dart';

import '../config/cli_config.dart';
import '../utils/logger.dart';
import '../utils/pub_dev_api.dart';
import '../utils/pubspec_lock.dart';
import 'check_dev_version.dart';
import 'print_vortex_cli.dart';

void checkForUpdate() async {
  if (!CliConfig.updateIsCheckingToday()) {
    if (!isDevVersion()) {
      await PubDevApi.getLatestVersionFromPackage('get_cli').then((
        versionInPubDev,
      ) async {
        await PubspecLock.getVersionCli(disableLog: true).then((
          versionInstalled,
        ) async {
          if (versionInstalled == null) exit(2);

          final v1 = Version.parse(versionInPubDev!);
          final v2 = Version.parse(versionInstalled);
          final needsUpdate = v1.compareTo(v2);
          // needs update.
          if (needsUpdate == 1) {
            LogService.info(
              "There's an update available! Current installed version: $versionInstalled"
            );
            //await versionCommand();
            printGetCli();
            final String codeSample = LogService.code('get update');
            LogService.info(
              "New version available: $versionInPubDev Please, run: ${' $codeSample'}",
              false,
              true,
            );
          }
        });
      });
      CliConfig.setUpdateCheckToday();
    }
  }
}
