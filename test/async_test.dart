import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/printer.dart';

import 'mock_delay.dart';

class Ticker {
  Future<void> future;
  int counter = 0;

  Ticker(this.future);

  Future<void> run() async {
    counter++;
    await future;
    counter++;
  }
}

class Sleeper {
  int counter = 0;
  Future<void> run(String name) async {
    await dsleep(name, 10);
    counter++;
  }
}

void main() {
  group('play with futures', () {
    test('stream test', () async {
      var timer = MockDelay();
      var ticker = Ticker(timer.sleep());
      expect(ticker.counter, 0);
      ticker.run();
      expect(ticker.counter, 1);
      await timer.finish();
      expect(ticker.counter, 2);
    });
    test('controller test', () async {
      var controller = MockSleep();
      DebugSleep.instance = controller;
      var sleeper = Sleeper();
      expect(sleeper.counter, 0);
      expect(controller.delays.length, 0);
      sleeper.run("one");
      sleeper.run("two");
      expect(sleeper.counter, 0);
      expect(controller.delays.length, 2);
      expect(controller.delays["one"]!.finished, false);
      expect(controller.delays["two"]!.finished, false);
      await controller.finish("two");
      expect(sleeper.counter, 1);
      expect(controller.delays.length, 2);
      expect(controller.delays["one"]!.finished, false);
      expect(controller.delays["two"]!.finished, true);
      await controller.finish("one");
      expect(sleeper.counter, 2);
      expect(controller.delays.length, 2);
      expect(controller.delays["one"]!.finished, true);
      expect(controller.delays["two"]!.finished, true);
    });
  });
}
