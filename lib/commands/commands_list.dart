import 'package:vortex_cli/commands/impl/create/project/project.dart';
import 'package:vortex_cli/commands/impl/runner/runner.dart';
import 'package:vortex_cli/commands/impl/runner/runner_component.dart';
import 'package:vortex_cli/commands/impl/runner/runner_composable.dart';
import 'package:vortex_cli/commands/impl/runner/runner_plugin.dart';

import 'impl/create/page/page.dart';
import 'impl/index.dart';
import 'interface/command.dart';

final List<Command> commands = [
  CommandParent(
    'create',
    [CreatePageCommand(), CreateProjectCommand()],
    ['-c'],
  ),
  HelpCommand(),
  VersionCommand(),
  InstallCommand(),
  RemoveCommand(),
  UpdateCommand(),
  CommandParent(
    'runner',
    [RunnerCommand(), RunnerComponent(), ComposableCommand(), PluginCommand()],
    ['-r'],
  ),
];

class CommandParent extends Command {
  final String _name;
  final List<String> _alias;
  final List<Command> _childrens;
  CommandParent(this._name, this._childrens, [this._alias = const []]);

  @override
  String get commandName => _name;
  @override
  List<Command> get childrens => _childrens;
  @override
  List<String> get alias => _alias;

  @override
  Future<void> execute() async {}

  @override
  String get hint => '';

  @override
  bool validate() => true;

  @override
  String get codeSample => '';

  @override
  int get maxParameters => 0;
}
