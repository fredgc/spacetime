import 'dart:convert';
import 'package:flutter/material.dart';

import '../drawable.dart';
import '../scene.dart';
import '../transform.dart';
import 'tutorial_step.dart';

/// Legacy prompt tag placeholder.
class Prompt {
  String tag;
  Prompt(this.tag);
}

/// Legacy script item placeholder.
class ScriptItem {
  Prompt prompt;
  String text;

  ScriptItem(this.prompt, this.text);
}

/// Legacy script holder.
class MyScript {
  final String script;

  MyScript(this.script);
}

/// A parsed tutorial lesson.
class Tutorial {
  final String title;
  final String description;
  final List<TutorialStep> steps;
  final bool allowDoItForMe;

  Tutorial({
    required this.title,
    this.description = '',
    required this.steps,
    this.allowDoItForMe = true,
  });

  factory Tutorial.fromMarkdown(String markdown) {
    final lines = markdown.split('\n');
    String title = 'Spacetime Tutorial';
    final descLines = <String>[];
    final steps = <TutorialStep>[];
    bool allowDoItForMe = true;

    String? currentStepTitle;
    final currentStepBody = <String>[];
    final currentStepDirectives = <TutorialDirective>[];
    final pendingDirectiveLines = <String>[];
    int stepCount = 0;

    void flushPendingDirectives() {
      if (pendingDirectiveLines.isEmpty) return;
      final combined = pendingDirectiveLines.join(' ');
      pendingDirectiveLines.clear();
      final parsed = _parseDirectives(
        combined,
        onDisableAuto: () => allowDoItForMe = false,
      );
      currentStepDirectives.addAll(parsed);
    }

    void finalizeCurrentStep() {
      flushPendingDirectives();
      if (currentStepTitle != null) {
        final hasInteractive = currentStepDirectives.any(
          (d) => !d.isSetupAction,
        );
        if (!hasInteractive) {
          currentStepDirectives.add(AcknowledgeDirective());
        }

        steps.add(
          TutorialStep(
            stepNumber: stepCount,
            title: currentStepTitle,
            body: currentStepBody.join('\n').trim(),
            directives: List.from(currentStepDirectives),
          ),
        );
      }
      currentStepBody.clear();
      currentStepDirectives.clear();
    }

    for (var rawLine in lines) {
      final line = rawLine.trim();

      if (line.startsWith('>')) {
        pendingDirectiveLines.add(line.substring(1).trim());
        continue;
      }

      flushPendingDirectives();

      if (line.startsWith('# ') && currentStepTitle == null) {
        title = line.substring(2).trim();
      } else if (line.startsWith('## ')) {
        finalizeCurrentStep();
        stepCount++;
        currentStepTitle = line.substring(3).trim();
        final match = RegExp(
          r'^(Step\s+\d+:?|\d+\.?)\s*(.*)',
          caseSensitive: false,
        ).firstMatch(currentStepTitle);
        if (match != null && match.group(2)!.isNotEmpty) {
          currentStepTitle = match.group(2)!.trim();
        }
      } else {
        if (currentStepTitle == null) {
          if (line.isNotEmpty) descLines.add(line);
        } else {
          currentStepBody.add(rawLine);
        }
      }
    }
    finalizeCurrentStep();

    return Tutorial(
      title: title,
      description: descLines.join('\n').trim(),
      steps: steps,
      allowDoItForMe: allowDoItForMe,
    );
  }

