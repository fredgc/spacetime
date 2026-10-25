import 'dart:math' as math;

class NameGuess {
  int _counter = 1;
  String _prefix = "X";
  String _name = "-nope-";
  static final RegExp re = RegExp(r'([^\d]*)(\d*)');

  int get counter => _counter;
  String get prefix => _prefix;
  String get name => _name;

  set counter(int x) {
    _counter = x;
    _name = "$_prefix$_counter";
  }

  set prefix(String x) {
    _prefix = x;
    _name = "$_prefix$_counter";
  }

  set name(String x) {
    _name = x;
    RegExpMatch? match = re.firstMatch(x);
    if (match == null) return;
    _prefix = match.group(1)!;
    String c = match.group(2)!;
    if (c.isEmpty) {
      _counter = 0;
    } else {
      _counter = int.parse(c);
    }
  }

  void increment() {
    counter = counter + 1;
  }

  void riseAbove(String x) {
    RegExpMatch? match = re.firstMatch(x);
    if (match == null) return;
    String c = match.group(2)!;
    if (c.isNotEmpty) {
      int counter = int.parse(c);
      //  Log.text_edit.log("Comparing counter for $x -> $counter with $_counter");
      _counter = math.max(_counter, counter + 1);
      _name = "$_prefix$_counter";
    }
  }

  static final RegExp _trailingDigits = RegExp(r'^(.*?)(\d+)$');

  /// If [desiredName] conflicts with any name in [existingNames], increments
  /// the trailing number (or appends ` 2` / `2` if none) until unique.
  static String nextAvailableName(
    String desiredName,
    Iterable<String> existingNames,
  ) {
    final existingSet = existingNames.map((s) => s.trim()).toSet();
    final trimmed = desiredName.trim();
    if (!existingSet.contains(trimmed)) {
      return desiredName;
    }

    final match = _trailingDigits.firstMatch(trimmed);
    String base;
    int counter;
    if (match != null) {
      base = match.group(1)!;
      counter = int.parse(match.group(2)!) + 1;
    } else {
      base = "$trimmed ";
      counter = 2;
    }

    for (final existing in existingSet) {
      final m = _trailingDigits.firstMatch(existing);
      if (m != null) {
        final existingBase = m.group(1)!;
        if (existingBase == base ||
            existingBase.trimRight() == base.trimRight()) {
          final existingCounter = int.parse(m.group(2)!);
          if (existingCounter >= counter) {
            counter = existingCounter + 1;
          }
        }
      }
    }

    while (existingSet.contains("$base$counter")) {
      counter++;
    }
    return "$base$counter";
  }

  /// Increments the counter in a filename before its extension (e.g.,
  /// `spacetime_drawing.st.json` -> `spacetime_drawing_2.st.json` or
  /// `drawing1.json` -> `drawing2.json`) if it conflicts with [existingFilenames].
  static String nextAvailableFilename(
    String desiredFilename,
    Iterable<String> existingFilenames,
  ) {
    final existingSet = existingFilenames.map((s) => s.trim()).toSet();
    final trimmed = desiredFilename.trim();
    if (!existingSet.contains(trimmed)) {
      return desiredFilename;
    }

    String stem = trimmed;
    String ext = "";
    if (trimmed.endsWith(".st.json")) {
      stem = trimmed.substring(0, trimmed.length - ".st.json".length);
      ext = ".st.json";
    } else {
      final dotIndex = trimmed.lastIndexOf('.');
      if (dotIndex > 0) {
        stem = trimmed.substring(0, dotIndex);
        ext = trimmed.substring(dotIndex);
      }
    }

    final match = _trailingDigits.firstMatch(stem);
    String base;
    int counter;
    if (match != null) {
      base = match.group(1)!;
      counter = int.parse(match.group(2)!) + 1;
    } else {
      base = "${stem}_";
      counter = 2;
    }

    while (existingSet.contains("$base$counter$ext")) {
      counter++;
    }
    return "$base$counter$ext";
  }
}
