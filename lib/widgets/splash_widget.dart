import 'dart:async';
import 'package:flutter/material.dart';

import '../drive.dart';
import '../file_manager.dart';
import '../js_stub.dart' if (dart.library.html) '../js_interface.dart';
import '../navigation.dart';
import '../printer.dart';
import '../scene.dart';
import '../settings.dart';
import '../sprites.dart';
import 'app_widget.dart';
import 'json_syntax_dialog.dart';

/// A widget used to wrap a splash screen during initialization or an app widget
/// after initialization.
class SplashWidget extends StatefulWidget {
  final Settings settings;
  final FileManager fileManager;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'Splash-$_debugId';

  SplashWidget(this.settings, this.fileManager, {super.key}) {
    Log.widget.log('MAGENTA: Create new $this.');
  }

  @override
  State<SplashWidget> createState() {
    return SplashWidgetState();
  }
}

class SplashWidgetState extends State<SplashWidget>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _settingsListener;
  late StreamSubscription _fileListener;
  late StreamSubscription _driveListener;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'SState-$_debugId for $widget';

  SplashWidgetState();

  @override
  void initState() {
    super.initState();
    removeSplashFromWeb();
    _settingsListener = widget.settings.statusStream().listen((status) {
      SceneData.version = widget.settings.version;
      if (mounted) setState(() {});
    });
    _fileListener = widget.fileManager.statusStream().listen((status) {
      if (mounted) setState(() {});
    });
    _driveListener = widget.fileManager.driveAccess.statusStream().listen((
      status,
    ) {
      if (mounted &&
          status == DriveAccessStatus.authorized &&
          widget.fileManager.current.holder is DriveHolder &&
          widget.fileManager.status == LoadingStatus.error) {
        widget.fileManager.reload();
      } else if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(SplashWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    removeSplashFromWeb();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settingsListener.cancel();
    _fileListener.cancel();
    _driveListener.cancel();
    super.dispose();
  }

  Widget splashText(BuildContext context, String s) {
    removeSplashFromWeb();
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: widget.fileManager.isTesting ? 0.5 : null,
            ),
            const SizedBox(height: 20),
            Text(
              s,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _buildCount = 0;
  @override
  Widget build(BuildContext context) {
    _buildCount++;
    Log.widget.log(
      'ORANGE: build $this, c=$_buildCount '
      '${widget.fileManager.current}, '
      'status=${widget.fileManager.status}'
      ', v${widget.settings.version}.${widget.settings.buildNumber}',
    );
    Log.widget.log(
      'ORANGE: settings=${widget.settings.status}, '
      'sprites=${Sprite.initialized}',
    );
    widget.fileManager.setContext('Widget $this, $_buildCount', context);
    Widget center;
    if (widget.settings.status == SettingsStatus.notInitialized) {
      Log.widget.log('MAGENTA: splash settings.');
      widget.settings.initialize(context);
      Sprite.initialize(context, widget.settings);
      center = splashText(context, 'Initializing Settings...');
    } else if (!Sprite.initialized) {
      Log.widget.log('MAGENTA: splash sprites.');
      center = splashText(context, 'Initializing Sprites...');
    } else if (widget.fileManager.status == LoadingStatus.notInitialized) {
      Log.widget.log('MAGENTA: splash file manager.');
      center = splashText(context, 'Initializing file access...');
    } else if (widget.fileManager.status == LoadingStatus.error) {
      Log.widget.log('MAGENTA: splash error.');
      center = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          splashText(
            context,
            'Error Loading '
            '${widget.fileManager.current.holder.userDescription()}',
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: ExpansionTile(
                key: const ValueKey('expand_load_error_details'),
                title: const Text(
                  'Expand Error Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      widget.fileManager.exception?.toString() ??
                          'Unknown load error',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.fileManager.current.holder is DriveHolder &&
              widget.fileManager.driveAccess.status !=
                  DriveAccessStatus.authorized) ...[
            ElevatedButton.icon(
              key: const ValueKey('drive_sign_in_button'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In to Google Drive'),
              onPressed: () async {
                bool authorized = await widget.fileManager.driveAccess
                    .getAuthorization(context);
                if (authorized && mounted) {
                  setState(() {
                    widget.fileManager.reload();
                  });
                }
              },
            ),
            const SizedBox(height: 8),
          ] else ...[
            ElevatedButton(
              key: const ValueKey('edit_json_syntax_button'),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (c) =>
                      JsonSyntaxEditorDialog(fileManager: widget.fileManager),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
              child: const Text('Edit JSON Syntax'),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () => setState(() {
              widget.fileManager.popCurrentFile(context);
            }),
            child: Text('Go back to ${widget.fileManager.previous}'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.fileManager.makeNew();
              });
            },
            child: const Text('Open empty scene'),
          ),
        ],
      );
    } else if (widget.fileManager.status != LoadingStatus.loaded) {
      Log.widget.log('MAGENTA: splash file loading.');
      center = splashText(context, 'Loading...');
    } else if (widget.fileManager.current.scene == null) {
      Log.widget.log('MAGENTA: splash scene viewer is null.');
      center = splashText(context, 'BUG: scene view is null');
    } else {
      center = AppWidget(
        widget.fileManager.current.scene!,
        widget.settings,
        widget.fileManager,
        key: ObjectKey(widget.fileManager.current.scene!),
      );
      Log.widget.log('MAGENTA: splash scene for $this, scene_widget = $center');
      fixAddressBar(context, widget.fileManager.current.holder.path);
    }

    if (center is! AppWidget) {
      return Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16.0), child: center),
        ),
      );
    }

    return center;
  }
}