  /// Parses one or more directives from a blockquote string (even when
  /// multiple directives have been merged onto a single line by mdformat).
  static List<TutorialDirective> _parseDirectives(
    String text, {
    required VoidCallback onDisableAuto,
  }) {
    final results = <TutorialDirective>[];
    int pos = 0;
    final int len = text.length;

    while (pos < len) {
      // Skip whitespace, semicolons, and stray commas.
      while (pos < len &&
          (text[pos] == ' ' ||
              text[pos] == '\t' ||
              text[pos] == ';' ||
              text[pos] == ',')) {
        pos++;
      }
      if (pos >= len) break;

      final rem = text.substring(pos);

      // 1. Auto-complete disable flags
      final noAutoMatch = RegExp(
        r'^(?:no_auto|disable_auto|allow_auto\s*=\s*false|disable_do_it_for_me)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (noAutoMatch != null) {
        onDisableAuto();
        pos += noAutoMatch.end;
        continue;
      }

      // 2. Reset directive
      final resetMatch = RegExp(
        r'^reset\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (resetMatch != null) {
        results.add(ResetDirective());
        pos += resetMatch.end;
        continue;
      }

      // 3. Acknowledge directive: ok | next | continue
      final okMatch = RegExp(
        r'^(?:ok|next|continue)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (okMatch != null) {
        results.add(AcknowledgeDirective());
        pos += okMatch.end;
        continue;
      }

      // 4. Setup directive: setup: <comma-separated items>
      final setupMatch = RegExp(
        r'^setup\s*:\s*',
        caseSensitive: false,
      ).firstMatch(rem);
      if (setupMatch != null) {
        pos += setupMatch.end;
        pos = _consumeSetupDirective(text, pos, results);
        continue;
      }

      // 5. Inline object / scene directive: object: ... or scene: ...
      final objMatch = RegExp(
        r'^(?:object|objects|load_object|scene)\s*:\s*',
        caseSensitive: false,
      ).firstMatch(rem);
      if (objMatch != null) {
        pos += objMatch.end;
        pos = _consumeObjectDirective(text, pos, results);
        continue;
      }

      // 6. Add / Place interactive directive: add = <type>[(...)]
      final addMatch = RegExp(
        r'^(?:add|place)\s*=\s*(event|instant|light\s*cone|light_cone|lightcone|cone|clock|person|train|barn|flag)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (addMatch != null) {
        final drawType = parseDrawType(addMatch.group(1)!);
        pos += addMatch.end;
        Map<String, String> args = {};
        pos = _consumeOptionalParenArgs(text, pos, (parsed) => args = parsed);
        if (drawType != null) {
          results.add(
            AddObjectDirective(
              targetType: drawType,
              targetX: args['x'] != null ? double.tryParse(args['x']!) : null,
              targetT: (args['t'] ?? args['time']) != null
                  ? double.tryParse((args['t'] ?? args['time'])!)
                  : null,
              tolerance: (args['tol'] ?? args['tolerance']) != null
                  ? (double.tryParse((args['tol'] ?? args['tolerance'])!) ??
                        0.5)
                  : 0.5,
              targetName: args['name'],
              targetColor: (args['color'] ?? args['c']) != null
                  ? parseColor((args['color'] ?? args['c'])!)
                  : null,
            ),
          );
        }
        continue;
      }

      // 7. Select interactive directive: select = <name|type>
      final selectMatch = RegExp(
        r'^select\s*=\s*(?:"([^"]+)"|'
        r"'([^']+)'"
        r'|([^\s,;()]+))',
        caseSensitive: false,
      ).firstMatch(rem);
      if (selectMatch != null) {
        final target =
            (selectMatch.group(1) ??
                    selectMatch.group(2) ??
                    selectMatch.group(3)!)
                .trim();
        results.add(SelectObjectDirective(target: target));
        pos += selectMatch.end;
        continue;
      }

      // 8. Move interactive directive: move = <name|type>(x=..., t=...)
      final moveMatch = RegExp(
        r'^move\s*=\s*(?:"([^"]+)"|'
        r"'([^']+)'"
        r'|([^\s,;()]+))',
        caseSensitive: false,
      ).firstMatch(rem);
      if (moveMatch != null) {
        final target =
            (moveMatch.group(1) ?? moveMatch.group(2) ?? moveMatch.group(3)!)
                .trim();
        pos += moveMatch.end;
        Map<String, String> args = {};
        pos = _consumeOptionalParenArgs(text, pos, (parsed) => args = parsed);
        results.add(
          MoveObjectDirective(
            target: target,
            targetX: args['x'] != null ? double.tryParse(args['x']!) : null,
            targetT: (args['t'] ?? args['time']) != null
                ? double.tryParse((args['t'] ?? args['time'])!)
                : null,
            tolerance: (args['tol'] ?? args['tolerance']) != null
                ? (double.tryParse((args['tol'] ?? args['tolerance'])!) ?? 0.25)
                : 0.25,
          ),
        );
        continue;
      }

      // 9. Tool directive: tool = <select|add>
      final toolMatch = RegExp(
        r'^tool\s*=\s*(select|add)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (toolMatch != null) {
        final tool = parseTool(toolMatch.group(1)!);
        if (tool != null) {
          results.add(ToolDirective(targetTool: tool));
        }
        pos += toolMatch.end;
        continue;
      }

      // 10. DrawType directive: type = <type>
      final typeMatch = RegExp(
        r'^type\s*=\s*(event|instant|light\s*cone|light_cone|lightcone|cone|clock|person|train|barn|flag)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (typeMatch != null) {
        final drawType = parseDrawType(typeMatch.group(1)!);
        if (drawType != null) {
          results.add(DrawTypeDirective(targetType: drawType));
        }
        pos += typeMatch.end;
        continue;
      }

      // 11. Name directive: name = <name>
      final nameMatch = RegExp(
        r'^name\s*=\s*(?:"([^"]+)"|'
        r"'([^']+)'"
        r'|([^\s,;()]+))',
        caseSensitive: false,
      ).firstMatch(rem);
      if (nameMatch != null) {
        final targetName =
            (nameMatch.group(1) ?? nameMatch.group(2) ?? nameMatch.group(3)!)
                .trim();
        results.add(NameDirective(targetName: targetName));
        pos += nameMatch.end;
        continue;
      }

      // 12. Color directive: color = <color>
      final colorMatch = RegExp(
        r'^color\s*=\s*([^\s,;()]+)',
        caseSensitive: false,
      ).firstMatch(rem);
      if (colorMatch != null) {
        final targetColor = parseColor(colorMatch.group(1)!);
        if (targetColor != null) {
          results.add(ColorDirective(targetColor: targetColor));
        }
        pos += colorMatch.end;
        continue;
      }

      // 13. Velocity: v = <num> [tol=<num>] or velocity = <num>
      final vMatch = RegExp(
        r'^(?:v|velocity)\s*=\s*(-?[\d.]+)(?:\s+tol\s*=\s*([\d.]+))?',
        caseSensitive: false,
      ).firstMatch(rem);
      if (vMatch != null) {
        final target = double.tryParse(vMatch.group(1)!);
        final tol = vMatch.group(2) != null
            ? double.tryParse(vMatch.group(2)!)
            : null;
        if (target != null) {
          results.add(
            VelocityDirective(targetVelocity: target, tolerance: tol ?? 0.02),
          );
        }
        pos += vMatch.end;
        continue;
      }

      // 14. Time: t = <num> [tol=<num>] or time = <num>
      final tMatch = RegExp(
        r'^(?:t|time)\s*=\s*(-?[\d.]+)(?:\s+tol\s*=\s*([\d.]+))?',
        caseSensitive: false,
      ).firstMatch(rem);
      if (tMatch != null) {
        final target = double.tryParse(tMatch.group(1)!);
        final tol = tMatch.group(2) != null
            ? double.tryParse(tMatch.group(2)!)
            : null;
        if (target != null) {
          results.add(TimeDirective(targetTime: target, tolerance: tol ?? 0.1));
        }
        pos += tMatch.end;
        continue;
      }

      // 15. Mode: mode = <lorentz|ether|emitter> or bare lorentz|ether|emitter
      final modeMatch = RegExp(
        r'^(?:mode\s*=\s*)?(lorentz|ether|emitter)\b',
        caseSensitive: false,
      ).firstMatch(rem);
      if (modeMatch != null) {
        final mode = parseLightSpeed(modeMatch.group(1)!);
        if (mode != null) {
          results.add(ModeDirective(targetMode: mode));
        }
        pos += modeMatch.end;
        continue;
      }

      // Unknown token: skip past current non-whitespace token to prevent loops.
      final skipMatch = RegExp(r'^\S+').firstMatch(rem);
      pos += skipMatch?.end ?? 1;
    }

    return results;
  }

