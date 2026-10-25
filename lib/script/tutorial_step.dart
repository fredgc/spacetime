import '../drawable.dart';
import '../scene.dart';
import '../transform.dart';
import 'tutorial_parser.dart';

/// Base class for all step directives.
abstract class TutorialDirective {
  String get highlightId;
  String highlightIdFor(SceneView scene) => highlightId;
  bool get isSetupAction => false;
  bool get canDoItForMe => false;
  bool isSatisfied(SceneView scene);
  String statusText(SceneView scene);
  void onStepStart(SceneView scene) {}
  void applyDoItForMe(SceneView scene) {}
}

/// Combined velocity directive: highlights velocity slider and checks target.
class VelocityDirective extends TutorialDirective {
  final double targetVelocity;
  final double? explicitTolerance;

  VelocityDirective({required this.targetVelocity, double? tolerance})
    : explicitTolerance = tolerance;

  double get tolerance => explicitTolerance ?? 0.02;

  double effectiveTolerance(SceneView scene) {
    if (explicitTolerance != null) return explicitTolerance!;
    final range = (scene.velocity.max - scene.velocity.min).abs();
    if (range > 0) {
      return (range * 0.01).clamp(0.01, 0.03);
    }
    return 0.02;
  }

  @override
  String get highlightId => 'slider.velocity';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return (scene.velocity.value - targetVelocity).abs() <=
        effectiveTolerance(scene);
  }

  @override
  String statusText(SceneView scene) {
    return 'Target: v = ${targetVelocity.toStringAsFixed(2)}  (Current: ${scene.velocity.value.toStringAsFixed(2)})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.velocity.value = targetVelocity;
    scene.updateScene();
  }
}

/// Combined time directive: highlights time slider and checks target.
class TimeDirective extends TutorialDirective {
  final double targetTime;
  final double? explicitTolerance;

  TimeDirective({required this.targetTime, double? tolerance})
    : explicitTolerance = tolerance;

  double get tolerance => explicitTolerance ?? 0.04;

  double effectiveTolerance(SceneView scene) {
    if (explicitTolerance != null) return explicitTolerance!;
    final range = (scene.time.max - scene.time.min).abs();
    // Default to ~1% of the slider range (e.g. 0.04 for standard range 4.0)
    if (range > 0) {
      return (range * 0.01).clamp(0.02, 0.05);
    }
    return 0.04;
  }

  @override
  String get highlightId => 'slider.time';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return (scene.time.value - targetTime).abs() <= effectiveTolerance(scene);
  }

  @override
  String statusText(SceneView scene) {
    return 'Target: t = ${targetTime.toStringAsFixed(2)}  (Current: ${scene.time.value.toStringAsFixed(2)})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.time.value = targetTime;
    scene.updateScene();
  }
}

/// Combined mode directive: highlights light speed menu and checks selection.
class ModeDirective extends TutorialDirective {
  final LightSpeed targetMode;

  ModeDirective({required this.targetMode});

  @override
  String get highlightId => 'menu.light_speed';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return scene.lightSpeed.value == targetMode;
  }

  @override
  String statusText(SceneView scene) {
    return 'Menu (☰) → View → ${targetMode.name}  (Current: ${scene.lightSpeed.value.name})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.lightSpeed.value = targetMode;
    scene.updateScene();
  }
}

/// Tool directive: highlights Select/Add tool chooser and checks selection.
class ToolDirective extends TutorialDirective {
  final Tool targetTool;

  ToolDirective({required this.targetTool});

  @override
  String get highlightId => 'tool.mode';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return scene.currentTool.value == targetTool;
  }

  @override
  String statusText(SceneView scene) {
    return 'Tool: ${targetTool.label}  (Current: ${scene.currentTool.value.label})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentTool.value = targetTool;
  }
}

/// DrawType directive: highlights object type chooser and checks selection.
class DrawTypeDirective extends TutorialDirective {
  final DrawType targetType;

  DrawTypeDirective({required this.targetType});

  @override
  String get highlightId => 'tool.type';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return scene.currentType.value == targetType;
  }

  @override
  String statusText(SceneView scene) {
    return 'Object Type: ${targetType.label}  (Current: ${scene.currentType.value.label})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentType.value = targetType;
  }
}

