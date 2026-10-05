import 'dart:async';
import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'file_holder.dart';
import 'file_manager.dart';
import 'recent_file.dart';
import 'sign_in_button.dart';
import 'printer.dart';

class DriveHolder extends FileHolder {
  DriveHolder(super.id);

  static final String type_name = "drive";
  @override
  String get type => type_name;
  @override
  String get path => "/scene?drive=$id"; //XXX -- must agree with main::makeWidget.
  @override
  bool get skip_recent => false;
  static final String create_string = "_new_";

  File? file;

  factory DriveHolder.create() {
    return DriveHolder(create_string);
  }

  @override
  String userDescription() {
    // Displayed in "Recent files".
    return "$title (drive)";
  }

  @override
  Future<bool> saveData(String data, FileManager manager) async {
    Log.drive.log("PURPLE: Drive save $id");
    if (file == null && id != create_string) {
      Log.drive.log("saveData: getting file by id.");
      file = await manager.drive_access.getFileById(manager.context, id);
      if (file == null) return false;
    }
    String desc = "";
    try {
      Map<String, dynamic> json = jsonDecode(data);
      if (json.containsKey("description") && json["description"] is String) {
        desc = (json["description"] as String).trim();
      }
      if (json.containsKey("title") && json["title"] is String) {
        String jsonTitle = (json["title"] as String).trim();
        if (jsonTitle.isNotEmpty) {
          title = jsonTitle;
        }
      }
    } catch (_) {}

    String fullDesc = desc.isNotEmpty
        ? desc
        : "A spacetime diagram created with the Spacetime Drawing Tool.\nhttps://spacetime.gchouse.org";

    List<int> bytes = utf8.encode(data);
    Stream<List<int>> stream = Stream.value(bytes);
    Media media = Media(
      stream,
      data.length,
      contentType: MyDriveAccess.mime_type,
    );
    if (id == create_string) {
      file = await manager.drive_access.newFile(
        manager.context,
        title,
        fullDesc,
        media,
      );
      if (file != null && file!.id != null) {
        id = file!.id!;
      }
    } else {
      file = await manager.drive_access.saveData(
        manager.context,
        file!,
        title,
        fullDesc,
        media,
      );
    }
    if (file != null && file!.name != null) {
      title = file!.name!;
    }
    manager.drive_access.logFile("After saving", file);
    return (file != null);
  }

  @override
  Future<String> loadData(FileManager manager) async {
    Log.drive.log("PURPLE: Drive load $id");
    if (file == null) {
      file = await manager.drive_access.getFileById(manager.context, id);
      manager.drive_access.logFile("After get file by id", file);
      if (file == null) {
        if (manager.drive_access.status != DriveAccessStatus.Authorized) {
          throw Exception(
            "Not logged in or permissions not granted for Google Drive.",
          );
        }
        throw Exception("Could not find file with id $id");
      }
    }
    title = file!.name ?? "-unknown-";
    Media? media = await manager.drive_access.loadData(manager.context, file!);
    if (media == null) {
      Log.drive.log("PURPLE: null media.");
      if (manager.drive_access.status != DriveAccessStatus.Authorized) {
        throw Exception(
          "Not logged in or permissions not granted for Google Drive.",
        );
      }
      throw Exception("Could not load media from file with id $id");
    }
    List<List<int>> lists = await media.stream.toList();
    List<int> list = lists.expand((l) => l).toList(); // Flatten.
    return utf8.decode(list);
  }
}

class DriveTab extends OneTab {
  final FileManager manager;
  DriveTab(bool load, this.manager, RecentFiles recent, {super.key})
    : super("Google Drive", load, recent);
  @override
  State<OneTab> createState() => DriveState(manager.drive_access);

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "DT$debug_id";
}

String buildDriveQuery(String rawQuery) {
  String query = rawQuery.trim();
  if (query.isEmpty) return "";

  List<String> clauses = [];
  final ownerRegex = RegExp(r'\bowner:(\S+)\b', caseSensitive: false);
  final matches = ownerRegex.allMatches(query);

  for (final match in matches) {
    final target = match.group(1)!;
    if (target.toLowerCase() == 'me') {
      clauses.add("'me' in owners");
    } else {
      final escapedTarget = target.replaceAll("'", "\\'");
      clauses.add("'$escapedTarget' in owners");
    }
  }

  String nonOwner = query.replaceAll(ownerRegex, '').trim();
  if (nonOwner.isNotEmpty) {
    final hasOperator = RegExp(
      r'\b(contains|in|=|!=|>|<|has)\b',
      caseSensitive: false,
    ).hasMatch(nonOwner);
    if (hasOperator) {
      clauses.add(nonOwner);
    } else {
      final escaped = nonOwner.replaceAll("'", "\\'");
      clauses.add("name contains '$escaped'");
    }
  }

  return clauses.join(" and ");
}

String formatFileModifiedTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return "$year-$month-$day $hour:$minute";
}