  /// Consumes comma-separated setup items (e.g. `v=0.0, t=0.0, mode=lorentz`
  /// or inline objects like `person(name="Alice", x=0)`) starting at [pos].
  static int _consumeSetupDirective(
    String text,
    int pos,
    List<TutorialDirective> results,
  ) {
    double? v;
    double? t;
    LightSpeed? mode;
    Tool? tool;
    DrawType? type;
    final inlineObjects = <Drawable>[];

    final int len = text.length;
    while (pos < len) {
      while (pos < len && (text[pos] == ' ' || text[pos] == '\t')) {
        pos++;
      }
      if (pos >= len) break;

      final rem = text.substring(pos);

      // Check for inline object spec inside setup: e.g. person(name="Alice", x=0)
      final fnMatch = RegExp(
        r'^(event|instant|light\s*cone|light_cone|lightcone|cone|clock|person|train|barn|flag)\s*\(',
        caseSensitive: false,
      ).firstMatch(rem);
      if (fnMatch != null) {
        final drawType = parseDrawType(fnMatch.group(1)!);
        final openParenPos = pos + fnMatch.end - 1;
        final closeParenPos = _findMatchingDelimiter(
          text,
          openParenPos,
          '(',
          ')',
        );
        final argsStr = text.substring(openParenPos + 1, closeParenPos);
        if (drawType != null) {
          final d = _buildDrawableFromArgs(
            drawType,
            _parseKeyValueArgs(argsStr),
          );
          inlineObjects.add(d);
        }
        pos = closeParenPos < len ? closeParenPos + 1 : len;
      } else {
        // Parse key=value pair
        final kvMatch = RegExp(
          r'^(v|velocity|t|time|mode|tool|type)\s*=\s*([^\s,;]+)',
          caseSensitive: false,
        ).firstMatch(rem);
        if (kvMatch == null) break;

        final key = kvMatch.group(1)!.toLowerCase();
        final val = kvMatch.group(2)!.toLowerCase();
        if (key == 'v' || key == 'velocity') {
          v = double.tryParse(val);
        } else if (key == 't' || key == 'time') {
          t = double.tryParse(val);
        } else if (key == 'mode') {
          mode = parseLightSpeed(val);
        } else if (key == 'tool') {
          tool = parseTool(val);
        } else if (key == 'type') {
          type = parseDrawType(val);
        }
        pos += kvMatch.end;
      }

      while (pos < len && (text[pos] == ' ' || text[pos] == '\t')) {
        pos++;
      }
      if (pos < len && text[pos] == ',') {
        pos++;
      } else {
        break;
      }
    }

    if (v != null ||
        t != null ||
        mode != null ||
        tool != null ||
        type != null) {
      results.add(
        SetupDirective(
          velocity: v,
          time: t,
          mode: mode,
          tool: tool,
          type: type,
        ),
      );
    }
    if (inlineObjects.isNotEmpty) {
      results.add(ObjectDirective(inlineObjects));
    }
    return pos;
  }

