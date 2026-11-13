import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../animate.dart';
import '../edit.dart';
import '../file_manager.dart';
import '../js_stub.dart' if (dart.library.html) '../js_interface.dart';
import '../keyboard_detector.dart';
import '../l10n/l10n_extension.dart';
import '../menus.dart';
import '../navigation.dart';
import '../printer.dart';
import '../scene.dart';
import '../script.dart';
import '../settings.dart';
import '../slider.dart';
import '../splitter.dart';
import '../tutorial_widget.dart';
import 'tap_to_edit.dart';

class AppWidget extends StatefulWidget {
  final Settings settings;
  final SceneView sceneViewer;
  final FileManager fileManager;
  final MyUndoManager undoManager;
  final MyMenu fileMenu;
  final MyMenu tutorialMenu;
  final EditMenu editMenu;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'AppWidget-$_debugId';

  AppWidget(this.sceneViewer, this.settings, this.fileManager, {super.key})
    : undoManager = sceneViewer.undoManager,
      fileMenu = fileManager.makeMenu(),
      tutorialMenu = fileManager.makeTutorialMenu(),
      editMenu = EditMenu(sceneViewer, sceneViewer.undoManager);

  @override
  State<AppWidget> createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget>
    with SingleTickerProviderStateMixin {
  final MyMenu viewMenu = MyMenu('View');
  final MyShortcutManager shortcutManager = MyShortcutManager();
  late final MyAnimator animator;
  BoxConstraints _constraints = const BoxConstraints();
  bool _narrow = false;

  late final Timer _debugTimer;
  int _timerCounter = 0;
  int _buildCount = 0;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'WState-$_debugId for $widget';

  AppWidgetState();

  static SavableBool debugLogs = SavableBool(
    'debug_logs',
    'Periodic Debug Logs',
    false,
    tip: 'Print some debug logs to the console.',
    debugOnly: true,
  );

  late final StreamSubscription _settingsListener;

  void updateSettings() {
    widget.sceneViewer.updateSettings();
  }

  @override
  void initState() {
    super.initState();
    _settingsListener = widget.settings.statusStream().listen((status) {
      updateSettings();
      if (mounted) setState(() {});
    });
    animator = MyAnimator(this, widget.sceneViewer);
    _setupSceneViewer();
    KeyboardDetector.init();
    KeyboardDetector.hasKeyboard.addListener(_onKeyboardChanged);
    LocaleController.currentLocale.addListener(_onLocaleChanged);
    HardwareKeyboard.instance.addHandler(keyHandler);
  }

  void _setupSceneViewer() {
    widget.sceneViewer.startAnimation = startAnimation;
    widget.sceneViewer.time.startAnimation = startAnimation;
    _debugTimer = makeTimer();
    widget.sceneViewer.lightSpeed.addListener(updateLayout);
    widget.sceneViewer.currentName.addListener(updateLayout);
    widget.sceneViewer.currentType.addListener(updateLayout);
    widget.sceneViewer.currentColor.addListener(updateLayout);
    widget.sceneViewer.currentTool.addListener(updateLayout);
    viewMenu.items = [
      for (var s in widget.sceneViewer.lightSpeed.makeItems()) s,
      MyMenuItem(
        'Fit Scene',
        callback: () => setState(() => widget.sceneViewer.fitViewAndUpdate()),
      ),
    ];
    shortcutManager.clear();
    shortcutManager.add(widget.fileMenu);
    shortcutManager.add(widget.tutorialMenu);
    shortcutManager.add(widget.editMenu);
    shortcutManager.add(viewMenu);
    shortcutManager.add(widget.sceneViewer.lightSpeed);
    shortcutManager.add(widget.sceneViewer.currentTool);
    shortcutManager.add(widget.sceneViewer.currentType);
    shortcutManager.add(widget.sceneViewer.currentColor);
  }

  void _cleanupSceneViewer(SceneView oldViewer) {
    _debugTimer.cancel();
    oldViewer.lightSpeed.removeListener(updateLayout);
    oldViewer.currentName.removeListener(updateLayout);
    oldViewer.currentType.removeListener(updateLayout);
    oldViewer.currentColor.removeListener(updateLayout);
    oldViewer.currentTool.removeListener(updateLayout);
  }

  @override
  void didUpdateWidget(AppWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sceneViewer != widget.sceneViewer) {
      _cleanupSceneViewer(oldWidget.sceneViewer);
      animator.dispose();
      animator = MyAnimator(this, widget.sceneViewer);
      _setupSceneViewer();
    }
  }

  void updateLayout() {
    setState(() {});
  }

