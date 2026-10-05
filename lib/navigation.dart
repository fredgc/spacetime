import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To use SystemNavigator
import 'package:go_router/go_router.dart';

import 'printer.dart';

void popOrHome(BuildContext context) {
  if (context.canPop()) {
    // Log.navigation.log("PURPLE: pop");
    context.pop();
  } else {
    // Log.navigation.log("PURPLE: cannot pop. going home.");
    context.go("/scene");
  }
  // Log.navigation.log("PURPLE: Finished app pop.");
}

bool isTopWidget(BuildContext context) {
  return (ModalRoute.of(context)?.isCurrent ?? false);
}

void fixAddressBar(BuildContext context, String path) {
  // Log.navigation.log("PURPLE: fixAddressBar ${trunc(path)}.");
  // dumpNavigator(context, "fix address bar");
  if (ModalRoute.of(context)?.isCurrent ?? false) {
    // Log.navigation.log("PURPLE: fixAddressBar wait and then ${trunc(path)}.");
    Future.delayed(Duration(milliseconds: 100), () {
      // Log.navigation.log("PURPLE: change the url in the address bar to ${trunc(path)}.");
      // dumpNavigator(context, "before fix address ${trunc(path)}");
      SystemNavigator.routeInformationUpdated(uri: Uri.parse(path));
    });
    // return true;
  } else {
    // Log.navigation.log("XXX -- $path is not top.");
    // return false;
  }
}

// Just for debugging.
void dumpNavigator(BuildContext context, String source) {
  try {
    final navigator = Navigator.of(context);
    Log.dump.log(
      "MAGENTA: in $source. Navigator = $navigator, "
      "${navigator.widget.pages.length} pages",
    );
    for (Page p in navigator.widget.pages) {
      Log.dump.log(
        "   Page. name=${p.name}, arguments = ${trunc(p.arguments)}, "
        "canPop=${p.canPop}",
      );
    }
    if (ModalRoute.of(context) == null) {
      Log.dump.log("no modal route.");
    } else {
      final settings = ModalRoute.of(context)!.settings;
      final arguments = settings.arguments;
      Log.dump.log("route settings = ${trunc(settings)}");
      Log.dump.log(
        "route arguments = ${trunc(arguments)}, isCurrent = ${ModalRoute.of(context)?.isCurrent}",
      );
    }
  } catch (ex) {
    Log.errors.log("$source dump error: $ex");
  }
}
