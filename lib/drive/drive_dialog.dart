import 'dart:async';

import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import '../file_manager.dart';
import '../printer.dart';
import '../recent_file.dart';
import 'drive_auth.dart';
import 'drive_service.dart';

class DriveTab extends OneTab {
  final FileManager manager;
  DriveTab(bool load, this.manager, RecentFiles recent, {super.key})
    : super('Google Drive', load, recent);
  @override
  State<OneTab> createState() => DriveState();

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'DT$_debugId';
}

class DriveState extends State<DriveTab> {
  static String searchQuery = '';
  static List<String> lastFetchedNames = [];
  late TextEditingController _searchController;
  Timer? _debounceTimer;

  bool _initialized = false;
  bool _active = true;
  bool _authorized = false;
  int _fetchId = 0;
  List<File> files = [];
  late MyDriveAccess access;
  StreamSubscription? _statusListener;

  static int _debugCounter = 0;
  final int _debugId = ++_debugCounter;
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      'DTS$_debugId-$widget';

  DriveState();

  @override
  void initState() {
    super.initState();
    access = widget.manager.driveAccess;
    _searchController = TextEditingController(text: searchQuery);
    Log.drive.log('Init State for Drive tabs..');
    initialize();
  }

  Future<void> initialize() async {
    bool authorized = await access.checkAuthorization();
    setState(() {
      _authorized = authorized;
      _initialized = true;
    });
    if (authorized) fetchFiles();
    _statusListener = access.statusStream().listen((status) {
      Log.drive.log('Auth listener: heard status = $status');
      setState(() {
        _authorized = access.status == DriveAccessStatus.authorized;
      });
      if (_authorized && files.isEmpty) {
        fetchFiles();
      }
    });
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_active && mounted) {
        fetchFiles();
      }
    });
  }

  void fetchFiles() async {
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
        Log.drive.log('Processing list $result');
        if (!_active || _fetchId != currentFetchId) break;
        setState(() {
          files.addAll(result);
          lastFetchedNames = files
              .map((f) => f.name ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
        });
      }
    } catch (e) {
      Log.drive.log('Error fetching files: $e');
    }
  }

  @override
  void dispose() {
    Log.drive.log('MAGENTA: dispose $this.');
    _statusListener?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _active = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Log.drive.log('build $this, authorized = $_authorized');
    if (!_initialized) return const Text('Checking login...');
    if (!_authorized) {
      return DriveAuthorizeWidget(
        access,
        (bool result) => setState(() {
          Log.drive.log('PURPLE: $this drive authorized called callback.');
          _authorized = result;
          if (_authorized) fetchFiles();
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
              widget.load ? 'Load from Drive' : 'Save to Drive',
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
                hintText: 'Search by title or query (e.g. owner:me)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
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
          if (!widget.load)
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
                    Log.drive.log('CYAN: drive file make new.');
                    DriveHolder holder = DriveHolder.create();
                    Navigator.of(context).pop(holder);
                    Log.drive.log('CYAN: After pop - new file.');
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.file_open),
                      SizedBox(width: 8),
                      Expanded(child: Text('New File')),
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
    if (file.owners == null || file.owners!.isEmpty) return '-no owner-';

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
        String desc = owner.displayName ?? owner.emailAddress ?? '';
        if (owner.displayName != null &&
            owner.emailAddress != null &&
            owner.displayName != owner.emailAddress) {
          desc = '${owner.displayName} (${owner.emailAddress})';
        }
        if (desc.isNotEmpty) {
          otherOwners.add(desc);
        }
      }
    }

    if (isOwnedByMe) return null;
    if (otherOwners.isEmpty) return null;
    return otherOwners.join(', ');
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
            holder.title = file.name ?? '-unknown name-';
            holder.file = file;
            access.logFile('Chose this file', file);

            Log.drive.log('CYAN: drive file $holder.');
            Navigator.of(context).pop(holder);
            Log.drive.log('CYAN: After pop - load/save drive file.');
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
                        'Modified: $modified',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (owner != null)
                      Text(
                        'Owner: $owner',
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
