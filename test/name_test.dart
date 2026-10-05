import 'package:test/test.dart';

import 'package:spacetime/name.dart';

void main() {
  group('names', () {
    test('set', () {
      NameGuess guess = NameGuess();
      guess.prefix = "Z";
      expect(guess.name, "Z1");
    });
    test('increment', () {
      NameGuess guess = NameGuess();
      guess.prefix = "Z";
      guess.increment();
      expect(guess.name, "Z2");
    });
    test('counter', () {
      NameGuess guess = NameGuess();
      guess.prefix = "Z";
      guess.counter = 4;
      expect(guess.name, "Z4");
      guess.counter = 42;
      expect(guess.name, "Z42");
    });
    test('prefix', () {
      NameGuess guess = NameGuess();
      guess.prefix = "Dog";
      expect(guess.name, "Dog1");
      guess.prefix = "Cat";
      expect(guess.name, "Cat1");
    });
    test('guess', () {
      NameGuess guess = NameGuess();
      guess.name = "Cat32";
      expect(guess.prefix, "Cat");
      expect(guess.counter, 32);
      expect(guess.name, "Cat32");
      guess.increment();
      expect(guess.name, "Cat33");
      guess.name = "Dog";
      expect(guess.prefix, "Dog");
      expect(guess.counter, 0);
      expect(guess.name, "Dog");
      guess.increment();
      expect(guess.name, "Dog1");
      guess.name = "Dog12Cat13";
      expect(guess.prefix, "Dog");
      expect(guess.counter, 12);
      expect(guess.name, "Dog12Cat13");
      guess.increment();
      expect(guess.name, "Dog13");
    });
  });
}
