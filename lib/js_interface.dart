// ignore_for_file: depend_on_referenced_packages
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import "printer.dart";

import 'file_manager.dart';

@JS()
external void setCallbackFunction(JSFunction f);

@JS('setUnsavedCallback')
external void setUnsavedCallback(JSFunction f);

@JS('removeSplashFromWeb')
external void removeSplashFromWeb();

void _doFileSave() {
  Log.navigation.log(
    "_do_FileSave: Javascript says window unloading XXXXXXXXXXXXXXXXXXXXXX",
  );
}

void initJavascriptInterface() {
  Log.navigation.log("Running initJavascriptInterface");
  setCallbackFunction((_doFileSave).toJS);
}

void initUnsavedCallback(FileManager fileManager) {
  Log.navigation.log("Setting JS unsaved callback");
  setUnsavedCallback((() => fileManager.unsaved.value).toJS);
}

double getBrowserRootFontSize() {
  try {
    final rootElement = web.document.documentElement;
    if (rootElement != null) {
      final fontSizeStr = web.window.getComputedStyle(rootElement).fontSize;
      // Parse e.g. "16px" or "20px" or "16"
      final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(fontSizeStr);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    }
  } catch (e) {
    Log.errors.log("Error reading browser root font size: $e");
  }
  return 16.0;
}

bool detectWebHasKeyboard() {
  try {
    final hasFinePointer = web.window.matchMedia('(pointer: fine)').matches;
    final hasCoarsePointer = web.window.matchMedia('(pointer: coarse)').matches;
    final maxTouch = web.window.navigator.maxTouchPoints;
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    final isMobileUserAgent =
        userAgent.contains('android') ||
        userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod') ||
        (userAgent.contains('macintosh') && maxTouch > 1);

    if (isMobileUserAgent && !hasFinePointer) {
      return false;
    }
    if (hasCoarsePointer && !hasFinePointer && maxTouch > 0) {
      return false;
    }
    return true;
  } catch (e) {
    Log.errors.log("Error detecting web keyboard: $e");
    return true;
  }
}

Future<void> reloadAndFlushCache() async {
  try {
    Log.settings.log(
      "PURPLE: Flushing service workers, caches, and reloading page.",
    );
    final nav = web.window.navigator;
    final serviceWorker = nav.serviceWorker;
    final registrations = await serviceWorker.getRegistrations().toDart;
    final regList = registrations.toDart;
    for (final reg in regList) {
      (reg).unregister();
    }
    final cacheStorage = web.window.caches;
    final keys = await cacheStorage.keys().toDart;
    final keyList = keys.toDart;
    for (final key in keyList) {
      cacheStorage.delete((key).toDart);
    }
  } catch (e) {
    Log.errors.log("Error clearing web cache: $e");
  }
  web.window.location.reload();
}
