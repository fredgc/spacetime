import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spacetime/animate.dart';
import 'package:spacetime/file_manager.dart';
import 'package:spacetime/scene.dart';
import 'package:spacetime/settings.dart';

class _TestTickerWidget extends StatefulWidget {
  final Function(SingleTickerProviderStateMixin, BuildContext) onReady;
  const _TestTickerWidget({required this.onReady});

  @override
  State<_TestTickerWidget> createState() => _TestTickerWidgetState();
}

class _TestTickerWidgetState extends State<_TestTickerWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onReady(this, context);
  }

  @override
  Widget build(BuildContext context) => const Placeholder();
}

void main() {
  testWidgets('MyAnimator lifecycle, tick handling, and controls', (
    tester,
  ) async {
    final settings = Settings();
    final fileManager = FileManager(settings);
    final scene = SceneView(fileManager, settings, SceneData());
    late MyAnimator animator;

    await tester.pumpWidget(
      _TestTickerWidget(
        onReady: (tickerProvider, context) {
          animator = MyAnimator(tickerProvider, scene);
        },
      ),
    );

    expect(animator.isAnimating, false);
    expect(animator.ticks, 0);
    expect(animator.toString(), contains('Animator-'));
    expect(animator.debugPrint(), contains('a'));

    // Start playback
    animator.play();
    expect(animator.isAnimating, true);

    // Pump frames to let ticks fire
    await tester.pump(const Duration(milliseconds: 100));
    expect(animator.ticks > 0, true);

    // Pause playback
    animator.pause();
    expect(animator.isAnimating, false);

    // Call onComplete
    animator.onComplete();
    expect(animator.isAnimating, true);

    animator.dispose();
  });
}
