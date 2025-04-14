import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:vortex_cli/exception/cli_exception.dart';

import '../../../../core/structure.dart';
import '../../../../samples/analysis_option.dart';
import '../../../../utils/menu.dart';
import '../../../../utils/pubspec_utils.dart';
import '../../../../utils/shell_utils.dart';
import '../../../interface/command.dart';
import '../../init/flutter/init.dart';

class CreateProjectCommand extends Command {
  @override
  String get commandName => 'project';

  @override
  List<String> get alias => ['-p'];

  @override
  Future<void> execute() async {
    final menu = Menu([
      'Flutter Project',
      'Vortex Server',
    ], title: 'Select which type of project you want to create ?');
    final result = menu.choose();
    String? nameProject = name;
    if (name == '.') {
      nameProject = ask("what is the name of the project?");
    }

    var path = Structure.replaceAsExpected(
      path: Directory.current.path + p.separator + nameProject.snakeCase,
    );
    await Directory(path).create(recursive: true);

    Directory.current = path;

    if (result.index == 0) {
      var org = ask(
        "What is your company's domain? \x1B[33m"
        "Example: com.yourcompany \x1B[0m",
      );

      final iosLangMenu =
          Menu(['Swift', 'Objective-C'], title: "what language do you want to use on ios?");
      final iosResult = iosLangMenu.choose();

      var iosLang = iosResult.index == 0 ? 'swift' : 'objc';

      final androidLangMenu =
          Menu(['Kotlin', 'Java'], title: "what language do you want to use on android?");
      final androidResult = androidLangMenu.choose();

      var androidLang = androidResult.index == 0 ? 'kotlin' : 'java';

      final linterMenu = Menu([
        'Yes',
        'No',
      ], title: "do you want to use some linter?");
      final linterResult = linterMenu.choose();

      await ShellUtils.flutterCreate(path, org, iosLang, androidLang);
      File('test/widget_test.dart').writeAsStringSync('');

      switch (linterResult.index) {
        case 0:
          if (PubspecUtils.isServerProject) {
            await PubspecUtils.addDependencies('lints',
                isDev: true, runPubGet: true);
            AnalysisOptionsSample(
                    include: 'include: package:lints/recommended.yaml')
                .create();
          } else {
            await PubspecUtils.addDependencies('flutter_lints',
                isDev: true, runPubGet: true);
            AnalysisOptionsSample(
                    include: 'include: package:flutter_lints/flutter.yaml')
                .create();
          }
          break;

        default:
          AnalysisOptionsSample().create();
      }
      await InitCommand().execute();
    }else {
      CliException('Not implemented yet');
    }
  }

  @override
  String? get hint => "Use to generate new project";

  @override
  bool validate() {
    return true;
  }

  @override
  String get codeSample => 'get create project';

  @override
  int get maxParameters => 0;
}
