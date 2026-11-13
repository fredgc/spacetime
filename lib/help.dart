import 'dart:async';
import 'dart:convert';
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
import 'l10n/l10n_extension.dart';
import 'navigation.dart';

class HelpScreen extends StatefulWidget {
  final Settings settings;
  final String initialPage;
  static const routeName = "/help";
  const HelpScreen(this.settings, {this.initialPage = "about.html", super.key});

  /// Decodes an HTTP response body as UTF-8 regardless of whether the server
  /// includes a `charset=utf-8` parameter in `Content-Type` (`response.body`
  /// defaults to Latin-1 when `charset` is omitted, corrupting UTF-8 smart
  /// quotes and localized text).
  static String decodeHttpResponse(http.Response response) {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  /// Prepares raw HTML documentation for display in the WebView.
  static String prepareHtmlContent(
    String htmlContent, {
    required String cssContent,
    required bool isDark,
    String? versionTag,
  }) {
    if (versionTag != null && versionTag.isNotEmpty) {
      htmlContent = htmlContent.replaceAll(
        RegExp(r'\{\{\s*VERSION\s*\}\}'),
        versionTag,
      );
    }

    // Ensure external links and /version5/ links open in the top browser tab/window
    // rather than inside the srcdoc iframe or triggering Flutter's SPA router.
    final anchorTargetRegExp = RegExp(
      r'<a\s+href="(https?://[^"]+|/version5/[^"]*)"(?![^>]*\btarget=)',
    );
    htmlContent = htmlContent.replaceAllMapped(anchorTargetRegExp, (match) {
      return '<a href="${match.group(1)}" target="_blank" rel="noopener"';
    });

    // Clean up any <pre class="mermaid"><code> blocks and unescape HTML entities
    // inside Mermaid source so quoted node labels and <br> tags parse cleanly.
    final mermaidRegExp = RegExp(
      r'<pre class="mermaid"><code>([\s\S]*?)</code></pre>',
    );
    htmlContent = htmlContent.replaceAllMapped(mermaidRegExp, (match) {
      final rawMermaid = (match.group(1) ?? '')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&');
      return '<pre class="mermaid">$rawMermaid</pre>';
    });

    if (htmlContent.contains('<pre class="mermaid">') &&
        !htmlContent.contains('mermaid.min.js')) {
      const mermaidScript =
          '<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>\n'
          "<script>mermaid.initialize({ startOnLoad: true, theme: 'default' });</script>";
      if (htmlContent.contains('</body>')) {
        htmlContent = htmlContent.replaceFirst(
          '</body>',
          '$mermaidScript\n</body>',
        );
      } else {
        htmlContent = '$htmlContent\n$mermaidScript';
      }
    }

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
    return htmlContent;
  }

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
        widget.settings.theme.themeData.colorScheme.surface,
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
    LocaleController.currentLocale.addListener(_onLocaleChanged);
    loadHelpFile(_currentFilename);
  }

