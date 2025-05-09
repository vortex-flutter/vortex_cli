import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vortex_cli/utils/logger.dart';
import '../../interface/command.dart';

class ComposableCommand extends Command {
  @override
  String get commandName => 'composable';

  @override
  List<String> get alias => ['composable', '-c'];

  @override
  Future<void> execute() async {
    final composablesDir =
        flags.contains('composables-dir')
            ? _getArgValue('composables-dir')
            : 'lib/composables';
    final verbose =
        flags.contains('verbose') || flags.contains('-v') ? true : false;

    LogService.info("Running Vortex composable scanner...");
    final projectDir = Directory.current.path;
    LogService.info("Project directory: $projectDir");
    final fullComposablesDir = path.join(projectDir, composablesDir);
    LogService.info("Composables directory: $fullComposablesDir");

    // Check if the composables directory exists
    if (!Directory(fullComposablesDir).existsSync()) {
      LogService.error("Composables directory not found: $fullComposablesDir");
      return;
    }

    try {
      // Scan for composable files
      final composableFiles = _findComposableFiles(fullComposablesDir);
      LogService.info("Found ${composableFiles.length} composable files");

      if (verbose) {
        for (final file in composableFiles) {
          LogService.info(
            "Composable file: ${path.relative(file.path, from: projectDir)}",
          );
        }
      }

      // Generate the composable registration code
      _generateComposableRegistration(projectDir, composableFiles);

      LogService.info("Vortex composable scanner completed successfully");
    } catch (e, stackTrace) {
      LogService.error(
        "Error running composable scanner, error: $e, stackTrace: $stackTrace",
      );
    }
  }

  @override
  String? get codeSample => '';

  @override
  String? get hint => 'vortex composable';

  @override
  int get maxParameters => 0;

  String _getArgValue(String flag) {
    final index = flags.indexOf(flag);
    if (index != -1 && index < flags.length - 1) {
      return flags[index + 1];
    }
    return '';
  }

  List<File> _findComposableFiles(String directory) {
    return Directory(directory)
        .listSync(recursive: true)
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith('.dart') &&
              _containsComposableAnnotation(entity),
        )
        .cast<File>()
        .toList();
  }

  bool _containsComposableAnnotation(File file) {
    try {
      final content = file.readAsStringSync();
      return content.contains('@VortexComposable');
    } catch (e) {
      LogService.error("Error reading file: ${file.path}, error: $e");
      return false;
    }
  }

  String _getPackageName(String projectDir) {
    try {
      final pubspecFile = File(path.join(projectDir, 'pubspec.yaml'));

      if (pubspecFile.existsSync()) {
        final content = pubspecFile.readAsStringSync();
        final nameMatch = RegExp(r'name:\s*([^\s]+)').firstMatch(content);
        if (nameMatch != null) {
          return nameMatch.group(1)!;
        }
      }
    } catch (e) {
      LogService.error("Error getting package name, error: $e");
    }

    return 'app';
  }

  void _generateComposableRegistration(
    String projectDir,
    List<File> composableFiles,
  ) {
    try {
      final outputDir = path.join(projectDir, 'lib', 'generated');
      final outputFile = File(
        path.join(outputDir, 'composables.vortex.g.dart'),
      );

      // Create the output directory if it doesn't exist
      if (!Directory(outputDir).existsSync()) {
        Directory(outputDir).createSync(recursive: true);
      }

      // Generate the composable registration code
      final buffer = StringBuffer();
      buffer.writeln('// Generated code - do not modify by hand');
      buffer.writeln('');
      buffer.writeln('import \'package:flutter/material.dart\';');
      buffer.writeln('import \'package:vortex/vortex.dart\';');
      buffer.writeln('');

      // Track imported files to avoid duplicates
      final importedFiles = <String>{};

      // Import all composable files
      for (final file in composableFiles) {
        final relativePath = path.relative(file.path, from: projectDir);
        final importPath = relativePath
            .replaceAll('\\', '/')
            .replaceFirst(RegExp(r'^lib/'), '');

        final importStatement =
            'import \'package:${_getPackageName(projectDir)}/$importPath\';';

        // Only add the import if we haven't seen it before
        if (importedFiles.add(importPath)) {
          buffer.writeln(importStatement);
        }
      }

      buffer.writeln('');
      buffer.writeln(
        'extension GeneratedComposableAccessor on VortexComposables {',
      );

      // Add composable accessors
      for (final file in composableFiles) {
        final content = file.readAsStringSync();
        final annotationMatch = RegExp(
          r'''@VortexComposable\(\s*(['"])(.*?)\1\s*\)''',
        ).firstMatch(content);

        if (annotationMatch != null) {
          final composableName = annotationMatch.group(2)!;
          final functionMatch = RegExp(
            r'(\w+)\s+Function\s*\([^)]*\)\s+get\s+(\w+)',
          ).firstMatch(content);

          if (functionMatch != null) {
            final returnType = functionMatch.group(1)!;
            final functionName = functionMatch.group(2)!;

            buffer.writeln(
              '  $returnType Function(${_getFunctionParameters(content)}) get $functionName =>',
            );
            buffer.writeln(
              '    VortexComposables.use<$returnType Function(${_getFunctionParameters(content)})>();',
            );
          }
        }
      }

      buffer.writeln('}');

      // Write the generated code to the output file
      outputFile.writeAsStringSync(buffer.toString());

      LogService.info(
        "Generated composable registration code: ${outputFile.path}",
      );
      LogService.info("Add the following to your main.dart file:");
      LogService.info(
        "import 'package:${_getPackageName(projectDir)}/generated/composables.vortex.g.dart';",
      );
    } catch (e, stackTrace) {
      LogService.error(
        "Error generating composable registration code, error: $e, stackTrace: $stackTrace",
      );
    }
  }

  String _getFunctionParameters(String content) {
    final paramsMatch = RegExp(r'Function\s*\(([^)]*)\)').firstMatch(content);

    if (paramsMatch != null) {
      return paramsMatch.group(1)!.trim();
    }

    return 'BuildContext context';
  }
}
