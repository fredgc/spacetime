import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'js_stub.dart' if (dart.library.html) 'js_interface.dart';

/// Detects whether the current device is likely to have a physical keyboard.
///
/// On web touch devices and mobile platforms, keyboard shortcut indications
/// are hidden until a physical key event is detected.
class KeyboardDetector {
  static final ValueNotifier<bool> hasKeyboard = ValueNotifier<bool>(
    _initialValue(),
  );
  static bool _initialized = false;

  static bool _initialValue() {
    if (kIsWeb) {
      return detectWebHasKeyboard();
    }
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {
      return true;
    }
    return false;
  }

  /// Initializes listening to hardware key events.
  static void init() {
    if (_initialized) return;
    _initialized = true;
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  static bool _handleKeyEvent(KeyEvent event) {
    onKeyEvent(event);
    return false;
  }

  /// Called when a hardware key event occurs to ensure [hasKeyboard] is true.
  static void onKeyEvent(KeyEvent event) {
    if (!hasKeyboard.value) {
      hasKeyboard.value = true;
    }
  }

  /// Reset the keyboard state, optionally overriding it (useful for tests).
  @visibleForTesting
  static void reset({bool? overrideValue}) {
    hasKeyboard.value = overrideValue ?? _initialValue();
  }
}
