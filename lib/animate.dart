// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Code reused from polytope project.

import 'package:flutter/material.dart';

import "printer.dart";
import 'scene.dart';

/// Manages animation timing loops for iterating time steps in the scene viewer.
class MyAnimator {
  /// Duration in seconds before restarting the animation loop.
  static final int clockTime = 10;

  /// The animation controller powering time ticks.
  final AnimationController controller;
  double _previousClock = 0.0;

  /// Reference to the active scene viewer.
  final SceneView sceneViewer;

  /// Counter tracking ticks processed.
  int ticks = 0;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "Animator-$_debugId";

  /// Constructs [MyAnimator] attached to [tick_provider] and [sceneViewer].
  MyAnimator(SingleTickerProviderStateMixin tick_provider, this.sceneViewer)
    : controller = AnimationController(
        vsync: tick_provider,
        duration: Duration(seconds: clockTime),
        upperBound: clockTime.toDouble(),
      ) {
    controller.view.addListener(hearTick);
    controller.addStatusListener((status) {
      // Log.animate.log("Animation status: $status, value = ${zzz(controller.value)}");
      if (status == AnimationStatus.completed) {
        // Warn the scene_viewer that the animation is going to reset.
        onComplete();
      }
    });
    // Log.animate.log("ORANGE: Created $this for $tick_provider and $scene_viewer");
  }

  /// Returns debug representation of current animation status.
  String debugPrint() {
    return (" a${zzz(controller.value)}($ticks)");
  }

  /// Callback executed on animation ticks.
  void hearTick() {
    ticks++;
    double dt = controller.value - _previousClock;
    bool changed = sceneViewer.updateTime(dt);
    _previousClock = controller.value;
    if (!changed) {
      Log.animate.log("Animator: no change. pausing.");
      pause();
    }
  }

  /// Reset loop when animation completes full duration cycle.
  void onComplete() {
    // Log.animate.log("$this onComplete. previous = ${zzz(previous_clock)}");
    _previousClock = 0;
    controller.reset();
    controller.forward();
  }

  /// Disposes controller listeners and resources.
  void dispose() {
    controller.dispose();
  }

  /// Pauses active animation.
  void pause() => controller.stop();

  /// Starts or resumes animation playback.
  void play() {
    Log.animate.log("GREEN: Animator is starting.");
    controller.forward(from: controller.value);
  }

  /// Whether the animation is currently active.
  bool get isAnimating => controller.isAnimating;
}