/// Name directive: highlights object name field and checks value.
class NameDirective extends TutorialDirective {
  final String targetName;

  NameDirective({required this.targetName});

  @override
  String get highlightId => 'tool.name';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return scene.currentName.value.toLowerCase() == targetName.toLowerCase() ||
        (scene.selected != null &&
            scene.selected!.name.toLowerCase() == targetName.toLowerCase());
  }

  @override
  String statusText(SceneView scene) {
    return 'Set Name: $targetName  (Current: ${scene.currentName.value})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentName.value = targetName;
  }
}

/// Color directive: highlights color chooser and checks selection.
class ColorDirective extends TutorialDirective {
  final int targetColor;

  ColorDirective({required this.targetColor});

  @override
  String get highlightId => 'tool.color';

  @override
  bool get canDoItForMe => true;

  @override
  bool isSatisfied(SceneView scene) {
    return scene.currentColor.value == targetColor ||
        (scene.selected != null && scene.selected!.color == targetColor);
  }

  @override
  String statusText(SceneView scene) {
    return 'Select Color: $targetColor  (Current: ${scene.currentColor.value})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentColor.value = targetColor;
  }
}

/// Interactive directive guiding the user to add an object of [targetType]
/// onto the canvas (near recommended [targetX], [targetT]).
class AddObjectDirective extends TutorialDirective {
  final DrawType targetType;
  final double? targetX;
  final double? targetT;
  final double tolerance;
  final String? targetName;
  final int? targetColor;

  int _initialCount = 0;

  AddObjectDirective({
    required this.targetType,
    this.targetX,
    this.targetT,
    this.tolerance = 0.5,
    this.targetName,
    this.targetColor,
  });

  /// Recommended location where the object should be placed (defaults to 0, 0).
  Point get recommendedPoint => Point(x: targetX ?? 0.0, t: targetT ?? 0.0);

  @override
  String get highlightId => 'canvas.point';

  @override
  String highlightIdFor(SceneView scene) {
    if (scene.currentTool.value != Tool.add) return 'tool.mode';
    if (scene.currentType.value != targetType) return 'tool.type';
    if (targetColor != null && scene.currentColor.value != targetColor) {
      return 'tool.color';
    }
    if (targetName != null &&
        scene.currentName.value.toLowerCase() != targetName!.toLowerCase()) {
      return 'tool.name';
    }
    return 'canvas.point';
  }

  @override
  bool get canDoItForMe => true;

  bool _matches(Drawable d) {
    if (d.type != targetType) return false;
    if (targetName != null &&
        d.name.toLowerCase() != targetName!.toLowerCase()) {
      return false;
    }
    if (targetColor != null && d.color != targetColor) return false;
    if (targetX != null &&
        (d.pt.x - targetX!).abs() > tolerance &&
        (d.ptObs.x - targetX!).abs() > tolerance) {
      return false;
    }
    if (targetT != null &&
        (d.pt.t - targetT!).abs() > tolerance &&
        (d.ptObs.t - targetT!).abs() > tolerance) {
      return false;
    }
    return true;
  }

  @override
  void onStepStart(SceneView scene) {
    _initialCount = scene.data.drawables.where(_matches).length;
  }

  @override
  bool isSatisfied(SceneView scene) {
    final count = scene.data.drawables.where(_matches).length;
    return count > _initialCount;
  }

  @override
  String statusText(SceneView scene) {
    if (scene.currentTool.value != Tool.add) {
      return '1. Switch tool to Add (Current: ${scene.currentTool.value.label})';
    }
    if (scene.currentType.value != targetType) {
      return '2. Select object type: ${targetType.label} (Current: ${scene.currentType.value.label})';
    }
    if (targetColor != null && scene.currentColor.value != targetColor) {
      return 'Select color $targetColor';
    }
    if (targetName != null &&
        scene.currentName.value.toLowerCase() != targetName!.toLowerCase()) {
      return 'Set object name to $targetName';
    }
    final pt = recommendedPoint;
    final xStr = pt.x.toStringAsFixed(1);
    final tStr = pt.t.toStringAsFixed(1);
    return 'Click canvas near (x=$xStr, t=$tStr) to place ${targetType.label}';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentTool.value = Tool.add;
    scene.currentType.value = targetType;
    if (targetColor != null) {
      scene.currentColor.value = targetColor!;
    }
    if (targetName != null) {
      scene.currentName.value = targetName!;
    }
    scene.addObject(recommendedPoint);
    scene.updateScene();
    scene.requestRepaintScene();
  }
}

