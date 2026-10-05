import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spacetime/slider.dart';

class SliderHolder extends StatelessWidget {
  final MySlider slider;
  final String title;

  AnimationController controller;
  int ticks = 0;
  double previous_clock = 0.0;
  AnimationStatus status = AnimationStatus.dismissed;

  SliderHolder({
    super.key,
    required this.title,
    required this.slider,
    required WidgetTester ticker,
  }) : controller = AnimationController(
         duration: const Duration(seconds: 10),
         upperBound: 10,
         vsync: ticker,
       ) {
    controller.view.addListener(hearTick);
    controller.addStatusListener((status) {
      this.status = status;
      // print("Animation status: $status, value = ${zzz(controller.value)}");
      // if (status == AnimationStatus.completed) {
      //   // Warn the scene_viewer that the animation is going to reset.
      //   onComplete();
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slider Demo',
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: slider.build(context)),
      ),
    );
  }

  void start() {
    previous_clock = 0.0;
    controller.reset();
    controller.forward();
  }

  void hearTick() {
    ticks++;
    double dt = controller.value - previous_clock;
    bool changed = slider.updateTime(dt);
    previous_clock = controller.value;
    //     print("Tick $ticks: $dt, time=${zzz(controller.value)}, slider=${zzz(slider.value)}");
  }
}

void main() {
  testWidgets('Slider builds', (tester) async {
    final String title = 'This is the title';
    final String name = 'velocity';
    var slider = MySlider(name, 0.0, 1.0, 0.0);
    // print("PURPLE: a value = ${slider.value}, speed=${slider.speed}");
    SliderHolder holder = SliderHolder(
      title: title,
      slider: slider,
      ticker: tester,
    );
    await tester.pumpWidget(holder);
    await tester.pumpAndSettle();

    final titleFinder = find.text(title);
    final labelFinder = find.textContaining(name);

    expect(titleFinder, findsOneWidget);
    expect(labelFinder, findsOneWidget);
    // print("PURPLE: b value = ${slider.value}, speed=${slider.speed}");

    holder.start();
    expect(holder.status, AnimationStatus.forward);
    // No. This forwards through the whole thing.
    // await tester.pumpAndSettle();

    // Animation controller does not seem to be more accurate than about this:
    final double epsilon = 0.01;
    // print("PURPLE: c value = ${slider.value}, speed=${slider.speed}");
    slider.setSpeed(0.1);
    // print("PURPLE: d value = ${slider.value}, speed=${slider.speed}");

    expect(slider.value, closeTo(0.0, epsilon));
    await tester.pumpFrames(holder, Duration(seconds: 5));
    // print("PURPLE: e value = ${slider.value}, speed=${slider.speed}");
    expect(slider.value, closeTo(0.5, epsilon));
    expect(holder.status, AnimationStatus.forward);
    await tester.pumpFrames(holder, Duration(seconds: 5));
    // print("PURPLE: f value = ${slider.value}, speed=${slider.speed}");
    expect(slider.value, closeTo(1.0, epsilon));
    await tester.pumpFrames(holder, Duration(seconds: 5));
    // print("PURPLE: g value = ${slider.value}, speed=${slider.speed}");
    expect(slider.value, closeTo(1.0, epsilon));
    expect(holder.status, AnimationStatus.completed);
  });

  // XXX test sticky values.
  // XXX test user ui. -- this is done in edit test. but not with animation.
  // XXX mix my animation with slider.
  // XXX test forward and restart.
}
