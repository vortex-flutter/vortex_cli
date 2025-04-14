import 'dart:io';

import 'package:vortex_cli/commands/impl/install/install_flutterwind.dart';
import 'package:vortex_cli/commands/impl/install/install_vortex.dart';

import '../../../../core/structure.dart';
import '../../../../samples/vortex_main.dart';
import '../../../../utils/create_list_directory.dart';
import '../../../../utils/create_main.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/pubspec_utils.dart';
import '../../create/page/page.dart';

Future<void> createInitVortexPattern() async {
  var canContinue = await createMain();
  if (!canContinue) return;

  var isServerProject = PubspecUtils.isServerProject;
  if (!isServerProject) {
    await installVortex();
    await installFlutterWind();
  }

  var initialDirs = [Directory(Structure.replaceAsExpected(path: 'lib/data/'))];
  VortexMainSample(isServer: isServerProject).create();
  await Future.wait([CreatePageCommand().execute()]);
  createListDirectory(initialDirs);

  LogService.success('Vortex Pattern created successfully');
}
