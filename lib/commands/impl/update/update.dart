import '../../../utils/shell_utils.dart';
import '../../interface/command.dart';

class UpdateCommand extends Command {
  @override
  String get commandName => 'update';
  @override
  List<String> get acceptedFlags => ['-f', '--git'];

  @override
  Future<void> execute() async {
    await ShellUtils.update();
  }

  @override
  String? get hint => 'To update VORTEX_CLI';

  @override
  List<String> get alias => ['upgrade'];

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String get codeSample => 'vortex update';

  @override
  int get maxParameters => 0;
}