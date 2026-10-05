import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/script.dart';

void main() {
  group('scripts.', () {
    test('simple test', () {
      String input = "this is a test.";
      MyScript s = MyScript(input);
      expect(input, s.script);
    });
  });
}
