import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'file_manager.dart';
import 'help.dart';
import 'printer.dart';
import 'scene.dart';
import 'settings.dart';
import 'widget.dart';
import 'navigation.dart';

// For Javascript interop.
import 'js_stub.dart' if (dart.library.html) 'js_interface.dart';

class MyApp {
  final Settings settings;
  final FileManager manager;
  late final GoRouter router;

  // Use this constructor when running integration tests.
  MyApp(this.settings, this.manager, String initialLocation) {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(path: "/scene", builder: makeSplash, onExit: onExit),
        GoRoute(path: "/settings", builder: makeSettings),
        GoRoute(path: "/help", builder: makeHelp),
        GoRoute(path: "/about", builder: makeHelp),
      ],
      errorBuilder: errorBuilder, // Default is to make a scene.
    );
  }

  // Use this factory method for normal runtime, not for unit tests.
  factory MyApp.fullApp() {
    var settings = Settings();
    var manager = FileManager(settings);
    //XXX use class.routeName instead?
    return MyApp(settings, manager, "/scene");
  }

  // This kicks off app initialization for both the full app and for tests.
  Future<void> initialize() async {
    settings.addTheme();
    SceneView.initSettings(settings);

    // XXX Pass in a function that tells what to call when window closes.
    initJavascriptInterface();

    // Debug settings.
    settings.initDebug();
    SceneView.initDebugSettings(settings);
    settings.add(AppWidgetState.debug_logs);

    Log.initSettings(settings);

    manager.initialize();
  }

  Widget build() {
    Log.init.log("CYAN: building material app for $this");
    return MaterialApp.router(
      title: "Spacetime Drawing Tool",
      theme: settings.theme.theme_data,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final browserFontSize = getBrowserRootFontSize();
        final scaleFactor = browserFontSize / 16.0;
        final textScaler = scaleFactor != 1.0
            ? TextScaler.linear(scaleFactor)
            : mediaQueryData.textScaler;
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: textScaler),
          child: child!,
        );
      },
    );
  }

  Widget makeSettings(BuildContext context, GoRouterState state) {
    Log.init.log("CYAN: makeSettings.");
    fixAddressBar(context, "/settings");
    return SettingsScreen(settings);
  }

  Widget makeHelp(BuildContext context, GoRouterState state) {
    Log.init.log("CYAN: makeHelp.");
    String initialPage = "about.html";
    if (state.uri.path == "/about") {
      initialPage = "about.html";
      fixAddressBar(context, "/about");
    } else {
      initialPage = state.uri.queryParameters['page'] ?? "overview.html";
      fixAddressBar(context, state.uri.toString());
    }
    return HelpScreen(settings, initialPage: initialPage);
  }

  Widget errorBuilder(BuildContext context, GoRouterState state) {
    Log.init.log("CYAN: errorBuilder. ${state.uri}");
    return makeSplash(context, state);
  }

  int scene_count = 0;
  Widget makeSplash(BuildContext context, GoRouterState state) {
    scene_count++;
    Log.init.log("CYAN: makeSplash. count=$scene_count.");
    Log.init.log("CYAN: in makeSplash, uri=${trunc(state.uri)}, ");
    // So it knows where to put alerts/dialogs.
    manager.setContext("scene $scene_count", context);
    fixAddressBar(context, state.uri.toString());
    manager.checkNavigation(state.uri.queryParameters);
    Log.init.log("After check Navigation.");
    return SplashWidget(settings, manager);
  }

  FutureOr<bool> onExit(BuildContext context, GoRouterState state) async {
    // XXX can put check save here. But it is not always called.
    Log.init.log(
      "CYAN: Exit. unsaved = ${manager.unsaved.value}, url=${state.uri}",
    );
    return await manager.checkSave(context);
  }
}
