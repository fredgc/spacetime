import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../printer.dart';
import '../sign_in_button.dart';

enum DriveAccessStatus { loggedOut, loggedIn, authorized }

/// Manages Google Drive OAuth tokens, sign-in state, and API initialization.
class MyDriveAccess {
  DriveAccessStatus _status = DriveAccessStatus.loggedOut;
  DriveAccessStatus get status => _status;
  final StreamController<DriveAccessStatus> _statusStream =
      StreamController<DriveAccessStatus>.broadcast();

  GoogleSignInAccount? user;
  Map<String, String>? cachedUserInfo;
  DriveApi? driveApi;

  static final String mimeType = 'application/spacetime';

  static final scopes = [DriveApi.driveScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool isTesting = false;

  final String fields =
      'id, name, description, kind, mimeType, owners, permissions, size, version, modifiedTime';

  static final String wasAuthorizedString = 'was_authorized';
  static final String rememberMeString = 'remember_me';

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'DA$_debugId';

  bool rememberMe = true;

  MyDriveAccess();

  Future<void> setRememberMe(bool value) async {
    rememberMe = value;
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(rememberMeString, value);
  }

  Future<void> initialize() async {
    Log.drive.log('PURPLE: $this Initialize drive.');
    final prefs = SharedPreferencesAsync();
    rememberMe = await prefs.getBool(rememberMeString) ?? true;
    if (isTesting) {
      Log.drive.log(
        'PURPLE: Skipping drive sign-in initialization for testing.',
      );
      status = DriveAccessStatus.loggedOut;
      return;
    }
    await _googleSignIn.initialize();
    _googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);
    bool wasAuthorized = await prefs.getBool(wasAuthorizedString) ?? false;
    Log.drive.log(
      'PURPLE: rememberMe = $rememberMe, wasAuthorized = $wasAuthorized',
    );
    cachedUserInfo = await TokenStorage.getUserInfo();
    if (rememberMe && wasAuthorized) {
      DriveApi? cachedApi = await getCachedDriveApi();
      if (cachedApi != null) {
        driveApi = cachedApi;
        status = DriveAccessStatus.authorized;
        Log.drive.log(
          'PURPLE: Restored authorized DriveApi from cache on initialize.',
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
        Log.drive.log('PURPLE: authentication event sets user = $user');
        if (user == null) {
          status = DriveAccessStatus.loggedOut;
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
          status = DriveAccessStatus.authorized;
          return;
        }

        await TokenStorage.clearCredentials();
        driveApi = null;
        status = DriveAccessStatus.loggedIn;
        break;

      case GoogleSignInAuthenticationEventSignOut():
        user = null;
        cachedUserInfo = null;
        driveApi = null;
        await TokenStorage.clearTokens();
        status = DriveAccessStatus.loggedOut;
        break;
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    Log.drive.log('RED: AUTHENTICATION ERROR: $e');
    user = null;
    driveApi = null;
    status = DriveAccessStatus.loggedOut;
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
      Log.drive.log('PURPLE: Cached token is expired (expiry: $expiry).');
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
    Log.drive.log('PURPLE: Successfully created DriveApi from cached tokens.');
    return DriveApi(authenticatedClient);
  }

  Future<DriveApi?> getRefreshedDriveApi() => getCachedDriveApi();

  set status(DriveAccessStatus newStatus) {
    if (_status != newStatus) {
      final prefs = SharedPreferencesAsync();
      prefs.setBool(
        wasAuthorizedString,
        newStatus == DriveAccessStatus.authorized,
      );
    }
    _status = newStatus;
    notify();
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  Stream<DriveAccessStatus> statusStream() {
    return _statusStream.stream;
  }

  void notify() {
    if (_statusStream.hasListener) _statusStream.add(_status);
  }

  void setAuthorized(bool authorized) {
    status = authorized
        ? DriveAccessStatus.authorized
        : (user != null
              ? DriveAccessStatus.loggedIn
              : DriveAccessStatus.loggedOut);
  }

  Future<void> handleSignIn() async {
    Log.drive.log(
      'PURPLE: $this handle signin. This should happen after the button was clicked.',
    );
    try {
      await _googleSignIn.authenticate();
      Log.drive.log('PURPLE: $this handle signin was successful.');
    } catch (error) {
      Log.drive.log('PURPLE: $this handle signin failed: $error.');
    }
  }

  Future<void> logout() async {
    Log.drive.log('PURPLE: $this log out.');
    user = null;
    cachedUserInfo = null;
    driveApi = null;
    await TokenStorage.clearTokens();
    status = DriveAccessStatus.loggedOut;
    return _googleSignIn.disconnect();
  }

  Future<bool> checkAuthorization() async {
    if (status == DriveAccessStatus.authorized && driveApi != null) {
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

  Future<bool> getAuthorization(BuildContext? context) async {
    if (await checkAuthorization()) {
      Log.drive.log('PURPLE: get authorization not needed.');
      return true;
    }
    Log.drive.log('PURPLE: $this need to authorize. driveApi = $driveApi.');
    if (context == null || !context.mounted) {
      Log.drive.log('RED: context is null or not mounted in getAuthorization.');
      return false;
    }
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
    Log.drive.log('PURPLE: $this after dialog, authorized = $authorized');
    if (!authorized) logout();
    setAuthorized(authorized);
    return authorized;
  }

  Future<bool> requestScopes() async {
    Log.drive.log('Request scopes.');
    if (user == null) {
      Log.drive.log('User is null. Cannot request scopes.');
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
      Log.drive.log('Error requesting scopes: $e');
      setAuthorized(false);
      return false;
    }
  }

  bool isAuthError(Object err) {
    final String errStr = err.toString();
    return errStr.contains('invalid_token') ||
        errStr.contains('401') ||
        errStr.contains('403') ||
        errStr.contains('Access was denied') ||
        errStr.contains('Unauthenticated');
  }

  Future<void> _handleAuthError(Object err) async {
    Log.drive.log('PURPLE: $this Drive API Auth Error: $err');
    if (isAuthError(err)) {
      driveApi = null;
      await TokenStorage.clearTokens();
      if (user == null) {
        cachedUserInfo = null;
      }
      setAuthorized(false);
    }
  }

  Future<File?> getFileById(BuildContext? context, String id) async {
    Log.drive.log('PURPLE: $this getFileById $id');
    if (!await getAuthorization(context)) return null;
    try {
      File file = await driveApi!.files.get(id, $fields: fields) as File;
      logFile('getFileby id $id', file);
      return file;
    } catch (err) {
      Log.drive.log('PURPLE: $this Error getFileById: $err');
      bool wasAuth = isAuthError(err);
      await _handleAuthError(err);
      if (wasAuth && context != null && context.mounted) {
        if (await getAuthorization(context)) {
          try {
            File retryFile =
                await driveApi!.files.get(id, $fields: fields) as File;
            logFile('getFileby id $id after reauth', retryFile);
            return retryFile;
          } catch (retryErr) {
            Log.drive.log('PURPLE: $this Retry error getFileById: $retryErr');
            await _handleAuthError(retryErr);
          }
        }
      }
      return null;
    }
  }

  Future<File?> newFile(
    BuildContext? context,
    String title,
    String description,
    Media media,
  ) async {
    Log.drive.log('PURPLE: $this Creating new file');
    if (!await getAuthorization(context)) return null;
    try {
      File file = File();
      file.name = title;
      file.description = description;
      file.mimeType = mimeType;
      file = await driveApi!.files.create(file, uploadMedia: media);
      Log.drive.log('PURPLE: $this Finished create file. result = $file.');
      logFile('create', file);
      return file;
    } catch (err) {
      Log.drive.log('PURPLE: $this Error create file: $err');
      await _handleAuthError(err);
      return null;
    }
  }

  Future<File?> saveData(
    BuildContext? context,
    File file,
    String title,
    String description,
    Media media,
  ) async {
    Log.drive.log('PURPLE: $this Updating file w/id = ${file.id}');
    if (!await getAuthorization(context)) {
      Log.drive.log('RED: $this not authorized!');
      return null;
    }
    if (file.id == null) {
      Log.drive.log('RED: save file id is null.');
      return null;
    }
    try {
      File request = File();
      request.name = title;
      request.description = description;
      request.mimeType = mimeType;
      file = await driveApi!.files.update(
        request,
        file.id!,
        uploadMedia: media,
      );
      Log.drive.log('PURPLE: $this Finished update file. result = $file.');
      logFile('update request', request);
      logFile('update result', file);
      return file;
    } catch (err) {
      Log.drive.log('PURPLE: $this Error updating file: $err');
      await _handleAuthError(err);
      return null;
    }
  }

  Future<Media?> loadData(BuildContext? context, File file) async {
    Log.drive.log('PURPLE: $this load data w/id = ${file.id}');
    if (!await getAuthorization(context)) return null;
    if (file.id == null) {
      Log.drive.log('XXX The file id was null when trying to load.');
      return null;
    }
    try {
      Media media =
          await driveApi!.files.get(
                file.id!,
                downloadOptions: DownloadOptions.fullMedia,
              )
              as Media;
      Log.drive.log('PURPLE: $this Finished update file. result = $media.');
      return media;
    } catch (err) {
      Log.drive.log('PURPLE: $this Error loading file: $err');
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
            Log.drive.log('PURPLE: $this Retry error loadData: $retryErr');
            await _handleAuthError(retryErr);
          }
        }
      }
      return null;
    }
  }

  Stream<List<File>> listFiles({String specialQuery = ''}) async* {
    Log.drive.log('PURPLE: $this listFiles. driveApi = $driveApi');
    if (driveApi == null) throw Exception('You aint Logged in.');

    final List<String> queries = [];
    final String trimmedSpecial = specialQuery.trim();
    final String specialSuffix = trimmedSpecial.isNotEmpty
        ? (trimmedSpecial.toLowerCase().startsWith('and ')
              ? ' $trimmedSpecial'
              : ' and $trimmedSpecial')
        : '';

    queries.add(
      "trashed = false and mimeType = '$mimeType' and 'me' in owners$specialSuffix",
    );

    queries.add(
      "trashed = false and mimeType = '$mimeType' and sharedWithMe = true$specialSuffix",
    );

    final Set<String> seenIds = {};

    try {
      for (final fullQuery in queries) {
        String? pageToken;
        do {
          Log.drive.log('Query: $fullQuery');
          FileList list = await driveApi!.files.list(
            q: fullQuery,
            spaces: 'drive',
            pageToken: pageToken,
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
            orderBy: 'modifiedTime desc',
            $fields: 'nextPageToken, files($fields)',
          );
          if (list.files != null && list.files!.isNotEmpty) {
            List<File> uniqueFiles = [];
            for (File file in list.files!) {
              logFile(' list', file);

              if (file.id != null && seenIds.add(file.id!)) {
                uniqueFiles.add(file);
              }
            }
            if (uniqueFiles.isNotEmpty) {
              Log.drive.log(
                'PURPLE: $this list files Count = ${uniqueFiles.length}',
              );
              int count = 0;
              for (File file in uniqueFiles) {
                count++;
                logFile(' list $count', file);
              }
              yield uniqueFiles;
            }
          }
          pageToken = list.nextPageToken;
        } while (pageToken != null && pageToken.isNotEmpty);
      }
    } catch (err) {
      Log.drive.log('PURPLE: $this Error listFiles: $err');
      await _handleAuthError(err);
      rethrow;
    }
  }

  Future<void> logUser() async {
    if (user == null) {
      Log.drive.log('User is null');
      return;
    }
    bool signedin = false;
    Log.drive.log('user = $user');
    Log.drive.log('signed in = $signedin');
    Log.drive.log('email = ${user!.email}');
    Log.drive.log('id = ${user!.id}');
    Log.drive.log('photo = ${user!.photoUrl}');
    Log.drive.log('name = ${user!.displayName}');
    Log.drive.log('hash = ${user!.hashCode}');
    var auth = user!.authentication;
    Log.drive.log('id token = ${auth.idToken}');
  }

  Future<void> logClient(String t, auth.AuthClient? client) async {
    Log.drive.log('PURPLE: $t client = $client');
    if (client == null) return;

    var creds = client.credentials;
    Log.drive.log('credentials = $creds');
    Log.drive.log('token = ${creds.accessToken}, id=${creds.idToken}');
    Log.drive.log('refresh=${creds.refreshToken}');
    Log.drive.log('scopes = ${creds.scopes}');
  }

  void logFile(String s, File? file) {
    if (file == null) {
      Log.drive.log('PURPLE: $s, null file.');
      return;
    }
    Log.drive.log('PURPLE: $s, file.id = ${file.id}');
    Log.drive.log('  name = ${file.name}');
    Log.drive.log('  description = ${file.description}');
    Log.drive.log('  modifiedTime = ${file.modifiedTime}');
    Log.drive.log(
      '  kind = ${file.kind}, size = ${file.size}, version = ${file.version}',
    );
    Log.drive.log('  mimeType = ${file.mimeType}');
    if (file.owners != null) {
      for (User user in file.owners!) {
        Log.drive.log('      Owner: ${user.displayName}, ${user.emailAddress}');
      }
    }
    if (file.permissions != null) {
      for (Permission p in file.permissions!) {
        Log.drive.log('     Permission: ${p.displayName}');
      }
    }
    if (file.capabilities != null) {
      FileCapabilities c = file.capabilities!;
      Log.drive.log(
        '      canComment = ${c.canComment}, canDelete = ${c.canDelete}'
        ', canEdit=${c.canEdit}, canModifyContent=${c.canModifyContent}.',
      );
    }
    if (file.linkShareMetadata != null) {
      Log.drive.log(' link = ${file.linkShareMetadata}');
    }
    if (file.contentHints != null) {
      Log.drive.log(' content hint = ${file.contentHints}');
    }
    if (file.webViewLink != null) {
      Log.drive.log(' webviewlink = ${file.webViewLink}');
    }
    if (file.resourceKey != null) {
      Log.drive.log(' resourceKey = ${file.resourceKey}');
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
    Log.drive.log('Fetching the CircleAvatar.');
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

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'DAW-$_debugId';

  DriveAuthorizeWidget(this.access, this.callback, {super.key});

  @override
  State<DriveAuthorizeWidget> createState() {
    return DriveAuthorizeWidgetState();
  }
}

class DriveAuthorizeWidgetState extends State<DriveAuthorizeWidget> {
  StreamSubscription? _statusListener;
  bool _authorized = false;
  bool _rememberMe = true;
  bool _isPopped = false;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'S$_debugId-$widget';

  DriveAuthorizeWidgetState() {
    Log.drive.log('ORANGE: Create new drive auth widget state $_debugId.');
  }

  void _pop(bool result) {
    if (_isPopped) return;
    _isPopped = true;
    widget.callback(result);
  }

  @override
  void initState() {
    super.initState();
    _rememberMe = widget.access.rememberMe;
    _statusListener = widget.access.statusStream().listen((status) {
      Log.drive.log('Auth listener: heard status = $status');
      setState(() {
        _authorized = widget.access.status == DriveAccessStatus.authorized;
        if (_authorized) {
          _pop(true);
        }
      });
    });
  }

  @override
  void dispose() {
    _statusListener?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthorizeScopes() async {
    if (widget.access.user == null) {
      Log.drive.log(
        'PURPLE: User is null when requesting scopes. Triggering sign in.',
      );
      await widget.access.handleSignIn();
      return;
    }
    bool authorized = await widget.access.requestScopes();
    Log.drive.log(
      'PURPLE: handle authorized state now has authorized =  $authorized',
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
      Log.drive.log('PURPLE: save tokens.');
    } catch (e) {
      Log.drive.log('RED: Error saving tokens: $e');
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
      Log.drive.log('PURPLE: save user info.');
    } catch (e) {
      Log.drive.log('RED: Error saving user info: $e');
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
      Log.drive.log('RED: Error reading user info: $e');
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
        Log.drive.log('PURPLE: loaded tokens.');
        return {
          'access_token': accessToken,
          'refresh_token': ?refreshToken,
          'id_token': ?idToken,
          'expiry_date': expiryDateString,
        };
      }
    } catch (e) {
      Log.drive.log('RED: Error reading tokens: $e');
    }
    return null;
  }

  static Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'id_token');
      await _storage.delete(key: 'expiry_date');
      Log.drive.log('PURPLE: cleared credentials.');
    } catch (e) {
      Log.drive.log('RED: Error clearing credentials: $e');
    }
  }

  static Future<void> clearTokens() async {
    try {
      await clearCredentials();
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'user_display_name');
      await _storage.delete(key: 'user_photo_url');
      Log.drive.log('PURPLE: cleared tokens.');
    } catch (e) {
      Log.drive.log('RED: Error clearing tokens: $e');
    }
  }
}
