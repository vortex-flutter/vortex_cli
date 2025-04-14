import '../../../utils/pubspec_utils.dart';

Future<void> installVortex([bool runPubGet = false]) async {
  PubspecUtils.removeDependencies('vortex', logger: false);
  await PubspecUtils.addDependencies('vortex', runPubGet: runPubGet);
}