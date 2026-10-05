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
}
