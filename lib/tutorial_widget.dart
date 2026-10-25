import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'drawable.dart';
import 'scene.dart';
import 'script.dart';
import 'transform.dart';

/// Floating, draggable, and minimizable tutorial overlay card.
class TutorialCard extends StatefulWidget {
  final TutorialController controller;
  final VoidCallback onClose;
  final VoidCallback? onFinish;

  const TutorialCard({
    super.key,
    required this.controller,
    required this.onClose,
    this.onFinish,
  });

  @override
  State<TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<TutorialCard> {
  Offset _offset = Offset.zero;
  bool _isMinimized = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final controller = widget.controller;

        if (controller.isCompleted) {
          return Transform.translate(
            offset: _offset,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade600,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tutorial Completed!",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Great job! You have completed all steps in ${controller.tutorial.title}. You can now continue playing with the scene and save your result.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      key: const ValueKey('tutorial-finish-btn'),
                      onPressed: widget.onFinish ?? widget.onClose,
                      child: const Text("Finish (Keep Scene)"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (_isMinimized) {
          return Transform.translate(
            offset: _offset,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _offset += details.delta;
                });
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: colorScheme.surfaceContainerHigh,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _isMinimized = false),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Step ${controller.currentStepIndex + 1}/${controller.tutorial.steps.length}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.open_in_full,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final step = controller.currentStep;
        if (step == null) return const SizedBox.shrink();

        final isSatisfied = controller.isCurrentStepSatisfied;
        final isContinueEnabled = controller.isContinueEnabled;

        return Transform.translate(
          offset: _offset,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSatisfied
                    ? Colors.green.shade600
                    : colorScheme.outlineVariant,
                width: isSatisfied ? 2.0 : 1.0,
              ),
            ),
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Drag Handle
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      setState(() {
                        _offset += details.delta;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          size: 18,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "TUTORIAL",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Step ${controller.currentStepIndex + 1} of ${controller.tutorial.steps.length}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          tooltip: "Minimize",
                          onPressed: () => setState(() => _isMinimized = true),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: "Reset Step",
                          onPressed: controller.resetCurrentStep,
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          tooltip: "Close Tutorial",
                          onPressed: widget.onClose,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSatisfied
                            ? Colors.green.shade600
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Step Title
                  Text(
                    step.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Step Body Prose
                  MarkdownBody(
                    data: step.body,
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                      listBullet: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      strong: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        height: 1.35,
                      ),
                      em: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                      code: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href));
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Status Chip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSatisfied
                          ? Colors.green.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSatisfied
                            ? Colors.green.shade600
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSatisfied ? Icons.check_circle : Icons.info_outline,
                          size: 16,
                          color: isSatisfied
                              ? Colors.green.shade700
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isSatisfied
                                ? "Target reached! Click Continue."
                                : (step.statusText(controller.scene).isNotEmpty
                                      ? step.statusText(controller.scene)
                                      : "Follow the prompt above"),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSatisfied
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSatisfied
                                  ? Colors.green.shade800
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.canDoItForMe) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const ValueKey('tutorial-do-it-for-me-btn'),
                        icon: const Icon(Icons.auto_fix_high, size: 16),
                        label: const Text("Do it for me"),
                        onPressed: controller.doItForMe,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Action / Navigation Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text("Back"),
                        onPressed: controller.currentStepIndex > 0
                            ? controller.previousStep
                            : null,
                      ),
                      TutorialHighlight(
                        highlightId: 'tutorial.continue',
                        activeHighlightId: controller.currentHighlightId,
                        borderRadius: BorderRadius.circular(24),
                        child: ElevatedButton.icon(
                          key: const ValueKey('tutorial-next-btn'),
                          icon: Icon(
                            controller.currentStepIndex ==
                                    controller.tutorial.steps.length - 1
                                ? Icons.done
                                : Icons.arrow_forward,
                            size: 16,
                          ),
                          label: Text(
                            controller.currentStepIndex ==
                                    controller.tutorial.steps.length - 1
                                ? "Finish"
                                : "Continue",
                          ),
                          style: isContinueEnabled
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                )
                              : null,
                          onPressed: isContinueEnabled
                              ? controller.nextStep
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Drives a repeating 0.0 -> 1.0 -> 0.0 pulse animation when [enabled] is true.
class TutorialPulseBuilder extends StatefulWidget {
  final bool enabled;
  final Widget Function(BuildContext context, double pulse) builder;

  const TutorialPulseBuilder({
    super.key,
    required this.enabled,
    required this.builder,
  });

  @override
  State<TutorialPulseBuilder> createState() => _TutorialPulseBuilderState();
}

class _TutorialPulseBuilderState extends State<TutorialPulseBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(TutorialPulseBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (!widget.enabled) {
      _controller.stop();
      _controller.value = 0.0;
    } else if (TutorialHighlight.shouldAnimate()) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder(context, 0.0);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = Curves.easeInOut.transform(_controller.value);
        return widget.builder(context, pulse);
      },
    );
  }
}