/// Interactive directive guiding the user to select an object on the canvas.
class SelectObjectDirective extends TutorialDirective {
  final String target;

  SelectObjectDirective({required this.target});

  @override
  String get highlightId => 'canvas.object';

  @override
  String highlightIdFor(SceneView scene) {
    if (scene.currentTool.value != Tool.select) return 'tool.mode';
    return 'canvas.object';
  }

  @override
  bool get canDoItForMe => true;

  bool _matches(Drawable? d) {
    if (d == null) return false;
    if (d.name.toLowerCase() == target.toLowerCase()) return true;
    final dt = Tutorial.parseDrawType(target);
    if (dt != null && d.type == dt) return true;
    return false;
  }

  /// Finds the drawable matching [target] in [scene].
  Drawable? findTargetDrawable(SceneView scene) {
    for (final d in scene.data.drawables) {
      if (_matches(d)) return d;
    }
    return null;
  }

  @override
  bool isSatisfied(SceneView scene) => _matches(scene.selected);

  @override
  String statusText(SceneView scene) {
    if (scene.currentTool.value != Tool.select) {
      return 'Switch tool to Select (Current: ${scene.currentTool.value.label})';
    }
    return "Click on '$target' in the diagram to select it";
  }

  @override
  void applyDoItForMe(SceneView scene) {
    scene.currentTool.value = Tool.select;
    final d = findTargetDrawable(scene);
    if (d != null) {
      scene.setSelected(d);
      scene.requestRepaintScene();
    }
  }
}

/// Interactive directive guiding the user to drag/move an object to target coordinates.
class MoveObjectDirective extends TutorialDirective {
  final String target;
  final double? targetX;
  final double? targetT;
  final double tolerance;

  MoveObjectDirective({
    required this.target,
    this.targetX,
    this.targetT,
    this.tolerance = 0.25,
  });

  @override
  String get highlightId => 'canvas.object';

  @override
  bool get canDoItForMe => true;

  Drawable? findTargetDrawable(SceneView scene) {
    for (final d in scene.data.drawables) {
      if (d.name.toLowerCase() == target.toLowerCase()) return d;
    }
    final dt = Tutorial.parseDrawType(target);
    if (dt != null) {
      for (final d in scene.data.drawables) {
        if (d.type == dt) return d;
      }
    }
    return null;
  }

  @override
  bool isSatisfied(SceneView scene) {
    final d = findTargetDrawable(scene);
    if (d == null) return false;
    if (targetX != null &&
        (d.pt.x - targetX!).abs() > tolerance &&
        (d.ptObs.x - targetX!).abs() > tolerance) {
      return false;
    }
    if (targetT != null &&
        (d.pt.t - targetT!).abs() > tolerance &&
        (d.ptObs.t - targetT!).abs() > tolerance) {
      return false;
    }
    return true;
  }

  @override
  String statusText(SceneView scene) {
    final d = findTargetDrawable(scene);
    final xStr = (targetX ?? 0.0).toStringAsFixed(1);
    final tStr = (targetT ?? 0.0).toStringAsFixed(1);
    if (d == null) {
      return 'Move $target to (x=$xStr, t=$tStr)';
    }
    return 'Move ${d.name} to (x=$xStr, t=$tStr)  (Current: x=${d.pt.x.toStringAsFixed(1)}, t=${d.pt.t.toStringAsFixed(1)})';
  }

  @override
  void applyDoItForMe(SceneView scene) {
    final d = findTargetDrawable(scene);
    if (d != null) {
      d.moveTo(Point(x: targetX ?? d.pt.x, t: targetT ?? d.pt.t, z: d.pt.z));
      scene.updateScene();
      scene.requestRepaintScene();
    }
  }
}

/// Acknowledge directive: user clicks Continue to advance.
class AcknowledgeDirective extends TutorialDirective {
  AcknowledgeDirective();

  @override
  String get highlightId => 'tutorial.continue';

  @override
  bool isSatisfied(SceneView scene) => false;

  @override
  String statusText(SceneView scene) => 'Click Continue to proceed';
}

