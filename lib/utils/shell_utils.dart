import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:vortex_cli/core/generator.dart';

import 'logger.dart';
import 'pub_dev_api.dart';
import 'pubspec_lock.dart';

class ShellUtils {
  static Future<void> pubGet() async {
    LogService.info('Running `flutter pub get` …');
    await run('dart pub get', verbose: true);
  }

  static Future<void> addPackage(String package) async {
    LogService.info('Adding package $package …');
    await run('dart pub add $package', verbose: true);
  }

  static Future<void> removePackage(String package) async {
    LogService.info('Removing package $package …');
    await run('dart pub remove $package', verbose: true);
  }

  static Future<void> flutterCreate(
    String path,
    String? org,
    String iosLang,
    String androidLang,
  ) async {
    LogService.info('Running `flutter create $path` …');

    await run(
        'flutter create --no-pub -i $iosLang -a $androidLang --org $org'
        ' "$path"',
        verbose: true);
  }

  static Future<void> update(
      [bool isGit = false, bool forceUpdate = false]) async {
    isGit = VortexCli.arguments.contains('--git');
    forceUpdate = VortexCli.arguments.contains('-f');
    if (!isGit && !forceUpdate) {
      var versionInPubDev =
          await PubDevApi.getLatestVersionFromPackage('get_cli');

      var versionInstalled = await PubspecLock.getVersionCli(disableLog: true);

      if (versionInstalled == versionInPubDev) {
        return LogService.info("Latest version of vortex_cli already installed");
      }
    }

    LogService.info('Upgrading get_cli …');

    try {
      if (Platform.script.path.contains('flutter')) {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/jonataslaw/get_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate vortex_cli', verbose: true);
        }
      } else {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/vortex_flutter/vortex_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate get_cli', verbose: true);
        }
      }
      return LogService.success("Upgrade complete");
    } on Exception catch (err) {
      LogService.info(err.toString());
      return LogService.error("There was an error upgrading vortex_cli");
    }
  }
}