  /// Consumes inline object definitions (function-style `person(...)` or JSON `{...}`)
  /// starting at [pos].
  static int _consumeObjectDirective(
    String text,
    int pos,
    List<TutorialDirective> results,
  ) {
    final drawables = <Drawable>[];
    final int len = text.length;

    while (pos < len) {
      while (pos < len && (text[pos] == ' ' || text[pos] == '\t')) {
        pos++;
      }
      if (pos >= len) break;

      if (text[pos] == '{') {
        final closePos = _findMatchingDelimiter(text, pos, '{', '}');
        final jsonStr = text.substring(
          pos,
          closePos < len ? closePos + 1 : len,
        );
        try {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map<String, dynamic>) {
            if (decoded['drawables'] is List) {
              final sceneData = SceneData.fromJson(decoded);
              if (decoded.containsKey('velocity') ||
                  decoded.containsKey('time')) {
                results.add(
                  SetupDirective(
                    velocity: (decoded['velocity'] as num?)?.toDouble(),
                    time: (decoded['time'] as num?)?.toDouble(),
                  ),
                );
              }
              drawables.addAll(sceneData.drawables);
            } else {
              final d = _parseDrawableMap(decoded);
              if (d != null) drawables.add(d);
            }
          }
        } catch (_) {
          // Ignore malformed inline JSON.
        }
        pos = closePos < len ? closePos + 1 : len;
      } else {
        final rem = text.substring(pos);
        final fnMatch = RegExp(
          r'^(event|instant|light\s*cone|light_cone|lightcone|cone|clock|person|train|barn|flag)\b',
          caseSensitive: false,
        ).firstMatch(rem);
        if (fnMatch == null) break;

        final drawType = parseDrawType(fnMatch.group(1)!);
        pos += fnMatch.end;
        Map<String, String> args = {};
        pos = _consumeOptionalParenArgs(text, pos, (parsed) => args = parsed);
        if (drawType != null) {
          drawables.add(_buildDrawableFromArgs(drawType, args));
        }
      }

      while (pos < len && (text[pos] == ' ' || text[pos] == '\t')) {
        pos++;
      }
      if (pos < len && text[pos] == ',') {
        pos++;
      } else {
        break;
      }
    }

