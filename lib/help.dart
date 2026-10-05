import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart' show rootBundle;
import 'webview_stub.dart' if (dart.library.html) 'webview_web.dart';

import "printer.dart";
import 'settings.dart';
import 'navigation.dart';

class HelpScreen extends StatefulWidget {
  final Settings settings;
  final String initialPage;
  static const routeName = "/help";
  const HelpScreen(this.settings, {this.initialPage = "about.html", super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late final WebViewController webViewController;
  double progress = 0;
  String _currentFilename = "about.html";
  bool _isMenuOpen = false;
  Brightness? _lastLoadedBrightness;
  late final StreamSubscription<SettingsStatus> _settingsListener;

  @override
  void initState() {
    super.initState();
    _currentFilename = widget.initialPage;
    if (kIsWeb) {
      initWebviewPlatform();
    }
    webViewController = WebViewController();
    try {
      webViewController.setBackgroundColor(
        widget.settings.theme.theme_data.colorScheme.surface,
      );
    } catch (e) {
      // Ignored if unsupported on the platform/test environment
    }
    if (!kIsWeb) {
      NavigationDelegate delegate;
      try {
        delegate = NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              this.progress = progress / 100.0;
            });
          },
          onPageFinished: (String url) {
            _applyTheme();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("http")) {
              launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        );
      } catch (e) {
        delegate = NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              this.progress = progress / 100.0;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith("http")) {
              launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        );
      }
      webViewController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(delegate);
    }
    _settingsListener = widget.settings.statusStream().listen((status) {
      if (mounted) {
        setState(() {});
        _checkAndReloadTheme();
      }
    });
    loadHelpFile(_currentFilename);
  }

  @override
  void dispose() {
    _settingsListener.cancel();
    super.dispose();
  }

  void _applyTheme() {
    bool isDark = widget.settings.theme.scheme.brightness == Brightness.dark;
    String js = isDark
        ? "document.documentElement.classList.add('dark-theme'); document.documentElement.classList.remove('light-theme');"
        : "document.documentElement.classList.add('light-theme'); document.documentElement.classList.remove('dark-theme');";
    webViewController.runJavaScript(js).catchError((e) {
      Log.help.log("Error injecting theme JS: $e");
    });
  }

  void _checkAndReloadTheme() {
    final currentBrightness = widget.settings.theme.scheme.brightness;
    if (_lastLoadedBrightness != currentBrightness) {
      try {
        webViewController.setBackgroundColor(
          widget.settings.theme.theme_data.colorScheme.surface,
        );
      } catch (e) {}
      loadHelpFile(_currentFilename);
      _applyTheme();
    }
  }

  @override
  void didUpdateWidget(HelpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage) {
      _currentFilename = widget.initialPage;
      loadHelpFile(_currentFilename);
    }
  }

  void loadHelpFile(String filename) async {
    _lastLoadedBrightness = widget.settings.theme.scheme.brightness;
    try {
      String htmlContent;
      String cssContent;
      if (kIsWeb) {
        final versionTag =
            '${widget.settings.version}+${widget.settings.build_number}';
        final htmlUri = Uri.parse('assets/assets/$filename?v=$versionTag');
        final cssUri = Uri.parse(
          'assets/assets/css/doc_style.css?v=$versionTag',
        );

        final htmlResponse = await http.get(htmlUri);
        final cssResponse = await http.get(cssUri);

        if (htmlResponse.statusCode == 200) {
          htmlContent = htmlResponse.body;
        } else {
          htmlContent = await rootBundle.loadString('assets/$filename');
        }

        if (cssResponse.statusCode == 200) {
          cssContent = cssResponse.body;
        } else {
          cssContent = await rootBundle.loadString('assets/css/doc_style.css');
        }

        // Scan HTML content for embedded version string (e.g., "v2.1.0+70").
        // If the document version is older than current version, perform a forced reload.
        final versionMatch = RegExp(
          r'\(v(\d+\.\d+\.\d+\+\d+)\)',
        ).firstMatch(htmlContent);
        if (versionMatch != null) {
          final embeddedVersion = versionMatch.group(1);
          if (embeddedVersion != null &&
              embeddedVersion != versionTag &&
              embeddedVersion != widget.settings.version) {
            final cacheBuster = DateTime.now().millisecondsSinceEpoch;
            final forcedResponse = await http.get(
              Uri.parse('assets/assets/$filename?nocache=$cacheBuster'),
              headers: {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache',
              },
            );
            if (forcedResponse.statusCode == 200) {
              htmlContent = forcedResponse.body;
            }
          }
        }
      } else {
        htmlContent = await rootBundle.loadString('assets/$filename');
        cssContent = await rootBundle.loadString('assets/css/doc_style.css');
      }

      // Clean up any <pre class="mermaid"><code> blocks to prevent Mermaid syntax error.
      final mermaidRegExp = RegExp(
        r'<pre class="mermaid"><code>([\s\S]*?)</code></pre>',
      );
      htmlContent = htmlContent.replaceAllMapped(mermaidRegExp, (match) {
        return '<pre class="mermaid">${match.group(1)}</pre>';
      });

      // Replace stylesheet link with inlined CSS to avoid relative path loading issues on web and mobile.
      final linkRegExp = RegExp(
        r'''<link\s+rel=["']stylesheet["']\s+href=["'][^"']*doc_style\.css["']\s*/?>''',
      );
      if (htmlContent.contains(linkRegExp)) {
        htmlContent = htmlContent.replaceFirst(
          linkRegExp,
          '<style>$cssContent</style>',
        );
      } else if (htmlContent.contains('</head>')) {
        htmlContent = htmlContent.replaceFirst(
          '</head>',
          '<style>$cssContent</style></head>',
        );
      } else {
        htmlContent = '<head><style>$cssContent</style></head>$htmlContent';
      }

      bool isDark = _lastLoadedBrightness == Brightness.dark;
      if (isDark) {
        // Change mermaid theme to dark.
        htmlContent = htmlContent.replaceFirst(
          "theme: 'default'",
          "theme: 'dark'",
        );
        htmlContent = htmlContent.replaceFirst(
          'theme: "default"',
          'theme: "dark"',
        );

        if (htmlContent.contains("<html")) {
          htmlContent = htmlContent.replaceFirst(
            "<html",
            "<html class=\"dark-theme\"",
          );
        } else if (htmlContent.contains("<body")) {
          htmlContent = htmlContent.replaceFirst(
            "<body",
            "<body class=\"dark-theme\"",
          );
        }
      } else {
        // Change mermaid theme to default.
        htmlContent = htmlContent.replaceFirst(
          "theme: 'dark'",
          "theme: 'default'",
        );
        htmlContent = htmlContent.replaceFirst(
          'theme: "dark"',
          'theme: "default"',
        );

        if (htmlContent.contains("<html")) {
          htmlContent = htmlContent.replaceFirst(
            "<html",
            "<html class=\"light-theme\"",
          );
        } else if (htmlContent.contains("<body")) {
          htmlContent = htmlContent.replaceFirst(
            "<body",
            "<body class=\"light-theme\"",
          );
        }
      }
      await webViewController.loadHtmlString(htmlContent);
    } catch (e) {
      Log.help.log("Error loading help file: $e");
    }
  }

  AppBar appBar(BuildContext context, {required bool isWideScreen}) {
    // Log.help.log("Building appbar.");
    return AppBar(
      title: Text((!isWideScreen && _isMenuOpen) ? "Help Menu" : "Help & Docs"),
      leading: isWideScreen
          ? null
          : IconButton(
              icon: Icon(_isMenuOpen ? Icons.close : Icons.menu),
              tooltip: _isMenuOpen ? "Close Menu" : "Open Menu",
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                });
              },
            ),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: "Settings",
          onPressed: () {
            context.push(SettingsScreen.routeName);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: "Close",
          onPressed: () {
            // Log.help.log("CYAN: help close.");
            popOrHome(context);
          },
        ),
      ],
    );
  }

  Widget buildNavigationList(BuildContext context, {required bool isSidebar}) {
    List<Widget> items = [
      if (isSidebar) ...[
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
          child: Text(
            "Spacetime Help",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
      ] else ...[
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                "Spacetime Help",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Documentation & Guides",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      const Padding(
        padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
        child: Text(
          "User Guides",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
      buildDrawerItem(
        context,
        "About Spacetime",
        "about.html",
        Icons.info_outline,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        "Overview",
        "overview.html",
        Icons.visibility_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        "Toolbar and Sliders",
        "controls.html",
        Icons.tune,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        "Spacetime Objects",
        "objects.html",
        Icons.category_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        "Relativistic Transformations",
        "transformations.html",
        Icons.transform,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        "File Management",
        "files.html",
        Icons.folder_open_outlined,
        isSidebar: isSidebar,
      ),
    ];
    if (Settings.kDebugEnabled && Settings.debugEnabled) {
      items.addAll([
        const Divider(),
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            "Developer Docs",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        buildDrawerItem(
          context,
          "Readme",
          "dev/README.html",
          Icons.description_outlined,
          isSidebar: isSidebar,
        ),
        buildDrawerItem(
          context,
          "Developer Guide",
          "dev/GEMINI.html",
          Icons.code_outlined,
          isSidebar: isSidebar,
        ),
        buildDrawerItem(
          context,
          "Project Plan",
          "dev/plan.html",
          Icons.assignment_outlined,
          isSidebar: isSidebar,
        ),
      ]);
    }
    return ListView(padding: EdgeInsets.zero, children: items);
  }

  Widget buildDrawerItem(
    BuildContext context,
    String title,
    String filename,
    IconData icon, {
    required bool isSidebar,
  }) {
    final isSelected = _currentFilename == filename;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (!isSidebar) {
          setState(() {
            _isMenuOpen = false;
          });
        }
        setState(() {
          _currentFilename = filename;
        });
        loadHelpFile(filename);
      },
    );
  }

  Widget webview(BuildContext c) {
    return WebViewWidget(controller: webViewController);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.settings.theme.theme_data,
      child: Builder(
        builder: (BuildContext context) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final bool isWideScreen = screenWidth > 750;
          return Scaffold(
            appBar: appBar(context, isWideScreen: isWideScreen),
            body: SafeArea(
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 280,
                          child: Material(
                            color: Theme.of(context).cardColor,
                            child: buildNavigationList(
                              context,
                              isSidebar: true,
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 1),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Builder(
                                      builder: (BuildContext c) =>
                                          webview(context),
                                    ),
                                    progress < 1.0
                                        ? LinearProgressIndicator(
                                            value: progress,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : (_isMenuOpen
                        ? Material(
                            color: Theme.of(context).cardColor,
                            child: buildNavigationList(
                              context,
                              isSidebar: false,
                            ),
                          )
                        : Column(
                            children: <Widget>[
                              Expanded(
                                child: Stack(
                                  children: [
                                    Builder(
                                      builder: (BuildContext c) =>
                                          webview(context),
                                    ),
                                    progress < 1.0
                                        ? LinearProgressIndicator(
                                            value: progress,
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ],
                          )),
            ),
          );
        },
      ),
    );
  }
}
