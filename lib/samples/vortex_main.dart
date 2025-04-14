import 'interface/sample_interface.dart';

class VortexMainSample extends Sample {
  final bool? isServer;
  VortexMainSample({this.isServer}) : super('lib/main.dart', overwrite: true);

  String get _flutterMain => '''import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vortex/vortex.dart';
import 'package:flutterwind_core/flutterwind.dart';

void main() async {
  await VortexRouter.discoverRoutes(
    projectDirectory: Directory(
      Directory.current.path,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with CompositionMixin {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final isDarkMode = useRef<bool>('isDarkMode', false);

    // Set up watchers
    watch(isDarkMode, () => isDarkMode.value, (newValue, oldValue) {
      Log.i(
        'Theme changed',
      );
    });

    // Set up lifecycle hooks
    onMounted(() {
      Log.i('App mounted');
    });

    return Vortex(
      child: FlutterWind(
        child: MaterialApp(
          title: 'Vortex Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          onGenerateInitialRoutes:
              (initialRoute) => [
                VortexRouter.initialRouteHandler(
                  RouteSettings(name: initialRoute),
                ),
              ],
          onGenerateRoute: VortexRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
  ''';

  String get _serverMain => '''import 'package:vortex_server/vortex_server.dart';


void main() {
  runApp(VortexServer(
    router: VortexRouter.routes,
  ));
}
  ''';

  @override
  String get content => isServer! ? _serverMain : _flutterMain;
}