import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:vortex_cli/utils/logger.dart';

import '../../../interface/command.dart';

class CreateMiddlewareCommand extends Command {
  @override
  String get commandName => 'middleware';

  @override
  Future<void> execute() async {
    var middlewareName = this.name;
    final middlewareDir =
        flags.contains('--dir') ? _getArgValue('--dir') : 'lib/middleware';
    final verbose = flags.contains('--verbose') ? true : false;
    final customFileName =
        flags.contains('--file') ? _getArgValue('--file') : null;

    if (verbose) {
      LogService.info('Creating middleware $middlewareName in $middlewareDir');
    }

    final projectDir = Directory.current.path;
    final fullMiddlewareDir = path.join(projectDir, middlewareDir);

    try {
      if (!Directory(fullMiddlewareDir).existsSync()) {
        Directory(fullMiddlewareDir).createSync(recursive: true);
        if (verbose) {
          LogService.info("Created directory: $middlewareDir");
        }
      }

      // Determine the file path
      // Determine the file path
      final fileName =
          customFileName != null
              ? customFileName.endsWith('.dart')
                  ? customFileName
                  : '$customFileName.dart'
              : '${_getFileNameFromMiddlewareName(middlewareName)}_middleware.dart';
      final filePath = path.join(fullMiddlewareDir, fileName);

      // Check if the file already exists
      if (File(filePath).existsSync()) {
        LogService.error("File already exists: $filePath");
        return;
      }

      // Generate the middleware content
      final middlewareContent = _generateMiddlewareContent(middlewareName);

      // Write the file
      File(filePath).writeAsStringSync(middlewareContent);

      LogService.success("Generated middleware at: $filePath");
    } catch (e, stackTrace) {
      LogService.error(
        "Error creating middleware",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  String? get hint => 'Create a new middleware';

  @override
  int get maxParameters => 0;

  @override
  String? get codeSample => 'vortex create middleware:<middleware_name>';

  String _getArgValue(String flag) {
    final index = flags.indexOf(flag);
    if (index != -1 && index < flags.length - 1) {
      return flags[index + 1];
    }
    return '';
  }

  String _getFileNameFromMiddlewareName(String middlewareName) {
    // Convert PascalCase or camelCase to snake_case
    final fileName =
        middlewareName
            .replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) => '_${match.group(0)!.toLowerCase()}',
            )
            .toLowerCase();

    // Remove leading underscore if present
    return fileName.startsWith('_') ? fileName.substring(1) : fileName;
  }

  String _generateMiddlewareContent(String middlewareName) {
    final className = _getClassNameFromMiddlewareName(middlewareName);

    return '''
import 'package:flutter/material.dart';
import 'package:vortex/vortex.dart';

@Middleware(name: '${middlewareName.toLowerCase()}')
class ${className}Middleware implements VortexMiddleware {
  @override
  Future<bool> execute(BuildContext context, String route) async {
    Log.w('context \$context');
    // Add your middleware logic here
    return true;
  }
}
''';
  }

  String _getClassNameFromMiddlewareName(String middlewareName) {
    // Ensure the class name starts with an uppercase letter
    if (middlewareName.isEmpty) return 'Default';

    // If it's already PascalCase, return as is
    if (middlewareName[0] == middlewareName[0].toUpperCase()) {
      return middlewareName;
    }

    // Convert first letter to uppercase
    return middlewareName[0].toUpperCase() + middlewareName.substring(1);
  }
}