/// Wraps a control widget with an animated pulsing highlight border and glow
/// when [highlightId] matches [activeHighlightId].
class TutorialHighlight extends StatefulWidget {
  /// Optional override to enable repeating pulse animations inside widget tests.
  static bool? forceAnimationInTests;

  /// Returns true when repeating pulse animations should run.
  /// Disabled by default under AutomatedTestWidgetsFlutterBinding so
  /// `tester.pumpAndSettle()` does not time out.
  static bool shouldAnimate() {
    if (forceAnimationInTests != null) return forceAnimationInTests!;
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return !bindingName.contains('TestWidgetsFlutterBinding');
  }

  /// Builds the interpolated BoxDecoration for a given [pulse] in [0.0, 1.0].
  /// At `pulse == 0.0`, the decoration is completely transparent (normal look).
  /// At `pulse == 1.0`, the decoration has a bright border, tint, and halo glow.
  static BoxDecoration buildPulseDecoration(
    BuildContext context,
    double pulse, {
    bool foreground = false,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? Colors.amberAccent.shade400
        : Colors.deepOrangeAccent.shade400;
    final p = pulse.clamp(0.0, 1.0);
    return BoxDecoration(
      color: foreground
          ? accentColor.withValues(alpha: 0.14 * p)
          : accentColor.withValues(alpha: 0.45 * p),
      border: Border.all(color: accentColor.withValues(alpha: p), width: 2.5),
      borderRadius: borderRadius,
      boxShadow: (!foreground && p > 0.05)
          ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.55 * p),
                blurRadius: 10.0 * p,
                spreadRadius: 1.5 * p,
              ),
            ]
          : null,
    );
  }

  final String highlightId;
  final String? activeHighlightId;
  final Widget child;
  final BorderRadius borderRadius;
  final bool foreground;
  final bool ensureVisible;

  const TutorialHighlight({
    super.key,
    required this.highlightId,
    required this.activeHighlightId,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.foreground = false,
    this.ensureVisible = false,
  });

  @override
  State<TutorialHighlight> createState() => _TutorialHighlightState();
}

class _TutorialHighlightState extends State<TutorialHighlight> {
  Timer? _scrollTimer;

  bool get _isHighlighted =>
      widget.activeHighlightId != null &&
      widget.activeHighlightId == widget.highlightId;

  @override
  void initState() {
    super.initState();
    if (_isHighlighted) {
      _scheduleEnsureVisible();
    }
  }

  @override
  void didUpdateWidget(TutorialHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasHighlighted =
        oldWidget.activeHighlightId != null &&
        oldWidget.activeHighlightId == oldWidget.highlightId;
    if (_isHighlighted && !wasHighlighted) {
      _scheduleEnsureVisible();
    }
  }

