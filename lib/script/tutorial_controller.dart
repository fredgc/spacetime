import 'package:flutter/foundation.dart';

import '../drawable.dart';
import '../scene.dart';
import '../transform.dart';
import 'tutorial_parser.dart';
import 'tutorial_step.dart';

/// Coordinates tutorial state, checks criteria, and triggers step updates.
class TutorialController extends ChangeNotifier {
  final SceneView scene;
  final Tutorial tutorial;
  int currentStepIndex = 0;
  bool isCompleted = false;

  TutorialController(this.scene, this.tutorial) {
    scene.velocity.addListener(_checkCondition);
    scene.time.addListener(_checkCondition);
    scene.lightSpeed.addListener(_checkCondition);
    scene.currentTool.addListener(_checkCondition);
    scene.currentType.addListener(_checkCondition);
    scene.currentName.addListener(_checkCondition);
    scene.currentColor.addListener(_checkCondition);
    scene.repaintCounter.addListener(_checkCondition);
    scene.undoManager.addListener(_checkCondition);
    _applyStepStart();
  }

  TutorialStep? get currentStep => (currentStepIndex < tutorial.steps.length)
      ? tutorial.steps[currentStepIndex]
      : null;

  String? get currentHighlightId => currentStep?.highlightIdFor(scene);

  /// If the current step has an unsatisfied [ModeDirective], returns its target mode.
  LightSpeed? get targetLightSpeed {
    final step = currentStep;
    if (step == null) return null;
    for (final d in step.directives) {
      if (d is ModeDirective && !d.isSatisfied(scene)) {
        return d.targetMode;
      }
    }
    return null;
  }

  /// If the current step highlights a specific object on the canvas, returns it.
  Drawable? get highlightedDrawable {
    final step = currentStep;
    if (step == null || currentHighlightId != 'canvas.object') return null;
    for (final d in step.directives) {
      if (d is SelectObjectDirective && !d.isSatisfied(scene)) {
        return d.findTargetDrawable(scene);
      }
      if (d is MoveObjectDirective && !d.isSatisfied(scene)) {
        return d.findTargetDrawable(scene);
      }
    }
    return null;
  }

  /// If the current step highlights a recommended point on the canvas to add an
  /// object, returns that point in observer coordinates.
  Point? get highlightedPoint {
    final step = currentStep;
    if (step == null || currentHighlightId != 'canvas.point') return null;
    for (final d in step.directives) {
      if (d is AddObjectDirective && !d.isSatisfied(scene)) {
        return d.recommendedPoint;
      }
    }
    return null;
  }

  /// If the current step has an unsatisfied [AddObjectDirective], returns it.
  AddObjectDirective? get activeAddObjectDirective {
    final step = currentStep;
    if (step == null) return null;
    for (final d in step.directives) {
      if (d is AddObjectDirective && !d.isSatisfied(scene)) {
        return d;
      }
    }
    return null;
  }

  bool get isCurrentStepSatisfied =>
      currentStep != null && currentStep!.isSatisfied(scene);

  /// Whether the user is allowed to proceed to the next step.
  bool get isContinueEnabled {
    if (isCompleted || currentStep == null) return false;
    final isAcknowledge = currentStep!.directives.any(
      (d) => d is AcknowledgeDirective,
    );
    if (isAcknowledge) return true;
    return isCurrentStepSatisfied;
  }

  /// Whether the "Do it for me" button should be available.
  bool get canDoItForMe =>
      tutorial.allowDoItForMe &&
      !isContinueEnabled &&
      (currentStep?.canDoItForMe ?? false);

  /// Automatically fulfills the current step criteria.
  void doItForMe() {
    if (currentStep == null) return;
    currentStep!.doItForMe(scene);
    _checkCondition();
  }

  double get progress => tutorial.steps.isEmpty
      ? 1.0
      : (currentStepIndex + 1) / tutorial.steps.length;

  void _applyStepStart() {
    currentStep?.onStepStart(scene);
    _updateSliderSnapTargets();
    _checkCondition();
  }

  void _updateSliderSnapTargets() {
    final step = currentStep;
    if (step == null || isCompleted) {
      scene.time.clearSnapTarget();
      scene.velocity.clearSnapTarget();
      return;
    }
    TimeDirective? timeDir;
    VelocityDirective? velDir;
    for (final d in step.directives) {
      if (d is TimeDirective) {
        timeDir = d;
      } else if (d is VelocityDirective) {
        velDir = d;
      }
    }
    if (timeDir != null) {
      scene.time.setSnapTarget(
        timeDir.targetTime,
        timeDir.effectiveTolerance(scene),
      );
    } else {
      scene.time.clearSnapTarget();
    }
    if (velDir != null) {
      scene.velocity.setSnapTarget(
        velDir.targetVelocity,
        velDir.effectiveTolerance(scene),
      );
    } else {
      scene.velocity.clearSnapTarget();
    }
  }

  void _checkCondition() {
    if (isCompleted || currentStep == null) return;
    notifyListeners();
  }

  void nextStep() {
    if (!isContinueEnabled && !isCompleted) return;
    if (currentStepIndex < tutorial.steps.length - 1) {
      currentStepIndex++;
      _applyStepStart();
      notifyListeners();
    } else {
      isCompleted = true;
      scene.time.clearSnapTarget();
      scene.velocity.clearSnapTarget();
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStepIndex > 0) {
      currentStepIndex--;
      isCompleted = false;
      _applyStepStart();
      notifyListeners();
    }
  }

  void resetCurrentStep() {
    _applyStepStart();
    notifyListeners();
  }

  @override
  void dispose() {
    scene.time.clearSnapTarget();
    scene.velocity.clearSnapTarget();
    scene.velocity.removeListener(_checkCondition);
    scene.time.removeListener(_checkCondition);
    scene.lightSpeed.removeListener(_checkCondition);
    scene.currentTool.removeListener(_checkCondition);
    scene.currentType.removeListener(_checkCondition);
    scene.currentName.removeListener(_checkCondition);
    scene.currentColor.removeListener(_checkCondition);
    scene.repaintCounter.removeListener(_checkCondition);
    scene.undoManager.removeListener(_checkCondition);
    super.dispose();
  }
}