  @override
  void dispose() {
    LocaleController.currentLocale.removeListener(_onLocaleChanged);
    _settingsListener.cancel();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      loadHelpFile(_currentFilename);
      setState(() {});
    }
  }

  Locale _resolveEffectiveLocale() {
    final active = LocaleController.currentLocale.value;
    if (active != null) return active;
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    for (final supported in LocaleController.supportedLocales) {
      if (supported.languageCode == systemLocale.languageCode &&
          (systemLocale.countryCode == null ||
              supported.countryCode == null ||
              supported.countryCode == systemLocale.countryCode)) {
        return supported;
      }
    }
    for (final supported in LocaleController.supportedLocales) {
      if (supported.languageCode == systemLocale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }

  String _resolveLocalizedFilename(String filename) {
    final cleanBase = filename.replaceAll(
      RegExp(r'_[a-z]{2}(?:_[a-z]{2})?\.html$'),
      '.html',
    );
    final locale = _resolveEffectiveLocale();
    if (cleanBase.endsWith('.html') && !cleanBase.startsWith('dev/')) {
      final base = cleanBase.substring(0, cleanBase.length - 5);
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        return '${base}_${locale.languageCode}_${locale.countryCode!.toLowerCase()}.html';
      }
      if (locale.languageCode != 'en') {
        return '${base}_${locale.languageCode}.html';
      }
    }
    return cleanBase;
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
          widget.settings.theme.themeData.colorScheme.surface,
        );
      } catch (e) {
        // Ignored on platforms not supporting setBackgroundColor.
      }
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
    final cleanBase = filename.replaceAll(
      RegExp(r'_[a-z]{2}(?:_[a-z]{2})?\.html$'),
      '.html',
    );
    _currentFilename = cleanBase;
    final localizedFilename = _resolveLocalizedFilename(cleanBase);
    try {
      String htmlContent;
      String cssContent;
      final versionTag =
          '${widget.settings.version}+${widget.settings.buildNumber}';
      if (kIsWeb) {
        var htmlUri = Uri.parse(
          'assets/assets/$localizedFilename?v=$versionTag',
        );
        final cssUri = Uri.parse(
          'assets/assets/css/doc_style.css?v=$versionTag',
        );

        var htmlResponse = await http.get(htmlUri);
        final cssResponse = await http.get(cssUri);

        if (htmlResponse.statusCode == 200) {
          htmlContent = HelpScreen.decodeHttpResponse(htmlResponse);
        } else if (localizedFilename != cleanBase) {
          htmlUri = Uri.parse('assets/assets/$cleanBase?v=$versionTag');
          htmlResponse = await http.get(htmlUri);
          if (htmlResponse.statusCode == 200) {
            htmlContent = HelpScreen.decodeHttpResponse(htmlResponse);
          } else {
            htmlContent = await rootBundle.loadString('assets/$cleanBase');
          }
        } else {
          htmlContent = await rootBundle.loadString('assets/$cleanBase');
        }

        if (cssResponse.statusCode == 200) {
          cssContent = HelpScreen.decodeHttpResponse(cssResponse);
        } else {
          cssContent = await rootBundle.loadString('assets/css/doc_style.css');
        }
      } else {
        try {
          htmlContent = await rootBundle.loadString(
            'assets/$localizedFilename',
          );
        } catch (_) {
          htmlContent = await rootBundle.loadString('assets/$cleanBase');
        }
        cssContent = await rootBundle.loadString('assets/css/doc_style.css');
      }

      htmlContent = HelpScreen.prepareHtmlContent(
        htmlContent,
        cssContent: cssContent,
        isDark: _lastLoadedBrightness == Brightness.dark,
        versionTag: versionTag,
      );
      await webViewController.loadHtmlString(htmlContent);
    } catch (e) {
      Log.help.log("Error loading help file: $e");
    }
  }

  AppBar appBar(BuildContext context, {required bool isWideScreen}) {
    final l10n = context.l10n;
    return AppBar(
      title: Text((!isWideScreen && _isMenuOpen) ? "Help Menu" : "Help & Docs"),
      leading: isWideScreen
          ? null
          : IconButton(
              icon: Icon(_isMenuOpen ? Icons.close : Icons.menu),
              tooltip: _isMenuOpen ? l10n.close : "Open Menu",
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
          tooltip: l10n.settings,
          onPressed: () {
            context.push(SettingsScreen.routeName);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.close,
          onPressed: () {
            popOrHome(context);
          },
        ),
      ],
    );
  }

  Widget buildNavigationList(BuildContext context, {required bool isSidebar}) {
    final l10n = context.l10n;
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
            children: [
              const Text(
                "Spacetime Help",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.helpDocumentationAndGuides,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
      Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
        child: Text(
          l10n.helpUserGuides,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
      buildDrawerItem(
        context,
        l10n.aboutSpacetime,
        "about.html",
        Icons.info_outline,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpOverview,
        "overview.html",
        Icons.visibility_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpControls,
        "controls.html",
        Icons.tune,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpObjects,
        "objects.html",
        Icons.category_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpTransformations,
        "transformations.html",
        Icons.transform,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpFiles,
        "files.html",
        Icons.folder_open_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpPrivacy,
        "privacy.html",
        Icons.privacy_tip_outlined,
        isSidebar: isSidebar,
      ),
      buildDrawerItem(
        context,
        l10n.helpTerms,
        "terms.html",
        Icons.gavel_outlined,
        isSidebar: isSidebar,
      ),
    ];
    if (Settings.kDebugEnabled && Settings.debugEnabled) {
      items.addAll([
        const Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            l10n.developerDocs,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        buildDrawerItem(
          context,
          l10n.helpReadme,
          "dev/README.html",
          Icons.description_outlined,
          isSidebar: isSidebar,
        ),
        buildDrawerItem(
          context,
          l10n.helpDeveloperGuide,
          "dev/GEMINI.html",
          Icons.code_outlined,
          isSidebar: isSidebar,
        ),
        buildDrawerItem(
          context,
          l10n.helpProjectPlan,
          "dev/plan.html",
          Icons.assignment_outlined,
          isSidebar: isSidebar,
        ),
        buildDrawerItem(
          context,
          "Tutorial Plan",
          "dev/tutorial_plan.html",
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
      data: widget.settings.theme.themeData,
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