class DriveState extends State<DriveTab> {
  static String searchQuery = "";
  late TextEditingController _searchController;
  Timer? _debounceTimer;

  bool _initialized = false;
  bool _active = true;
  bool _authorized = false;
  int _fetchId = 0;
  List<File> files = [];
  MyDriveAccess access;
  StreamSubscription? _statusListener;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "DTS$debug_id-$widget";

  DriveState(this.access);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: searchQuery);
    Log.drive.log("Init State for Drive tabs..");
    initialize();
  }

  // GREEN: This is called and awaited by the FileManager initialization.
  Future<void> initialize() async {
    bool authorized = await access.checkAuthorization();
    setState(() {
      _authorized = authorized;
      _initialized = true;
    });
    if (authorized) fetch_files();
    _statusListener = access.statusStream().listen((status) {
      Log.drive.log("Auth listener: heard status = $status");
      setState(() {
        _authorized = access.status == DriveAccessStatus.Authorized;
      });
      if (_authorized && files.isEmpty) {
        fetch_files();
      }
    });
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_active && mounted) {
        fetch_files();
      }
    });
  }

  void fetch_files() async {
    final currentFetchId = ++_fetchId;
    final String driveQuery = buildDriveQuery(searchQuery);
    Log.drive.log(
      "PURPLE: $this Fetching file list (fetchId: $currentFetchId, query: '$driveQuery')",
    );
    setState(() {
      files.clear();
    });
    try {
      await for (List<File> result in access.listFiles(
        specialQuery: driveQuery,
      )) {
        Log.drive.log("Processing list $result");
        if (!_active || _fetchId != currentFetchId) break;
        setState(() {
          files.addAll(result);
        });
      }
    } catch (e) {
      Log.drive.log("Error fetching files: $e");
    }
  }

  @override
  void dispose() {
    Log.drive.log("MAGENTA: dispose $this.");
    _statusListener?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _active = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.drive.log("build $this, authorized = $_authorized");
    if (!_initialized) return const Text("Checking login...");
    if (!_authorized) {
      return DriveAuthorizeWidget(
        access,
        (bool result) => setState(() {
          Log.drive.log("PURPLE: $this drive authorized called callback.");
          _authorized = result;
          if (_authorized) fetch_files();
        }),
      );
    }
    Widget? avatar = access.getAvatar();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?avatar,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              widget.load ? "Load from Drive" : "Save to Drive",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: TextField(
              key: const ValueKey('drive-search-input'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by title or query (e.g. owner:me)...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged("");
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                _onSearchChanged(val);
                setState(() {});
              },
            ),
          ),
          for (var file in files) _buildFileRow(context, file),
          if (!widget.load) // Add a save new file.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey('open-drive-new'),
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onPressed: () {
                    Log.drive.log("CYAN: drive file make new.");
                    DriveHolder holder = DriveHolder.create();
                    Navigator.of(context).pop(holder);
                    Log.drive.log("CYAN: After pop - new file.");
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.file_open),
                      SizedBox(width: 8),
                      Expanded(child: Text("New File")),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _getFileOwnerDisplay(File file) {
    if (file.owners == null || file.owners!.isEmpty) return "-no owner-";

    final String? currentUserEmail =
        access.user?.email.toLowerCase() ??
        access.cachedUserInfo?['email']?.toLowerCase();
    final String? currentUserId =
        access.user?.id ?? access.cachedUserInfo?['id'];

    bool isOwnedByMe = false;
    final List<String> otherOwners = [];

    for (final owner in file.owners!) {
      final bool isMe =
          (owner.me == true) ||
          (currentUserEmail != null &&
              owner.emailAddress != null &&
              owner.emailAddress!.toLowerCase() == currentUserEmail) ||
          (currentUserId != null &&
              owner.permissionId != null &&
              owner.permissionId == currentUserId);

      if (isMe) {
        isOwnedByMe = true;
      } else {
        String desc = owner.displayName ?? owner.emailAddress ?? "";
        if (owner.displayName != null &&
            owner.emailAddress != null &&
            owner.displayName != owner.emailAddress) {
          desc = "${owner.displayName} (${owner.emailAddress})";
        }
        if (desc.isNotEmpty) {
          otherOwners.add(desc);
        }
      }
    }

    if (isOwnedByMe) return null;
    if (otherOwners.isEmpty) return null;
    return otherOwners.join(", ");
  }

  String? _getFileModifiedDisplay(File file) {
    if (file.modifiedTime == null) return null;
    return formatFileModifiedTime(file.modifiedTime!);
  }

  Widget _buildFileRow(BuildContext context, File file) {
    final String? owner = _getFileOwnerDisplay(file);
    final String? modified = _getFileModifiedDisplay(file);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          key: ValueKey('open-drive-${file.id}'),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          onPressed: () {
            DriveHolder holder = DriveHolder(file.id!);
            holder.title = file.name ?? "-unknown name-";
            holder.file = file;
            access.logFile("Chose this file", file);

            Log.drive.log("CYAN: drive file $holder.");
            Navigator.of(context).pop(holder);
            Log.drive.log("CYAN: After pop - load/save drive file.");
          },
          child: Row(
            children: [
              const Icon(Icons.file_open),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${file.name ?? '-unknown name-'} (${file.id})",
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (modified != null)
                      Text(
                        "Modified: $modified",
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (owner != null)
                      Text(
                        "Owner: $owner",
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DriveAccessStatus { LoggedOut, LoggedIn, Authorized }

// This is a singleton owned by the file manager.
class MyDriveAccess {
  DriveAccessStatus _status = DriveAccessStatus.LoggedOut;
  DriveAccessStatus get status => _status;
  final StreamController<DriveAccessStatus> _statusStream =
      StreamController<DriveAccessStatus>.broadcast();

  GoogleSignInAccount? user;
  Map<String, String>? cachedUserInfo;
  DriveApi? driveApi;

  // XXX -- put mime type in file_manager.
  // Or maybe use "Content-Type: application/json"
  static final String mime_type = "application/spacetime";

  static final scopes = [
    DriveApi.driveScope,
    // == 'https://www.googleapis.com/auth/drive',
  ];
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isTesting = false;

  // The fields I am interested in.
  final String fields =
      'id, name, description, kind, mimeType, owners, permissions, size, version, modifiedTime';

  // XXX Some of these might be interesting.
  // final String fields =
  //     'files(id, name, description, kind, mimeType, owners, permissions, capabilities, size, linkShareMetadata, version)';

  // Saved preference string to decide if we should try to automatically login.
  static final String was_authorized_string = "was_authorized";
  static final String remember_me_string = "remember_me";

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "DA$debug_id";

  bool rememberMe = true;

  MyDriveAccess();

  Future<void> setRememberMe(bool value) async {
    rememberMe = value;
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(remember_me_string, value);
  }

  Future<void> initialize() async {
    Log.drive.log("PURPLE: $this Initialize drive.");
    final prefs = SharedPreferencesAsync();
    rememberMe = await prefs.getBool(remember_me_string) ?? true;
    if (isTesting) {
      Log.drive.log(
        "PURPLE: Skipping drive sign-in initialization for testing.",
      );
      status = DriveAccessStatus.LoggedOut;
      return;
    }
    await _googleSignIn.initialize();
    _googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
    bool wasAuthorized = await prefs.getBool(was_authorized_string) ?? false;
    Log.drive.log(
      "PURPLE: rememberMe = $rememberMe, wasAuthorized = $wasAuthorized",
    );
    cachedUserInfo = await TokenStorage.getUserInfo();
    if (rememberMe && wasAuthorized) {
      DriveApi? cachedApi = await getCachedDriveApi();
      if (cachedApi != null) {
        driveApi = cachedApi;
        status = DriveAccessStatus.Authorized;
        Log.drive.log(
          "PURPLE: Restored authorized DriveApi from cache on initialize.",
        );
        return;
      }
      await _googleSignIn.attemptLightweightAuthentication();
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        user = event.user;
        Log.drive.log("PURPLE: authentication event sets user = $user");
        if (user == null) {
          status = DriveAccessStatus.LoggedOut;
          return;
        }
        await TokenStorage.saveUserInfo(user!);
        cachedUserInfo = {
          'id': user!.id,
          'email': user!.email,
          if (user!.displayName != null) 'displayName': user!.displayName!,
          if (user!.photoUrl != null) 'photoUrl': user!.photoUrl!,
        };
        final GoogleSignInClientAuthorization? authorization = await user
            ?.authorizationClient
            .authorizationForScopes(scopes);

        if (authorization != null) {
          final auth.AuthClient client = authorization.authClient(
            scopes: scopes,
          );
          await TokenStorage.saveCredentials(client.credentials);
          driveApi = DriveApi(client);
          status = DriveAccessStatus.Authorized;
          return;
        }

        await TokenStorage.clearCredentials();
        driveApi = null;
        status = DriveAccessStatus.LoggedIn;
        break;

      case GoogleSignInAuthenticationEventSignOut():
        user = null;
        cachedUserInfo = null;
        driveApi = null;
        await TokenStorage.clearTokens();
        status = DriveAccessStatus.LoggedOut;
        break;
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    Log.drive.log("RED: AUTHENTICATION ERROR: $e");
    user = null;
    driveApi = null;
    status = DriveAccessStatus.LoggedOut;
  }

  Future<DriveApi?> getCachedDriveApi() async {
    final savedTokens = await TokenStorage.getTokens();
    if (savedTokens == null) return null;

    final expiryString = savedTokens['expiry_date'];
    if (expiryString == null) return null;

    final expiry = DateTime.parse(expiryString).toUtc();
    if (DateTime.now().toUtc().isAfter(
      expiry.subtract(const Duration(minutes: 1)),
    )) {
      Log.drive.log("PURPLE: Cached token is expired (expiry: $expiry).");
      return null;
    }

    final accessToken = savedTokens['access_token'];
    if (accessToken == null || accessToken.isEmpty) return null;

    final refreshToken = savedTokens['refresh_token'];
    final idToken = savedTokens['id_token'];
    final credentials = auth.AccessCredentials(
      auth.AccessToken('Bearer', accessToken, expiry),
      refreshToken,
      scopes,
      idToken: idToken,
    );

    http.Client baseClient = http.Client();
    auth.AuthClient authenticatedClient;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      authenticatedClient = auth.autoRefreshingClient(
        auth.ClientId('', ''),
        credentials,
        baseClient,
      );
    } else {
      authenticatedClient = auth.authenticatedClient(baseClient, credentials);
    }
    Log.drive.log("PURPLE: Successfully created DriveApi from cached tokens.");
    return DriveApi(authenticatedClient);
  }

  Future<DriveApi?> getRefreshedDriveApi() => getCachedDriveApi();

  // Update login status and notify listeners.
  set status(DriveAccessStatus newStatus) {
    if (_status != newStatus) {
      final prefs = SharedPreferencesAsync();
      prefs.setBool(
        was_authorized_string,
        newStatus == DriveAccessStatus.Authorized,
      );
    }
    _status = newStatus;
    notify();
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  // These stream is notified whenever the login has change.
  Stream<DriveAccessStatus> statusStream() {
    return _statusStream.stream;
  }

  void notify() {
    // Notify all the other widgets, so that they redraw with latest settings.
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  void setAuthorized(bool authorized) {
    status = authorized
        ? DriveAccessStatus.Authorized
        : (user != null
              ? DriveAccessStatus.LoggedIn
              : DriveAccessStatus.LoggedOut);
  }

  // ORANGE: Used by web interface when signin button is clicked.
  // This is the on-click handler for the Sign In button that is rendered by Flutter.
  //
  // On the web, the on-click handler of the Sign In button is owned by the JS
  // SDK, so this method can be considered mobile only.
  Future<void> handleSignIn() async {
    Log.drive.log(
      "PURPLE: $this handle signin. This should happen after the button was clicked.",
    );
    try {
      await _googleSignIn.authenticate();
      Log.drive.log("PURPLE: $this handle signin was successful.");
    } catch (error) {
      // XXX display error to user.
      Log.drive.log("PURPLE: $this handle signin failed: $error.");
    }
  }

  // GREEN: Called by FileManager UI to logout and forget.
  Future<void> logout() async {
    Log.drive.log("PURPLE: $this log out.");
    user = null;
    cachedUserInfo = null;
    driveApi = null;
    await TokenStorage.clearTokens();
    status = DriveAccessStatus.LoggedOut;
    return _googleSignIn.disconnect();
  }

  // XXX ---- the following three functions do this:
  // Check to see if we are currently authorized or not. It can be done with no user interaction.
  // if not, the caller will prompt the user to login.
  // This one is done in background and on init.

  // check authorization and if we don't have it then open a dialog to request it.
  // This one is done before saving/loading and then it pops up a dialog.
  //
  // the callback when the dialog has button "request permissions" is clicked. This
  // needs to be the result of the user clicking something.
  // it then initializes the driveApi object.

  // XXX driveApi client should be auto initialized if possible.

  // BLUE: Called by DriveTab in initialization.
  // Check and double check to see if the user is logged in and authorized.  If
  // not, and the build context is not null, then open a dialog to request
  // authorization.
  Future<bool> checkAuthorization() async {
    if (status == DriveAccessStatus.Authorized && driveApi != null) {
      return true;
    }
    if (user == null && cachedUserInfo == null) {
      setAuthorized(false);
      return false;
    }
    if (user != null) {
      final GoogleSignInClientAuthorization? authorization = await user!
          .authorizationClient
          .authorizationForScopes(scopes);
      if (authorization != null) {
        final auth.AuthClient client = authorization.authClient(scopes: scopes);
        await TokenStorage.saveCredentials(client.credentials);
        driveApi = DriveApi(client);
        setAuthorized(true);
        return true;
      }
    }

    DriveApi? cachedApi = await getCachedDriveApi();
    if (cachedApi != null) {
      driveApi = cachedApi;
      setAuthorized(true);
      return true;
    }

    setAuthorized(false);
    return false;
  }

  // BLUE: Called when saving or loading data. Can use a UI.
  // XXX rename to requestscopes? requestAuthorization?
  // Check if the user is logged in and authorized, and if not, then open a
  // dialog to request it.
  Future<bool> getAuthorization(BuildContext? context) async {
    // Look at the cached value first.
    if (await checkAuthorization()) {
      Log.drive.log("PURPLE: get authorization not needed.");
      return true;
    }
    Log.drive.log("PURPLE: $this need to authorize. driveApi = $driveApi.");
    if (context == null || !context.mounted) {
      Log.drive.log("RED: context is null or not mounted in getAuthorization.");
      return false;
    }
    // If the dialog returns false or null, then the user has either not
    // authorized or not logged in.
    bool authorized =
        (true ==
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: DriveAuthorizeWidget(
              this,
              (result) => Navigator.of(context).pop(result),
            ),
          ),
        ));
    Log.drive.log("PURPLE: $this after dialog, authorized = $authorized");
    if (!authorized) logout();
    setAuthorized(authorized);
    return authorized;
  }

  // BLUE: Called from authorization widget (UI).
  // Prompt the user to authorize 'scopes'.
  //
  // This action is **required** in platforms that don't perform Authentication
  // and Authorization at the same time (like the web).
  //
  // On the web, this must be called from an user interaction (button click).
  //
  // After requesting scopes, the driveApi variable is initialized.
  Future<bool> requestScopes() async {
    Log.drive.log("Request scopes.");
    if (user == null) {
      Log.drive.log("User is null. Cannot request scopes.");
      setAuthorized(false);
      return false;
    }
    try {
      final GoogleSignInClientAuthorization authorization = await user!
          .authorizationClient
          .authorizeScopes(scopes);
      final auth.AuthClient client = authorization.authClient(scopes: scopes);
      await TokenStorage.saveCredentials(client.credentials);
      driveApi = DriveApi(client);
      setAuthorized(true);
      return true;
    } catch (e) {
      Log.drive.log("Error requesting scopes: $e");
      setAuthorized(false);
      return false;
    }
  }

  bool isAuthError(Object err) {
    final String errStr = err.toString();
    return errStr.contains("invalid_token") ||
        errStr.contains("401") ||
        errStr.contains("403") ||
        errStr.contains("Access was denied") ||
        errStr.contains("Unauthenticated");
  }

  Future<void> _handleAuthError(Object err) async {
    Log.drive.log("PURPLE: $this Drive API Auth Error: $err");
    if (isAuthError(err)) {
      driveApi = null;
      await TokenStorage.clearTokens();
      if (user == null) {
        cachedUserInfo = null;
      }
      setAuthorized(false);
    }
  }

  // BLUE: Called by DriveHolder in saveData and loadData.
  Future<File?> getFileById(BuildContext? context, String id) async {
    Log.drive.log("PURPLE: $this getFileById $id");
    if (!await getAuthorization(context)) return null;
    try {
      // GREEN: File file = await driveApi!.files.get(id) as File;
      File file = await driveApi!.files.get(id, $fields: fields) as File;
      logFile("getFileby id $id", file);
      return file;
    } catch (err) {
      Log.drive.log("PURPLE: $this Error getFileById: $err");
      bool wasAuth = isAuthError(err);
      await _handleAuthError(err);
      if (wasAuth && context != null && context.mounted) {
        if (await getAuthorization(context)) {
          try {
            File retryFile =
                await driveApi!.files.get(id, $fields: fields) as File;
            logFile("getFileby id $id after reauth", retryFile);
            return retryFile;
          } catch (retryErr) {
            Log.drive.log("PURPLE: $this Retry error getFileById: $retryErr");
            await _handleAuthError(retryErr);
          }
        }
      }
      return null;
    }
  }

  // BLUE: Called by DriveHolder in saveData.
  Future<File?> newFile(
    BuildContext? context,
    String title,
    String description,
    Media media,
  ) async {
    Log.drive.log("PURPLE: $this Creating new file");
    if (!await getAuthorization(context)) return null;
    try {
      File file = File();
      file.name = title;
      file.description = description;
      file.mimeType = mime_type;
      file = await driveApi!.files.create(file, uploadMedia: media);
      Log.drive.log("PURPLE: $this Finished create file. result = $file.");
      logFile("create", file);
      return file;
    } catch (err) {
      Log.drive.log("PURPLE: $this Error create file: $err");
      await _handleAuthError(err);
      return null;
    }
  }

  // BLUE: Called by DriveHolder in saveData.
  Future<File?> saveData(
    BuildContext? context,
    File file,
    String title,
    String description,
    Media media,
  ) async {
    Log.drive.log("PURPLE: $this Updating file w/id = ${file.id}");
    if (!await getAuthorization(context)) {
      Log.drive.log("RED: $this not authorized!");
      return null;
    }
    if (file.id == null) {
      Log.drive.log("RED: save file id is null.");
      return null;
    }
    try {
      File request = File(); // Create a new object for the request.
      request.name = title;
      request.description = description;
      request.mimeType = mime_type;
      file = await driveApi!.files.update(
        request,
        file.id!,
        uploadMedia: media,
      );
      Log.drive.log("PURPLE: $this Finished update file. result = $file.");
      logFile("update request", request);
      logFile("update result", file);
      return file;
    } catch (err) {
      Log.drive.log("PURPLE: $this Error updating file: $err");
      await _handleAuthError(err);
      return null;
    }
  }

  // BLUE: Called by DriveHolder in loadData for both load from list and reload.
  Future<Media?> loadData(BuildContext? context, File file) async {
    Log.drive.log("PURPLE: $this load data w/id = ${file.id}");
    if (!await getAuthorization(context)) return null;
    if (file.id == null) {
      Log.drive.log("XXX The file id was null when trying to load.");
      return null;
    }
    try {
      // GREEN: Media media = await driveApi!.files(id, downloadOptions: fullMedia)
      Media media =
          await driveApi!.files.get(
                file.id!,
                downloadOptions: DownloadOptions.fullMedia,
              )
              as Media;
      Log.drive.log("PURPLE: $this Finished update file. result = $media.");
      return media;
    } catch (err) {
      Log.drive.log("PURPLE: $this Error loading file: $err");
      bool wasAuth = isAuthError(err);
      await _handleAuthError(err);
      if (wasAuth && context != null && context.mounted) {
        if (await getAuthorization(context)) {
          try {
            Media retryMedia =
                await driveApi!.files.get(
                      file.id!,
                      downloadOptions: DownloadOptions.fullMedia,
                    )
                    as Media;
            return retryMedia;
          } catch (retryErr) {
            Log.drive.log("PURPLE: $this Retry error loadData: $retryErr");
            await _handleAuthError(retryErr);
          }
        }
      }
      return null;
    }
  }

  // ORANGE: Called by DriveTab after initialization.
  Stream<List<File>> listFiles({String specialQuery = ""}) async* {
    Log.drive.log("PURPLE: $this listFiles. driveApi = $driveApi");
    if (driveApi == null) throw Exception("You aint Logged in.");

    final List<String> queries = [];
    final String trimmedSpecial = specialQuery.trim();
    final String specialSuffix = trimmedSpecial.isNotEmpty
        ? (trimmedSpecial.toLowerCase().startsWith("and ")
              ? " $trimmedSpecial"
              : " and $trimmedSpecial")
        : "";

    // Always search for files owned by the user.
    queries.add(
      "trashed = false and mimeType = '$mime_type' and 'me' in owners$specialSuffix",
    );

    // Also search for files owned by other users.
    queries.add(
      "trashed = false and mimeType = '$mime_type' and sharedWithMe = true$specialSuffix",
    );

    final Set<String> seenIds = {};

    try {
      for (final fullQuery in queries) {
        String? pageToken;
        do {
          Log.drive.log("Query: $fullQuery");
          FileList list = await driveApi!.files.list(
            q: fullQuery,
            spaces: 'drive',
            pageToken: pageToken,
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
            orderBy: 'modifiedTime desc',
            $fields: "nextPageToken, files($fields)",
          );
          if (list.files != null && list.files!.isNotEmpty) {
            List<File> uniqueFiles = [];
            for (File file in list.files!) {
              logFile(" list", file);

              if (file.id != null && seenIds.add(file.id!)) {
                uniqueFiles.add(file);
              }
            }
            if (uniqueFiles.isNotEmpty) {
              Log.drive.log(
                "PURPLE: $this list files Count = ${uniqueFiles.length}",
              );
              int count = 0;
              for (File file in uniqueFiles) {
                count++;
                logFile(" list $count", file);
              }
              yield uniqueFiles;
            }
          }
          pageToken = list.nextPageToken;
        } while (pageToken != null && pageToken.isNotEmpty);
      }
    } catch (err) {
      Log.drive.log("PURPLE: $this Error listFiles: $err");
      await _handleAuthError(err);
      rethrow;
    }
  }

  Future<void> logUser() async {
    if (user == null) {
      Log.drive.log("User is null");
      return;
    }
    // XXX OLD: bool signedin = await _googleSignIn.isSignedIn();
    bool signedin = false;
    Log.drive.log("user = $user");
    Log.drive.log("signed in = $signedin");
    Log.drive.log("email = ${user!.email}");
    Log.drive.log("id = ${user!.id}");
    Log.drive.log("photo = ${user!.photoUrl}");
    Log.drive.log("name = ${user!.displayName}");
    Log.drive.log("hash = ${user!.hashCode}");
    // XXX OLD: Log.drive.log("clientId = ${_googleSignIn.clientId}"); // null.
    // XXX OLD: Log.drive.log("server auth code = ${user!.serverAuthCode}"); // null.
    var auth = user!.authentication;
    // token = null.
    // auth = GoogleSignInAuthentication:Instance of 'GoogleSignInTokenData'
    // XXX OLD: Log.drive.log("access token = ${auth.accessToken} for $auth");
    // id token = ey...
    Log.drive.log("id token = ${auth.idToken}");
    // GoogleSignInTokenData holds id token and access token and serverAuthCode.
  }

  Future<void> logClient(String t, auth.AuthClient? client) async {
    Log.drive.log("PURPLE: $t client = $client");
    if (client == null) return;

    var creds = client.credentials;
    /*
    [  +48 ms] PURPLE: requestScopes client = Instance of 'AuthenticatedClient'
    [        ] credentials = Instance of 'AccessCredentials'
    [        ] token = AccessToken(type=Bearer, data=ya29..., expiry=2026-04-21 02:34:04.671Z), id=null
    [        ] refresh=null
    [        ] scopes = [https://www.googleapis.com/auth/drive.file]

    */
    Log.drive.log("credentials = $creds");
    Log.drive.log("token = ${creds.accessToken}, id=${creds.idToken}");
    Log.drive.log("refresh=${creds.refreshToken}");
    Log.drive.log("scopes = ${creds.scopes}");
  }

  // BLUE: Called by DriveHolder after changes.
  void logFile(String s, File? file) {
    if (file == null) {
      Log.drive.log("PURPLE: $s, null file.");
      return;
    }
    Log.drive.log("PURPLE: $s, file.id = ${file.id}"); // a UUID-ish thing.
    // Untitled3 has id 1fc68r9nd3PsOTtzGnSvx6AAA-8isukyS.
    Log.drive.log("  name = ${file.name}");
    Log.drive.log("  description = ${file.description}");
    Log.drive.log("  modifiedTime = ${file.modifiedTime}");
    Log.drive.log(
      "  kind = ${file.kind}, size = ${file.size}, version = ${file.version}",
    );
    Log.drive.log("  mimeType = ${file.mimeType}");
    if (file.owners != null) {
      for (User user in file.owners!) {
        Log.drive.log("      Owner: ${user.displayName}, ${user.emailAddress}");
      }
    }
    if (file.permissions != null) {
      for (Permission p in file.permissions!) {
        Log.drive.log("     Permission: ${p.displayName}");
      }
    }
    if (file.capabilities != null) {
      FileCapabilities c = file.capabilities!;
      Log.drive.log(
        "      canComment = ${c.canComment}, canDelete = ${c.canDelete}"
        ", canEdit=${c.canEdit}, canModifyContent=${c.canModifyContent}.",
      );
    }
    if (file.linkShareMetadata != null) {
      Log.drive.log(" link = ${file.linkShareMetadata}");
    }
    if (file.contentHints != null) {
      Log.drive.log(" content hint = ${file.contentHints}");
    }
    if (file.webViewLink != null) {
      Log.drive.log(" webviewlink = ${file.webViewLink}");
    }
    if (file.resourceKey != null) {
      Log.drive.log(" resourceKey = ${file.resourceKey}");
    }
  }

  Widget? getAvatar([GoogleSignInAccount? user]) {
    user ??= this.user;
    if (user == null) {
      if (cachedUserInfo != null) {
        final name =
            cachedUserInfo!['displayName'] ?? cachedUserInfo!['email'] ?? '';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
        return ListTile(
          leading: CircleAvatar(child: Text(initial)),
          title: Text(cachedUserInfo!['displayName'] ?? ''),
          subtitle: Text(cachedUserInfo!['email'] ?? ''),
        );
      }
      return null;
    }
    Log.drive.log("Fetching the CircleAvatar.");
    return ListTile(
      leading: GoogleUserCircleAvatar(identity: user),
      title: Text(user.displayName ?? ''),
      subtitle: Text(user.email),
    );
  }
}

class DriveAuthorizeWidget extends StatefulWidget {
  final MyDriveAccess access;
  final void Function(bool) callback;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "DAW-$debug_id";

  DriveAuthorizeWidget(this.access, this.callback, {super.key}) {
    // Log.drive.log("ORANGE: Create new $this.");
  }

  @override
  State<DriveAuthorizeWidget> createState() {
    // Log.drive.log("ORANGE: Create state for $this.");
    return DriveAuthorizeWidgetState();
  }
}

class DriveAuthorizeWidgetState extends State<DriveAuthorizeWidget> {
  StreamSubscription? _statusListener;
  bool _authorized = false;
  bool _rememberMe = true;
  bool _isPopped = false;

  static int debug_counter = 0;
  final int debug_id = ++debug_counter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      "S$debug_id-$widget";

  DriveAuthorizeWidgetState() {
    Log.drive.log("ORANGE: Create new drive auth widget state $debug_id.");
  }

  void _pop(bool result) {
    if (_isPopped) return;
    _isPopped = true;
    widget.callback(result);
  }

  @override
  void initState() {
    // Log.drive.log("ORANGE: $this initState.");
    super.initState();
    _rememberMe = widget.access.rememberMe;
    _statusListener = widget.access.statusStream().listen((status) {
      Log.drive.log("Auth listener: heard status = $status");
      setState(() {
        _authorized = widget.access.status == DriveAccessStatus.Authorized;
        if (_authorized) {
          _pop(true);
        }
      });
    });
  }

  @override
  void dispose() {
    // Log.drive.log("ORANGE: Dispose of $this.");
    _statusListener?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthorizeScopes() async {
    if (widget.access.user == null) {
      Log.drive.log(
        "PURPLE: User is null when requesting scopes. Triggering sign in.",
      );
      await widget.access.handleSignIn();
      return;
    }
    bool authorized = await widget.access.requestScopes();
    Log.drive.log(
      "PURPLE: handle authorized state now has authorized =  $authorized",
    );
    setState(() {
      _authorized = authorized;
    });
    if (authorized) {
      _pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = widget.access.user;
    final bool isLoggedIn = user != null;
    final Widget? avatar = widget.access.getAvatar(user);
    if (isLoggedIn) {
      // The user is logged in.
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ?avatar,
            const SizedBox(height: 12),
            const Text(
              'Signed in successfully.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (_authorized) ...<Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('OK'),
              ),
              const SizedBox(height: 12),
            ],
            if (!_authorized) ...<Widget>[
              const Text(
                'Additional permissions needed to access Google Drive files.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _handleAuthorizeScopes,
                child: const Text('REQUEST PERMISSIONS'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton(
              onPressed: widget.access.logout,
              child: const Text('SIGN OUT'),
            ),
          ],
        ),
      );
    } else {
      // The user is NOT Authenticated
      final String? cachedEmail = widget.access.cachedUserInfo?['email'];
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              cachedEmail != null
                  ? 'Session expired for $cachedEmail.\nPlease sign in again.'
                  : 'You are not currently signed in.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Remember me on this device'),
              value: _rememberMe,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _rememberMe = value;
                  });
                  widget.access.setRememberMe(value);
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            // This method is used to separate mobile from web code with conditional exports.
            // See: src/sign_in_button.dart
            buildSignInButton(onPressed: widget.access.handleSignIn),
          ],
        ),
      );
    }
  }
}

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(
    auth.AccessCredentials credentials,
  ) async {
    try {
      await _storage.write(
        key: 'access_token',
        value: credentials.accessToken.data,
      );
      if (credentials.refreshToken != null) {
        await _storage.write(
          key: 'refresh_token',
          value: credentials.refreshToken!,
        );
      } else {
        await _storage.delete(key: 'refresh_token');
      }
      if (credentials.idToken != null) {
        await _storage.write(key: 'id_token', value: credentials.idToken!);
      } else {
        await _storage.delete(key: 'id_token');
      }
      await _storage.write(
        key: 'expiry_date',
        value: credentials.accessToken.expiry.toUtc().toIso8601String(),
      );
      Log.drive.log("PURPLE: save tokens.");
    } catch (e) {
      Log.drive.log("RED: Error saving tokens: $e");
    }
  }

  static Future<void> saveUserInfo(GoogleSignInAccount user) async {
    try {
      await _storage.write(key: 'user_id', value: user.id);
      await _storage.write(key: 'user_email', value: user.email);
      if (user.displayName != null) {
        await _storage.write(
          key: 'user_display_name',
          value: user.displayName!,
        );
      } else {
        await _storage.delete(key: 'user_display_name');
      }
      if (user.photoUrl != null) {
        await _storage.write(key: 'user_photo_url', value: user.photoUrl!);
      } else {
        await _storage.delete(key: 'user_photo_url');
      }
      Log.drive.log("PURPLE: save user info.");
    } catch (e) {
      Log.drive.log("RED: Error saving user info: $e");
    }
  }

  static Future<Map<String, String>?> getUserInfo() async {
    try {
      final id = await _storage.read(key: 'user_id');
      final email = await _storage.read(key: 'user_email');
      final displayName = await _storage.read(key: 'user_display_name');
      final photoUrl = await _storage.read(key: 'user_photo_url');
      if (id != null && email != null) {
        return {
          'id': id,
          'email': email,
          'displayName': ?displayName,
          'photoUrl': ?photoUrl,
        };
      }
    } catch (e) {
      Log.drive.log("RED: Error reading user info: $e");
    }
    return null;
  }

  static Future<Map<String, String>?> getTokens() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      final idToken = await _storage.read(key: 'id_token');
      final expiryDateString = await _storage.read(key: 'expiry_date');

      if (accessToken != null && expiryDateString != null) {
        Log.drive.log("PURPLE: loaded tokens.");
        return {
          'access_token': accessToken,
          'refresh_token': ?refreshToken,
          'id_token': ?idToken,
          'expiry_date': expiryDateString,
        };
      }
    } catch (e) {
      Log.drive.log("RED: Error reading tokens: $e");
    }
    return null;
  }

  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'id_token');
      await _storage.delete(key: 'expiry_date');
      Log.drive.log("PURPLE: cleared credentials.");
    } catch (e) {
      Log.drive.log("RED: Error clearing credentials: $e");
    }
  }

  static Future<void> clearTokens() async {
    try {
      await clearCredentials();
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_display_name');
      await _storage.delete(key: 'user_photo_url');
      Log.drive.log("PURPLE: cleared tokens.");
    } catch (e) {
      Log.drive.log("RED: Error clearing tokens: $e");
    }
  }
}
