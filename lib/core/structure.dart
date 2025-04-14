import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:vortex_cli/utils/logger.dart';
import '../exception/cli_exception.dart';
import '../models/file_model.dart';

class Structure {
  static final Map<String, String> _paths = {
    'page':
        Directory(
              replaceAsExpected(path: '${Directory.current.path}/lib/pages/'),
            ).existsSync()
            ? replaceAsExpected(path: 'lib/pages')
            : replaceAsExpected(path: 'lib/pages'),
    'component': replaceAsExpected(path: 'lib/components/'),
    'store': replaceAsExpected(path: 'lib/store/'),
    'composable': replaceAsExpected(path: 'lib/composables/'),
    'plugin': replaceAsExpected(path: 'lib/plugins/'),
    'middleware': replaceAsExpected(path: 'lib/middlewares/'),
  };

  static FileModel model(
    String? name,
    String command,
    bool wrapperFolder, {
    String? on,
    String? folderName,
  }) {
    LogService.debug('Paths: $_paths');
    LogService.debug('name: $name');
    LogService.debug('command: $command');
    LogService.debug('wrapperFolder: $wrapperFolder');
    LogService.debug('on: $on');
    LogService.debug('folderName: $folderName');

    if (on != null && on != '') {
      on = replaceAsExpected(path: on).replaceAll('\\\\', '\\');
      var current = Directory('lib');
      final list = current.listSync(recursive: true, followLinks: false);
      final contains = list.firstWhere(
        (element) {
          if (element is File) {
            return false;
          }

          return '${element.path}${p.separator}'.contains('$on${p.separator}');
        },
        orElse: () {
          return list.firstWhere(
            (element) {
              //Fix erro ao encontrar arquivo com nome
              if (element is File) {
                return false;
              }
              return element.path.contains(on!);
            },
            orElse: () {
              throw CliException('Folder $on not found');
            },
          );
        },
      );

      return FileModel(
        name: name,
        path: Structure.getPathWithName(
          contains.path,
          ReCase(name!).snakeCase,
          createWithWrappedFolder: wrapperFolder,
          folderName: folderName,
        ),
        commandName: command,
      );
    }
    return FileModel(
      name: name,
      path: Structure.getPathWithName(
        _paths[command],
        ReCase(name!).snakeCase,
        createWithWrappedFolder: wrapperFolder,
        folderName: folderName,
      ),
      commandName: command,
    );
  }

  static String replaceAsExpected({required String path}) {
    if (path.contains('\\')) {
      if (Platform.isLinux || Platform.isMacOS) {
        return path.replaceAll('\\', '/');
      } else {
        return path;
      }
    } else if (path.contains('/')) {
      if (Platform.isWindows) {
        return path.replaceAll('/', '\\\\');
      } else {
        return path;
      }
    } else {
      return path;
    }
  }

  static String? getPathWithName(
    String? firstPath,
    String secondPath, {
    bool createWithWrappedFolder = false,
    required String? folderName,
  }) {
    late String betweenPaths;
    LogService.debug('Platform: $firstPath');
    LogService.debug('Platform: $secondPath');
    LogService.debug('Platform: $folderName');

    if (Platform.isWindows) {
      betweenPaths = '\\\\';
    } else if (Platform.isMacOS || Platform.isLinux) {
      betweenPaths = '/';
    }
    if (betweenPaths.isNotEmpty) {
      if (createWithWrappedFolder) {
        return firstPath! +
            betweenPaths +
            folderName! +
            betweenPaths +
            secondPath;
      } else {
        return firstPath! + betweenPaths + secondPath;
      }
    }
    return null;
  }

  static List<String> safeSplitPath(String path) {
    return path.replaceAll('\\', '/').split('/')
      ..removeWhere((element) => element.isEmpty);
  }

  static String pathToDirImport(String path) {
    var pathSplit = safeSplitPath(path)
      ..removeWhere((element) => element == '.' || element == 'lib');
    return pathSplit.join('/');
  }
}
