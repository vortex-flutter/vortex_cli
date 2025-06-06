import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:vortex_cli/utils/logger.dart';
import '../../interface/command.dart';

class PluginCommand extends Command {
  @override
  String get commandName => 'plugin';

  @override
  List<String> get alias => ['plugin', '-p'];

  @override
  Future<void> execute() async {
    final pluginsDir =
        flags.contains('plugins-dir')
            ? _getArgValue('plugins-dir')
            : 'lib/plugins';
    final verbose =
        flags.contains('verbose') || flags.contains('-v') ? true : false;

    LogService.info("Running Vortex plugin scanner...");
    final projectDir = Directory.current.path;
    LogService.info("Project directory: $projectDir");
    final fullPluginsDir = path.join(projectDir, pluginsDir);
    LogService.info("Plugins directory: $fullPluginsDir");

    // Check if the plugins directory exists
    if (!Directory(fullPluginsDir).existsSync()) {
      LogService.error("Plugins directory not found: $fullPluginsDir");
      return;
    }

    try {
      // Scan for plugin files
      final pluginFiles = _findPluginFiles(fullPluginsDir);
      LogService.info("Found ${pluginFiles.length} plugin files");

      if (verbose) {
        for (final file in pluginFiles) {
          LogService.info(
            "Plugin file: ${path.relative(file.path, from: projectDir)}",
          );
        }
      }

      // Generate the plugin registration code
      _generatePluginRegistration(projectDir, pluginFiles);

      LogService.info("Vortex plugin scanner completed successfully");
    } catch (e, stackTrace) {
      LogService.error(
        "Error running plugin scanner, error: $e, stackTrace: $stackTrace",
      );
    }
  }

  @override
  String? get codeSample => '';

  @override
  String? get hint => 'vortex plugin';

  @override
  int get maxParameters => 0;

  String _getArgValue(String flag) {
    final index = flags.indexOf(flag);
    if (index != -1 && index < flags.length - 1) {
      return flags[index + 1];
    }
    return '';
  }

  List<File> _findPluginFiles(String directory) {
    return Directory(directory)
        .listSync(recursive: true)
        .where(
          (entity) =>
              entity is File &&
              entity.path.endsWith('.dart') &&
              _containsPluginAnnotation(entity),
        )
        .cast<File>()
        .toList();
  }

  bool _containsPluginAnnotation(File file) {
    try {
      final content = file.readAsStringSync();
      return content.contains('@VortexPlugin');
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

  void _generatePluginRegistration(String projectDir, List<File> pluginFiles) {
    try {
      final outputDir = path.join(projectDir, 'lib', 'generated');
      final outputFile = File(path.join(outputDir, 'plugins.vortex.g.dart'));

      // Create the output directory if it doesn't exist
      if (!Directory(outputDir).existsSync()) {
        Directory(outputDir).createSync(recursive: true);
      }

      // Generate the plugin registration code
      final buffer = StringBuffer();
      buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
      buffer.writeln('// ignore_for_file: unnecessary_cast');
      buffer.writeln('');
      buffer.writeln('import \'package:vortex/vortex.dart\';');
      buffer.writeln('');

      // Track imported files to avoid duplicates
      final importedFiles = <String>{};

      // Import all plugin files
      for (final file in pluginFiles) {
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
      buffer.writeln('extension PluginAccessor on VortexPlugins {');

      // Add plugin accessors
      for (final file in pluginFiles) {
        final content = file.readAsStringSync();
        final annotationMatch = RegExp(
          r'''@VortexPlugin\(\s*(['"])(.*?)\1\s*\)''',
        ).firstMatch(content);

        if (annotationMatch != null) {
          final pluginName = annotationMatch.group(2)!;
          final classMatch = RegExp(
            r'class\s+(\w+)\s+extends\s+Plugin',
          ).firstMatch(content);

          if (classMatch != null) {
            final className = classMatch.group(1)!;
            buffer.writeln(
              '  $className get $pluginName => VortexPlugins.use<$className>();',
            );
          }
        }
      }

      buffer.writeln('}');

      // Write the generated code to the output file
      outputFile.writeAsStringSync(buffer.toString());

      LogService.info("Generated plugin registration code: ${outputFile.path}");
      LogService.info("Add the following to your main.dart file:");
      LogService.info(
        "import 'package:${_getPackageName(projectDir)}/generated/plugins.vortex.g.dart';",
      );
    } catch (e, stackTrace) {
      LogService.error(
        "Error generating plugin registration code, error: $e, stackTrace: $stackTrace",
      );
    }
  }
}
