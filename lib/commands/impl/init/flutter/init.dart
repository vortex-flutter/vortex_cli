import 'package:vortex_cli/exception/cli_exception.dart';

import '../../../../utils/logger.dart';
import '../../../../utils/menu.dart';
import '../../../../utils/pubspec_utils.dart';
import '../../../../utils/shell_utils.dart';
import '../../../interface/command.dart';
import 'init_vortex.dart';

class InitCommand extends Command {
  @override
  String get commandName => 'init';

  @override
  Future<void> execute() async {
    final menu = Menu([
      'Vortex Pattern (by CodeSyncr)',
    ], title: 'Which architecture do you want to use?');
    final result = menu.choose();

    result.index == 0
        ? await createInitVortexPattern()
        : CliException('Invalid architecture');
    if (!PubspecUtils.isServerProject) {
      await ShellUtils.pubGet();
    }
    return;
  }

  @override
  String? get hint => "generate the chosen structure on an existing project:";

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String? get codeSample => LogService.code('vortex init');

  @override
  int get maxParameters => 0;
}