    if (drawables.isNotEmpty) {
      results.add(ObjectDirective(drawables));
    }
    return pos;
  }

  static int _consumeOptionalParenArgs(
    String text,
    int pos,
    void Function(Map<String, String>) onParsed,
  ) {
    final int len = text.length;
    int lookahead = pos;
    while (lookahead < len &&
        (text[lookahead] == ' ' || text[lookahead] == '\t')) {
      lookahead++;
    }
    if (lookahead < len && text[lookahead] == '(') {
      final closePos = _findMatchingDelimiter(text, lookahead, '(', ')');
      final argsStr = text.substring(lookahead + 1, closePos);
      onParsed(_parseKeyValueArgs(argsStr));
      return closePos < len ? closePos + 1 : len;
    }
    return pos;
  }

  static int _findMatchingDelimiter(
    String text,
    int startPos,
    String openChar,
    String closeChar,
  ) {
    int depth = 0;
    bool inDoubleQuote = false;
    bool inSingleQuote = false;
    for (int i = startPos; i < text.length; i++) {
      final ch = text[i];
      if (ch == '"' && !inSingleQuote && (i == 0 || text[i - 1] != '\\')) {
        inDoubleQuote = !inDoubleQuote;
      } else if (ch == "'" &&
          !inDoubleQuote &&
          (i == 0 || text[i - 1] != '\\')) {
        inSingleQuote = !inSingleQuote;
      } else if (!inDoubleQuote && !inSingleQuote) {
        if (ch == openChar) {
          depth++;
        } else if (ch == closeChar) {
          depth--;
          if (depth == 0) return i;
        }
      }
    }
    return text.length;
  }

  static Map<String, String> _parseKeyValueArgs(String argsStr) {
    final map = <String, String>{};
    final pattern = RegExp(
      r'([a-zA-Z_]\w*)\s*=\s*(?:"([^"]*)"|'
      r"'([^']*)'"
      r'|([^\s,)]+))',
    );
    for (final m in pattern.allMatches(argsStr)) {
      final key = m.group(1)!.toLowerCase();
      final val = (m.group(2) ?? m.group(3) ?? m.group(4) ?? '').trim();
      map[key] = val;
    }
    return map;
  }

  static Drawable _buildDrawableFromArgs(
    DrawType drawType,
    Map<String, String> args,
  ) {
    final name = (args['name'] != null && args['name']!.isNotEmpty)
        ? args['name']!
        : '${drawType.prefix}1';
    final x = args['x'] != null ? (double.tryParse(args['x']!) ?? 0.0) : 0.0;
    final tVal = args['t'] ?? args['time'];
    final t = tVal != null ? (double.tryParse(tVal) ?? 0.0) : 0.0;
    final z = args['z'] != null ? (double.tryParse(args['z']!) ?? 0.0) : 0.0;
    final vVal = args['v'] ?? args['velocity'];
    final v = vVal != null ? (double.tryParse(vVal) ?? 0.0) : 0.0;
    final cVal = args['color'] ?? args['c'];
    final color = cVal != null ? (parseColor(cVal) ?? 0) : 0;

    final frame = ReferenceFrame.fromV(v);
    frame.center = Point(x: x, t: t, z: z);
    return drawType.make(name, frame, color);
  }

  static Drawable? _parseDrawableMap(Map<String, dynamic> map) {
    final typeStr = map['type']?.toString();
    if (typeStr == null) return null;
    final drawType = parseDrawType(typeStr);
    if (drawType == null) return null;
    final name = map['name']?.toString() ?? '${drawType.prefix}1';
    final color = map['color'] is int
        ? map['color'] as int
        : (parseColor(map['color']?.toString() ?? '0') ?? 0);

    if (map['frame'] is Map<String, dynamic>) {
      final frameMap = Map<String, dynamic>.from(
        map['frame'] as Map<String, dynamic>,
      );
      if (frameMap['center'] == null) {
        frameMap['center'] = {
          'x': (frameMap['x'] as num?)?.toDouble() ?? 0.0,
          't': (frameMap['t'] as num?)?.toDouble() ?? 0.0,
          'z': (frameMap['z'] as num?)?.toDouble() ?? 0.0,
        };
      }
      final frame = ReferenceFrame.fromJson(frameMap);
      return drawType.make(name, frame, color);
    }

    final v = (map['velocity'] as num? ?? map['v'] as num?)?.toDouble() ?? 0.0;
    final x = (map['x'] as num?)?.toDouble() ?? 0.0;
    final t = (map['t'] as num? ?? map['time'] as num?)?.toDouble() ?? 0.0;
    final z = (map['z'] as num?)?.toDouble() ?? 0.0;
    final frame = ReferenceFrame.fromV(v);
    frame.center = Point(x: x, t: t, z: z);
    return drawType.make(name, frame, color);
  }

  static LightSpeed? parseLightSpeed(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.contains('ether')) return LightSpeed.ether;
    if (lower.contains('lorentz')) return LightSpeed.lorentz;
    if (lower.contains('emitter')) return LightSpeed.emitter;
    return null;
  }

  static Tool? parseTool(String text) {
    final lower = text.toLowerCase().trim();
    if (lower == 'select') return Tool.select;
    if (lower == 'add') return Tool.add;
    return null;
  }

  static DrawType? parseDrawType(String text) {
    final lower = text.toLowerCase().trim().replaceAll(RegExp(r'[\s_]+'), '');
    switch (lower) {
      case 'event':
        return DrawType.event;
      case 'instant':
        return DrawType.instant;
      case 'cone':
      case 'lightcone':
        return DrawType.cone;
      case 'clock':
        return DrawType.clock;
      case 'person':
        return DrawType.person;
      case 'train':
        return DrawType.train;
      case 'barn':
        return DrawType.barn;
      case 'flag':
        return DrawType.flag;
      default:
        return null;
    }
  }

  static int? parseColor(String text) {
    final lower = text.toLowerCase().trim();
    final asInt = int.tryParse(lower);
    if (asInt != null) {
      return asInt.clamp(0, SceneView.colorList.value.length - 1);
    }
    const colorNames = <String, int>{
      'default': 0,
      'white': 0,
      'black': 0,
      'purple': 1,
      'blue': 2,
      'teal': 3,
      'cyan': 4,
      'green': 5,
      'orange': 6,
      'yellow': 6,
      'red': 7,
      'brown': 8,
    };
    return colorNames[lower];
  }
}
