import 'package:flutter/material.dart';

import "my_app.dart";
import "printer.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make a complete full app, instead of a unit test app.
  Log.fullApp();
  final app = MyApp.fullApp();
  await app.initialize();
  Log.init.log("CYAN: running the app.");
  runApp(app.build());
  Log.init.log("CYAN: Done with main.");
}