  Timer makeTimer() {
    return Timer.periodic(const Duration(seconds: 5), (timer) {
      if (debugLogs.value) {
        _timerCounter++;
        Log.widget.log(
          '$_timerCounter, b$_buildCount, ${widget.sceneViewer.debugPrint()}${animator.debugPrint()}',
        );
      }
    });
  }

  void startAnimation() {
    Log.widget.log('GREEN: Widget heard startAnimation.');
    animator.play();
  }

  @override
  void dispose() {
    _settingsListener.cancel();
    KeyboardDetector.hasKeyboard.removeListener(_onKeyboardChanged);
    LocaleController.currentLocale.removeListener(_onLocaleChanged);
    HardwareKeyboard.instance.removeHandler(keyHandler);
    animator.dispose();
    _cleanupSceneViewer(widget.sceneViewer);
    super.dispose();
  }

  void _onKeyboardChanged() {
    widget.fileMenu.rebuild();
    widget.tutorialMenu.rebuild();
    widget.editMenu.rebuild();
    viewMenu.rebuild();
    if (mounted) {
      setState(() {});
    }
  }

  void _onLocaleChanged() {
    widget.fileManager.makeTutorialMenu(widget.tutorialMenu);
    if (mounted) {
      setState(() {});
    }
  }

  bool keyHandler(KeyEvent event) {
    KeyboardDetector.onKeyEvent(event);
    if (widget.sceneViewer.keyHandle(event.character, event.logicalKey)) {
      setState(() {
        Log.widget.log('Key state changed.');
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    Widget center = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints != _constraints) {
          _narrow = false;
          _constraints = constraints;
        }
        return ValueListenableBuilder<Locale?>(
          valueListenable: LocaleController.currentLocale,
          builder: (context, currentLocale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: currentLocale,
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale != null) {
                  for (final supported in supportedLocales) {
                    if (supported.languageCode == deviceLocale.languageCode &&
                        (deviceLocale.countryCode == null ||
                            supported.countryCode == null ||
                            supported.countryCode ==
                                deviceLocale.countryCode)) {
                      return supported;
                    }
                  }
                  for (final supported in supportedLocales) {
                    if (supported.languageCode == deviceLocale.languageCode) {
                      return supported;
                    }
                  }
                }
                return const Locale('en');
              },
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: widget.settings.theme.themeData,
              builder: (context, child) {
                final mediaQueryData = MediaQuery.of(context);
                final browserFontSize = getBrowserRootFontSize();
                final scaleFactor = browserFontSize / 16.0;
                final textScaler = scaleFactor != 1.0
                    ? TextScaler.linear(scaleFactor)
                    : mediaQueryData.textScaler;
                return MediaQuery(
                  data: mediaQueryData.copyWith(textScaler: textScaler),
                  child: child!,
                );
              },
              home: PopScope(
                canPop: !widget.fileManager.unsaved.value,
                onPopInvokedWithResult: (bool didPop, Object? result) async {
                  if (didPop) return;
                  bool saved = await widget.fileManager.checkSave(context);
                  if (saved && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Scaffold(
                  appBar: makeAppBar(context),
                  drawer: Builder(
                    builder: (BuildContext c) => makeMenuDrawer(c),
                  ),
                  body: SafeArea(
                    child: Center(
                      child: Builder(builder: (BuildContext c) => _mainBody(c)),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return shortcutManager.build(context, center);
  }

  AppBar makeAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return _wrapTutorialHighlight(
            'menu.light_speed',
            IconButton(
              key: const ValueKey('drawer-menu-btn'),
              icon: const Icon(Icons.menu),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          );
        },
      ),
      title: _sceneTitle(context),
      actions: _getButtons(context),
    );
  }

  Widget _sceneTitle(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        var tp = TextPainter(
          ellipsis: null,
          maxLines: 1,
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: widget.sceneViewer.data.title,
            style: const TextStyle(overflow: TextOverflow.visible),
          ),
        );
        tp.layout(maxWidth: size.maxWidth);
        var exceeded = tp.didExceedMaxLines;
        if (exceeded) {
          if (!_narrow) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _narrow = true;
              });
            });
          }
        }
        tp.dispose();
        return TapToEditText(
          'Title',
          key: const ValueKey('title_text_view'),
          widget.sceneViewer.data.title,
          widget.undoManager,
          (value) {
            if (widget.sceneViewer.data.title != value) {
              widget.undoManager.add(
                Change<String>('Title', widget.sceneViewer.data.title, value, (
                  v,
                ) {
                  setState(() {
                    widget.sceneViewer.data.title = v;
                    widget.fileManager.current.holder.title = v;
                    widget.fileManager.unsaved.value = true;
                  });
                }),
              );
            }
          },
        );
      },
    );
  }

  Widget _languageButton(BuildContext context) {
    final l10n = context.l10n;
    final current = LocaleController.currentLocale.value;
    return PopupMenuButton<Locale>(
      key: const ValueKey('languageSwitcherButton'),
      icon: const Icon(Icons.language_rounded),
      tooltip: l10n.language,
      initialValue: current ?? LocaleController.autoLocale,
      onSelected: (locale) {
        LocaleController.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        CheckedPopupMenuItem<Locale>(
          value: LocaleController.autoLocale,
          checked: current == null,
          child: Text(l10n.systemDefault),
        ),
        for (final locale in LocaleController.supportedLocales)
          CheckedPopupMenuItem<Locale>(
            value: locale,
            checked: current == locale,
            child: Text(LocaleController.languageDisplayName(locale)),
          ),
      ],
    );
  }

  Widget _settingsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Scaffold.of(context).closeDrawer();
        context.push(SettingsScreen.routeName);
      },
      icon: const Icon(Icons.settings),
      tooltip: context.l10n.settings,
    );
  }

  Widget _helpButton(BuildContext context) {
    final l10n = context.l10n;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.help),
      tooltip: l10n.helpOptions,
      onSelected: (String route) {
        context.push(route);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '/about',
          child: Text('${l10n.aboutSpacetime} v${widget.settings.fullVersion}'),
        ),
        PopupMenuItem<String>(
          value: '/help?page=overview.html',
          child: Text(l10n.helpAndUserGuides),
        ),
        if (Settings.kDebugEnabled && Settings.debugEnabled)
          PopupMenuItem<String>(
            value: '/help?page=dev/README.html',
            child: Text(l10n.developerDocs),
          ),
      ],
    );
  }

  Drawer makeMenuDrawer(BuildContext context) {
    return Drawer(
      child: ValueListenableBuilder<TutorialController?>(
        valueListenable: widget.fileManager.activeTutorial,
        builder: (context, controller, _) {
          return ListenableBuilder(
            listenable: Listenable.merge([?controller, viewMenu]),
            builder: (context, _) {
              final highlightLightSpeed =
                  controller?.currentHighlightId == 'menu.light_speed';
              final targetMode = controller?.targetLightSpeed;
              final highlightViewHeader =
                  highlightLightSpeed && !viewMenu.isExpanded;
              return ListView(
                // ignore: deprecated_member_use
                cacheExtent: 2000,
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Row(
                    children: [
                      IconButton(
                        key: const ValueKey('closeDrawerButton'),
                        icon: const Icon(Icons.close),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.sceneViewer.data.title,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _languageButton(context),
                      Text(context.l10n.language),
                    ],
                  ),
                  Row(
                    children: [
                      _settingsButton(context),
                      Text(context.l10n.settings),
                    ],
                  ),
                  widget.fileMenu.buildDrawerList(context),
                  widget.tutorialMenu.buildDrawerList(context),
                  widget.editMenu.buildDrawerList(context),
                  viewMenu.buildDrawerList(
                    context,
                    null,
                    (context, tileWidget) {
                      return TutorialHighlight(
                        highlightId: 'menu.light_speed.view',
                        activeHighlightId: highlightViewHeader
                            ? 'menu.light_speed.view'
                            : null,
                        ensureVisible: true,
                        child: tileWidget,
                      );
                    },
                    (context, item, itemWidget) {
                      final isTargetItem =
                          highlightLightSpeed &&
                          viewMenu.isExpanded &&
                          item is RadioItem &&
                          item.item == targetMode;
                      return TutorialHighlight(
                        highlightId: 'menu.light_speed.${item.name}',
                        activeHighlightId: isTargetItem
                            ? 'menu.light_speed.${item.name}'
                            : null,
                        ensureVisible: true,
                        child: itemWidget,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget makeMenuBar(BuildContext context) {
    return MenuBar(
      children: <Widget>[
        widget.fileMenu.build(context),
        widget.tutorialMenu.build(context),
        widget.editMenu.build(context),
        viewMenu.build(context),
      ],
    );
  }

  Widget _wrapTutorialHighlight(
    String highlightId,
    Widget child, {
    bool foreground = false,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  }) {
    return ValueListenableBuilder<TutorialController?>(
      valueListenable: widget.fileManager.activeTutorial,
      builder: (context, controller, _) {
        if (controller == null) return child;
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return TutorialHighlight(
              highlightId: highlightId,
              activeHighlightId: controller.currentHighlightId,
              foreground: foreground,
              borderRadius: borderRadius,
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _wrapCanvasTutorialHighlight(Widget child, {bool side = false}) {
    return ValueListenableBuilder<TutorialController?>(
      valueListenable: widget.fileManager.activeTutorial,
      builder: (context, controller, _) {
        if (controller == null) return child;
        return TutorialCanvasOverlay(
          scene: widget.sceneViewer,
          controller: controller,
          side: side,
          child: child,
        );
      },
    );
  }

  List<Widget> _toolButtons(BuildContext context) {
    return [
      _wrapTutorialHighlight(
        'tool.mode',
        widget.sceneViewer.currentTool.build(context),
      ),
      _wrapTutorialHighlight(
        'tool.name',
        TapToEditText(
          'Object Name',
          key: const ValueKey('object_name'),
          widget.sceneViewer.currentName.value,
          widget.undoManager,
          (value) => setState(() {
            widget.sceneViewer.currentName.value = value;
          }),
        ),
      ),
      _wrapTutorialHighlight(
        'tool.type',
        widget.sceneViewer.currentType.build(context),
      ),
      _wrapTutorialHighlight(
        'tool.color',
        widget.sceneViewer.currentColor.build(context),
      ),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton('DumpDebug', Icons.info, () {
          setState(() {
            Log.widget.log('-dump debug set state-');
          });
          Log.dump.log('-------------- dumpDebugInfo from $this');
          Log.includeVerbose = true;
          DebugPrint.printDebug = 1;
          widget.sceneViewer.dumpDebugInfo();
          widget.fileManager.dumpDebugInfo();
          dumpNavigator(context, 'DumpDebug');
        }),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton('StopDebug', Icons.exit_to_app, () {
          setState(() {
            Log.dump.log('Turing off debug print.');
            Log.includeVerbose = false;
            DebugPrint.printDebug = 0;
          });
        }),
      if (Settings.kDebugEnabled && Settings.debugEnabled)
        _makeButton('check exit', Icons.error, () {
          widget.fileManager.checkSave(context).then((bool result) {
            if (result) {
              Log.widget.log('Check Save returns true.');
            } else {
              Log.widget.log('Check Save returns false.');
            }
          });
        }),
    ];
  }

  bool _isNarrow(BuildContext context) =>
      _narrow || MediaQuery.sizeOf(context).width < 700;

  List<Widget> _getButtons(BuildContext context) {
    List<Widget> list = [];
    if (!_isNarrow(context)) list.addAll(_toolButtons(context));
    list.add(_languageButton(context));
    list.add(_helpButton(context));
    return list;
  }

  Widget _makeButton(String tip, IconData data, VoidCallback callback) {
    return IconButton(icon: Icon(data), tooltip: tip, onPressed: callback);
  }

  Widget _mainBody(BuildContext context) {
    final isNarrow = _isNarrow(context);
    return Column(
      children: [
        if (isNarrow)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _toolButtons(context)),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SplitterWidget(
                    top: (context) => Semantics(
                      label: context.l10n.semanticsSpacetimeCanvas,
                      child: _wrapCanvasTutorialHighlight(
                        widget.sceneViewer.build(context, this),
                        side: false,
                      ),
                    ),
                    bottom: (context) => Semantics(
                      label: context.l10n.semanticsObserverCanvas,
                      child: _wrapCanvasTutorialHighlight(
                        widget.sceneViewer.buildSideView(context, this),
                        side: true,
                      ),
                    ),
                    setter: (double x) {
                      widget.sceneViewer.data.transform.sideHeight = x;
                    },
                    initialSize: 80,
                    background: widget.settings.backgroundColor,
                    outline: widget.settings.theme.scheme.secondary,
                  ),
                  ValueListenableBuilder<TutorialController?>(
                    valueListenable: widget.fileManager.activeTutorial,
                    builder: (context, controller, child) {
                      if (controller == null) return const SizedBox.shrink();
                      final maxCardHeight = (constraints.maxHeight - 32.0)
                          .clamp(200.0, 420.0);
                      return Positioned(
                        top: 16,
                        right: 16,
                        child: TutorialCard(
                          controller: controller,
                          maxHeight: maxCardHeight,
                          onClose: widget.fileManager.closeTutorial,
                          onFinish: widget.fileManager.finishTutorial,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        ValueListenableBuilder<TutorialController?>(
          valueListenable: widget.fileManager.activeTutorial,
          builder: (context, controller, child) {
            return AnimatedBuilder(
              animation: controller ?? Listenable.merge([]),
              builder: (context, _) {
                final highlightId = controller?.currentHighlightId;
                final isSliderHighlighted =
                    highlightId == 'slider.velocity' ||
                    highlightId == 'slider.time';
                return TutorialPulseBuilder(
                  enabled: isSliderHighlighted,
                  builder: (context, pulse) {
                    return MySlider.buildTable(
                      context,
                      [widget.sceneViewer.time, widget.sceneViewer.velocity],
                      highlightId: highlightId,
                      highlightPulse: pulse,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
