import 'package:vortex_cli/core/generator.dart';

import '../../exception/cli_exception.dart';
import '../../utils/logger.dart';
import '../impl/args_mixin.dart';

abstract class Command with ArgsMixin {
  Command() {
    while (
        ((args.contains(commandName) || args.contains('$commandName:$name'))) &&
            args.isNotEmpty) {
      args.removeAt(0);
    }
    if (args.isNotEmpty && args.first == name) {
      args.removeAt(0);
    }
  }
  int get maxParameters;

  //int get minParameters;

  String? get codeSample;
  String get commandName;

  List<String> get alias => [];

  List<String> get acceptedFlags => [];

  /// hint for command line
  String? get hint;

  /// validate command line arguments
  bool validate() {
    if (VortexCli.arguments.contains(commandName) ||
        VortexCli.arguments.contains('$commandName:$name')) {
      var flagsNotAceppts = flags;
      flagsNotAceppts.removeWhere((element) => acceptedFlags.contains(element));
      if (flagsNotAceppts.isNotEmpty) {
        LogService.info('The ${flagsNotAceppts.toString()} is not necessary');
      }

      if (args.length > maxParameters) {
        List pars = args.skip(maxParameters).toList();
        throw CliException(
            'the ${pars.toString()} parameters are not necessary',
            codeSample: codeSample);
      }
    }
    return true;
  }

  /// execute command
  Future<void> execute();

  /// childrens command
  List<Command> get childrens => [];
}