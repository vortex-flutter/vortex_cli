import '../../../exception/cli_exception.dart';
import '../../../utils/logger.dart';
import '../../../utils/pubspec_utils.dart';
import '../../../utils/shell_utils.dart';
import '../../interface/command.dart';

class InstallCommand extends Command {
  @override
  String get commandName => 'install';
  @override
  List<String> get alias => ['-i'];
  @override
  Future<void> execute() async {
    var isDev = containsArg('--dev') || containsArg('-dev');
    var runPubGet = false;

    for (var element in args) {
      var packageInfo = element.split(':');
      LogService.info('Installing package "${packageInfo.first}" …');
      if (packageInfo.length == 1) {
        runPubGet = await PubspecUtils.addDependencies(packageInfo.first,
                isDev: isDev, runPubGet: false)
            ? true
            : runPubGet;
      } else {
        runPubGet = await PubspecUtils.addDependencies(packageInfo.first,
                version: packageInfo[1], isDev: isDev, runPubGet: false)
            ? true
            : runPubGet;
      }
    }

    if (runPubGet) await ShellUtils.pubGet();
  }

  @override
  String? get hint => 'Use to install a package in your project (dependencies):';

  @override
  bool validate() {
    super.validate();

    if (args.isEmpty) {
      throw CliException(
          'Please, enter the name of a package you wanna install',
          codeSample: codeSample);
    }
    return true;
  }

  final String? codeSample1 = LogService.code('vortex install vortex:0.0.2');
  final String? codeSample2 = LogService.code('vortex install vortex');

  @override
  String get codeSample => '''
  $codeSample1
  if you wanna install the latest version:
  $codeSample2
''';

  @override
  int get maxParameters => 999;
}