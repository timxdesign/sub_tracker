import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppBackupFileStore {
  AppBackupFileStore({
    this.backupFileName = 'subscription_tracker_backup.json',
    Future<Directory> Function()? appSupportDirectory,
    Future<Directory?> Function()? downloadsDirectory,
  }) : _appSupportDirectory =
           appSupportDirectory ?? getApplicationSupportDirectory,
       _downloadsDirectory = downloadsDirectory ?? getDownloadsDirectory;

  final String backupFileName;
  final Future<Directory> Function() _appSupportDirectory;
  final Future<Directory?> Function() _downloadsDirectory;

  Future<File> writeSnapshot(Map<String, dynamic> snapshot) async {
    final directory = await _appSupportDirectory();
    await directory.create(recursive: true);

    final file = File(
      '${directory.path}${Platform.pathSeparator}$backupFileName',
    );
    await file.writeAsString(jsonEncode(snapshot));
    return file;
  }

  Future<File> exportSnapshot(Map<String, dynamic> snapshot) async {
    final source = await writeSnapshot(snapshot);
    final targetDirectory =
        await _downloadsDirectory() ?? await _appSupportDirectory();
    await targetDirectory.create(recursive: true);

    final target = File(
      '${targetDirectory.path}${Platform.pathSeparator}$backupFileName',
    );
    if (source.path == target.path) {
      return source;
    }

    if (await target.exists()) {
      await target.delete();
    }
    return source.copy(target.path);
  }

  Future<Map<String, dynamic>> readSnapshotFromFile(File file) async {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Invalid backup file.');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
