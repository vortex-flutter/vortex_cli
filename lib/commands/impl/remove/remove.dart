import '../../../exception/cli_exception.dart';
import '../../../utils/logger.dart';
import '../../../utils/pubspec_utils.dart';
import '../../../utils/shell_utils.dart';
import '../../interface/command.dart';

class RemoveCommand extends Command {
  @override
  String get commandName => 'remove';
  @override
  Future<void> execute() async {
    for (var package in args) {
      PubspecUtils.removeDependencies(package);
    }

    //if (GetCli.arguments.first == 'remove') {
    await ShellUtils.pubGet();
    //}
  }

  @override
  String? get hint => 'Use to remove a package in your project (dependencies):';

  @override
  bool validate() {
    super.validate();
    if (args.isEmpty) {
      CliException('Enter the name of the package you wanna remove',
          codeSample: codeSample);
    }
    return true;
  }

  @override
  String? get codeSample => LogService.code('vortex remove http');

  @override
  int get maxParameters => 999;
  @override
  List<String> get alias => ['-rm'];
}