/// Reset directive: clears canvas at step start.
class ResetDirective extends TutorialDirective {
  @override
  String get highlightId => '';

  @override
  bool get isSetupAction => true;

  @override
  bool isSatisfied(SceneView scene) => true;

  @override
  String statusText(SceneView scene) => '';

  @override
  void onStepStart(SceneView scene) {
    scene.selected = null;
    scene.data.drawables.clear();
    scene.updateScene();
    scene.requestRepaintScene();
  }
}

/// Setup directive: programmatically sets initial state at step start.
class SetupDirective extends TutorialDirective {
  final double? velocity;
  final double? time;
  final LightSpeed? mode;
  final Tool? tool;
  final DrawType? type;

  SetupDirective({this.velocity, this.time, this.mode, this.tool, this.type});

  @override
  String get highlightId => '';

  @override
  bool get isSetupAction => true;

  @override
  bool isSatisfied(SceneView scene) => true;

  @override
  String statusText(SceneView scene) => '';

  @override
  void onStepStart(SceneView scene) {
    if (velocity != null) {
      scene.velocity.value = velocity!;
    }
    if (time != null) {
      scene.time.value = time!;
    }
    if (mode != null) {
      scene.lightSpeed.value = mode!;
    }
    if (tool != null) {
      scene.currentTool.value = tool!;
    }
    if (type != null) {
      scene.currentType.value = type!;
    }
    scene.updateScene();
  }
}

/// Object directive: adds or updates inline objects in the scene at step start.
class ObjectDirective extends TutorialDirective {
  final List<Drawable> drawables;

  ObjectDirective(this.drawables);

  @override
  String get highlightId => '';

  @override
  bool get isSetupAction => true;

  @override
  bool isSatisfied(SceneView scene) => true;

  @override
  String statusText(SceneView scene) => '';

  @override
  void onStepStart(SceneView scene) {
    for (final template in drawables) {
      final copy = template.clone();
      final existingIdx = scene.data.drawables.indexWhere(
        (d) => d.name == copy.name,
      );
      if (existingIdx >= 0) {
        scene.data.drawables[existingIdx] = copy;
      } else {
        scene.data.drawables.add(copy);
      }
      scene.guess.riseAbove(copy.name);
    }
    scene.updateScene();
    scene.requestRepaintScene();
  }
}

/// Represents a single step in a tutorial.
class TutorialStep {
  final int stepNumber;
  final String title;
  final String body;
  final List<TutorialDirective> directives;

  TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.body,
    required this.directives,
  });

  /// The primary highlight target ID, or null if none.
  String? get highlightId {
    for (final d in directives) {
      if (d.highlightId.isNotEmpty) {
        return d.highlightId;
      }
    }
    return null;
  }

  /// Dynamic highlight target ID based on current scene state.
  String? highlightIdFor(SceneView scene) {
    for (final d in directives) {
      if (!d.isSetupAction && !d.isSatisfied(scene)) {
        final id = d.highlightIdFor(scene);
        if (id.isNotEmpty) return id;
      }
    }
    if (isSatisfied(scene)) {
      return 'tutorial.continue';
    }
    return highlightId;
  }

  /// Whether all interactive exit criteria are currently satisfied.
  bool isSatisfied(SceneView scene) {
    final interactive = directives.where((d) => !d.isSetupAction);
    if (interactive.isEmpty) return true;
    for (final d in interactive) {
      if (d is AcknowledgeDirective) return false;
      if (!d.isSatisfied(scene)) return false;
    }
    return true;
  }

  /// Status string to display in UI.
  String statusText(SceneView scene) {
    for (final d in directives) {
      if (!d.isSetupAction && !d.isSatisfied(scene)) {
        final text = d.statusText(scene);
        if (text.isNotEmpty) return text;
      }
    }
    for (final d in directives) {
      final text = d.statusText(scene);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  /// Whether any directive in this step can be auto-completed.
  bool get canDoItForMe => directives.any((d) => d.canDoItForMe);

  /// Automatically applies the target state for this step.
  void doItForMe(SceneView scene) {
    for (final d in directives) {
      d.applyDoItForMe(scene);
    }
  }

  void onStepStart(SceneView scene) {
    for (final d in directives) {
      d.onStepStart(scene);
    }
  }
}
