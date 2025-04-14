import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:vortex_cli/utils/logger.dart';

import '../../../interface/command.dart';

class CreateComponentCommand extends Command {
  @override
  String get commandName => 'component';

  @override
  Future<void> execute() async {
    var componentName = this.name;
    final componentsDir =
        flags.contains('--dir') ? _getArgValue('--dir') : 'lib/components';
    final verbose = flags.contains('--verbose') ? true : false;
    final customFileName =
        flags.contains('--file') ? _getArgValue('--file') : null;
    final routePath =
        flags.contains('--route')
            ? _getArgValue('--route')
            : '/${componentName.toLowerCase()}';
    if (verbose) {
      LogService.info('Creating component $componentName in $componentsDir');
    }

    final projectDir = Directory.current.path;
    final fullComponentsDir = path.join(projectDir, componentsDir);

    try {
      if (!Directory(fullComponentsDir).existsSync()) {
        Directory(fullComponentsDir).createSync(recursive: true);
        if (verbose) {
          LogService.info("Created directory: $componentsDir");
        }
      }

      // Determine the file path
      final fileName =
          customFileName != null
              ? customFileName.endsWith('.dart')
                  ? customFileName
                  : '$customFileName.dart'
              : '${_getFileNameFromComponentName(componentName)}.dart';
      final filePath = path.join(fullComponentsDir, fileName);

      // Check if the file already exists
      if (File(filePath).existsSync()) {
        LogService.error("File already exists: $filePath");
        return;
      }

      // Generate the page content
      final pageContent = _generateComponentContent(componentName, routePath);

      // Write the file
      File(filePath).writeAsStringSync(pageContent);

      LogService.success("Generated page at: $filePath");
      LogService.info("Running router scanner to update routes...");
    } catch (e, stackTrace) {
      LogService.error(
        "Error running component scanner",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  String? get hint => 'Create a new component';

  @override
  int get maxParameters => 0;

  @override
  String? get codeSample => 'vortex create component:<component_name>';

  String _getArgValue(String flag) {
    final index = flags.indexOf(flag);
    if (index != -1 && index < flags.length - 1) {
      return flags[index + 1];
    }
    return '';
  }

  String _getFileNameFromComponentName(String componentName) {
    // Convert PascalCase or camelCase to snake_case
    final fileName =
        componentName
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) => '_${match.group(0)!.toLowerCase()}',
            )
            .toLowerCase();

    // Remove leading underscore if present
    return fileName.startsWith('_') ? fileName.substring(1) : fileName;
  }

  String _generateComponentContent(String componentName, String routePath) {
    final className = _getClassNameFromComponentName(componentName);

    return '''
import 'package:flutter/material.dart';
import 'package:vortex/vortex.dart';

/// $className component
@Component()
class $className extends StatelessWidget {
  const $className({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
  }

  String _getClassNameFromComponentName(String pageName) {
    // Ensure the class name starts with an uppercase letter
    if (pageName.isEmpty) return 'Page';

    if (pageName == 'index') return 'HomePage';

    // If it's already PascalCase, return as is
    if (pageName[0] == pageName[0].toUpperCase()) {
      return pageName;
    }

    // Convert first letter to uppercase
    return pageName[0].toUpperCase() + pageName.substring(1);
  }
}
