import 'dart:async';

import 'package:spacetime/printer.dart';

// This mock creates a future that will delay until the finish method is
// called.
class MockDelay {
  bool finished = false;
  var controller = StreamController<bool>();
  MockDelay();

  Future<void> finish() async {
    finished = true;
    controller.add(true);
    await controller.close();
  }

  Future<void> sleep() async {
    await controller.stream.toList();
    return;
  }
}

class MockSleep extends DebugSleep {
  Map<String, MockDelay> delays = {};

  @override
  Future<void> sleep(String text, Duration duration) async {
    // print("ZZZ sleep $text");
    if (delays.containsKey(text) && !(delays[text]!.finished)) {
      print("RED: Sleeping twice with same name '$text'? Is that OK?");
      return delays[text]!.sleep();
    }
    // print("Creating sleep for $text");
    MockDelay delay = MockDelay();
    delays[text] = delay;
    return delay.sleep();
  }

  Future<void> finish(String s) {
    if (delays.containsKey(s)) {
      // print("ZZZ Finish $s");
      return delays[s]!.finish();
    } else {
      print("RED: Could not find delay $s");
      listSleeps();
      return Future<void>.value();
    }
  }

  Future<void> finishAll() async {
    for (var s in delays.keys) {
      if (!delays[s]!.finished) await delays[s]!.finish();
    }
  }

  void listSleeps() {
    delays.forEach((tag, delay) {
      print("delay $tag, ${delay.finished ? 'finished' : 'active'}");
    });
  }
}