  void _scheduleEnsureVisible() {
    if (!widget.ensureVisible || !_isHighlighted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isHighlighted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: TutorialHighlight.shouldAnimate()
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        curve: Curves.easeInOut,
      );
    });
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 240), () {
      if (!mounted || !_isHighlighted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: TutorialHighlight.shouldAnimate()
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHighlighted) {
      return widget.child;
    }
    return TutorialPulseBuilder(
      enabled: true,
      builder: (context, pulse) {
        return DecoratedBox(
          key: ValueKey('highlight-${widget.highlightId}'),
          position: widget.foreground
              ? DecorationPosition.foreground
              : DecorationPosition.background,
          decoration: TutorialHighlight.buildPulseDecoration(
            context,
            pulse,
            foreground: widget.foreground,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Renders an animated tutorial highlight directly on the spacetime canvas for
/// a specific [Drawable] (`canvas.object`) or recommended [Point] (`canvas.point`).
class TutorialCanvasOverlay extends StatelessWidget {
  final SceneView scene;
  final TutorialController controller;
  final Widget child;

  const TutorialCanvasOverlay({
    super.key,
    required this.scene,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, scene.repaintCounter]),
      builder: (context, _) {
        final highlightId = controller.currentHighlightId;
        final targetDrawable = controller.highlightedDrawable;
        final targetPoint = controller.highlightedPoint;

        if (highlightId == 'canvas.main') {
          return TutorialHighlight(
            highlightId: 'canvas.main',
            activeHighlightId: highlightId,
            foreground: true,
            borderRadius: BorderRadius.zero,
            child: child,
          );
        }

        final hasObjectHighlight =
            highlightId == 'canvas.object' && targetDrawable != null;
        final hasPointHighlight =
            highlightId == 'canvas.point' && targetPoint != null;

        if (!hasObjectHighlight && !hasPointHighlight) {
          return child;
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final accentColor = isDark
            ? Colors.amberAccent.shade400
            : Colors.deepOrangeAccent.shade400;

        return TutorialPulseBuilder(
          enabled: true,
          builder: (context, pulse) {
            return CustomPaint(
              key: ValueKey('highlight-$highlightId'),
              foregroundPainter: _TutorialCanvasHighlightPainter(
                scene: scene,
                targetDrawable: targetDrawable,
                targetPoint: targetPoint,
                accentColor: accentColor,
                pulse: pulse,
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}

class _TutorialCanvasHighlightPainter extends CustomPainter {
  final SceneView scene;
  final Drawable? targetDrawable;
  final Point? targetPoint;
  final Color accentColor;
  final double pulse;

  _TutorialCanvasHighlightPainter({
    required this.scene,
    required this.targetDrawable,
    required this.targetPoint,
    required this.accentColor,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = pulse.clamp(0.0, 1.0);
    if (p <= 0.01) return;

    final transform = scene.data.transform;

    if (targetDrawable != null) {
      final glowPaint = targetDrawable!.getHighlightPaint(accentColor, p);
      targetDrawable!.paintHighlight(canvas, transform, glowPaint);

      final corePaint = Paint()
        ..color = accentColor.withValues(alpha: p)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = SceneView.lineWidth.value * (1.8 + 1.2 * p);
      targetDrawable!.paintHighlight(canvas, transform, corePaint);
    }

    if (targetPoint != null) {
      final c = transform.toScreen(targetPoint!);
      final baseRadius = SceneView.dotSize.value + 6.0;
      final outerRadius = baseRadius + 8.0 * p;

      final fillPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.25 * p)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(c, outerRadius, fillPaint);

      if (p > 0.05) {
        final glowPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.7 * p)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 * p
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * p);
        canvas.drawCircle(c, outerRadius, glowPaint);
      }

      final ringPaint = Paint()
        ..color = accentColor.withValues(alpha: p)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(c, baseRadius + 4.0 * p, ringPaint);

      final crossPaint = Paint()
        ..color = accentColor.withValues(alpha: p)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;
      const double arm = 5.0;
      canvas.drawLine(
        c + const Offset(-arm, 0),
        c + const Offset(arm, 0),
        crossPaint,
      );
      canvas.drawLine(
        c + const Offset(0, -arm),
        c + const Offset(0, arm),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TutorialCanvasHighlightPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.targetDrawable != targetDrawable ||
        oldDelegate.targetPoint != targetPoint ||
        oldDelegate.accentColor != accentColor;
  }
}
