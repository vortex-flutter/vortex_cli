import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:vortex_cli/core/generator.dart';

import '../../../../exception/cli_exception.dart';
import '../../../../utils/logger.dart';
import '../../../interface/command.dart';

class CreatePageCommand extends Command {
  @override
  String get commandName => 'page';

  @override
  List<String> get alias => ['module', '-p', '-m'];

  @override
  Future<void> execute() async {
    var isProject = false;
    if (VortexCli.arguments[0] == 'create' || VortexCli.arguments[0] == '-c') {
      isProject = VortexCli.arguments[1].split(':').first == 'project';
    }
    var pageName = this.name;
    if (pageName.isEmpty || isProject) {
      pageName = 'index';
    }

    final pageType = flags.contains('--stateful') ? 'stateful' : 'stateless';
    final pageDir =
        flags.contains('--dir') ? _getArgValue('--dir') : 'lib/pages';
    final routePath =
        flags.contains('--route')
            ? _getArgValue('--route')
            : '/${pageName.toLowerCase()}';
    final customFileName =
        flags.contains('--file') ? _getArgValue('--file') : null;

    LogService.info("Generating $pageType page: $pageName");
    LogService.info("Route path: $routePath");

    try {
      // Create the directory if it doesn't exist
      final projectDir = Directory.current.path;
      final fullPageDir = path.join(projectDir, pageDir);

      if (!Directory(fullPageDir).existsSync()) {
        Directory(fullPageDir).createSync(recursive: true);
        LogService.info("Created directory: $pageDir");
      }

      // Determine the file path
      final fileName =
          customFileName != null
              ? customFileName.endsWith('.dart')
                  ? customFileName
                  : '$customFileName.dart'
              : '${_getFileNameFromPageName(pageName)}.dart';
      final filePath = path.join(fullPageDir, fileName);

      // Check if the file already exists
      if (File(filePath).existsSync()) {
        throw CliException("File already exists: $filePath");
      }

      // Generate the page content
      final pageContent = _generatePageContent(pageName, pageType, routePath);

      // Write the file
      File(filePath).writeAsStringSync(pageContent);

      LogService.success("Generated page at: $filePath");
      LogService.info("Running router scanner to update routes...");
    } catch (e) {
      LogService.error("Error generating page: $e");
    }
  }

  @override
  String? get hint => "Use to generate pages";

  @override
  bool validate() {
    return true;
  }

  String _getArgValue(String flag) {
    final index = flags.indexOf(flag);
    if (index != -1 && index < flags.length - 1) {
      return flags[index + 1];
    }
    return '';
  }

  /// Generate the content for a new page
  String _generatePageContent(
    String pageName,
    String pageType,
    String routePath,
  ) {
    final className = _getClassNameFromPageName(pageName);

    if (pageType == 'stateless') {
      return '''
import 'package:flutter/material.dart';
import 'package:vortex/vortex.dart';

/// $className page
@VortexPage('$routePath')
class $className extends StatelessWidget {
  const $className({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import 'package:vortex/vortex.dart';

/// $className page
@VortexPage('$routePath')
class $className extends StatefulWidget {
  const $className({Key? key}) : super(key: key);

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';
    }
  }

  String _getFileNameFromPageName(String pageName) {
    // Convert PascalCase or camelCase to snake_case
    final fileName =
        pageName
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) => '_${match.group(0)!.toLowerCase()}',
            )
            .toLowerCase();

    // Remove leading underscore if present
    return fileName.startsWith('_') ? fileName.substring(1) : fileName;
  }

  String _getClassNameFromPageName(String pageName) {
    // Ensure the class name starts with an uppercase letter
    if (pageName.isEmpty) return 'Page';

    if(pageName == 'index') return 'HomePage';

    // If it's already PascalCase, return as is
    if (pageName[0] == pageName[0].toUpperCase()) {
      return pageName;
    }

    // Convert first letter to uppercase
    return pageName[0].toUpperCase() + pageName.substring(1);
  }

  @override
  String? get codeSample => 'vortex create page:product';

  @override
  int get maxParameters => 0;
}
