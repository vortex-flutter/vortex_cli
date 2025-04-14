import 'dart:io';

import '../core/structure.dart';
import 'logger.dart';
import 'menu.dart';

Future<bool> createMain() async {
  var newFileModel = Structure.model('', 'init', false);
  var main = File('${newFileModel.path}main.dart');

  if (main.existsSync()) {
    /// apenas quem chama essa função é o create project e o init,
    /// ambas funções iniciam um projeto e sobrescreve os arquivos

    final menu = Menu(['Yes!', 'No'],
        title: "Your lib folder is not empty. Are you sure you want to overwrite your application? \\n WARNING: This action is irreversible");
    final result = menu.choose();
    if (result.index == 1) {
      LogService.info("No files were overwritten");
      return false;
    }
    await Directory('lib/').delete(recursive: true);
  }
  return true;
}