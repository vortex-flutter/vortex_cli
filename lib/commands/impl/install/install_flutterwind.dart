import '../../../utils/pubspec_utils.dart';

Future<void> installFlutterWind([bool runPubGet = false]) async {
  PubspecUtils.removeDependencies('flutterwind_core', logger: false);
  await PubspecUtils.addDependencies('flutterwind_core', runPubGet: runPubGet);
}