import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';


class RequestException implements Exception {
  final String url;
  final int statusCode;
  final http.Response response;

  const RequestException({required this.url, required this.statusCode, required this.response});
}


class MissingFileException implements Exception {
  final String filePath;

  const MissingFileException({required this.filePath});
}


class ForgeInstallerException implements Exception {
  final int exitCode;
  final Process process;

  const ForgeInstallerException({required this.exitCode, required this.process});
}


class ForgeInstallationService {
  static const forgeBaseFilename = 'forge-{minecraft_version}-{forge_version}-installer.jar';
  static const forgeBaseUrl = 'https://maven.minecraftforge.net/net/minecraftforge/forge/{minecraft_version}-{forge_version}';
  final QoxariaVersion version;
  String? _filePath;

  ForgeInstallationService({required this.version});

  Future<String> _getFilePath() async {
    if (_filePath == null) {
      final filename = _getVersionFormattedString(forgeBaseFilename);
      final directory = await _getTempDirectory();
      _filePath = '${directory.path}/$filename';
    }
    return _filePath!;
  }

  String _getVersionFormattedString(String baseString) {
    return
      baseString
      .replaceAll('{minecraft_version}', '${version.minecraft}')
      .replaceAll('{forge_version}', '${version.forge}');
  }

  Future<Directory> _getTempDirectory() async {
    Directory directory;
    try {
      directory = await getTemporaryDirectory();
    } on MissingPlatformDirectoryException catch (e) {
      directory = Directory('${await getApplicationDocumentsDirectory()}/tmp');
      logger.info("Couldn't find temporary directory: $e\nCreated $directory to be used instead.");
    }
    return directory;
  }

  String _getDownloadUrl() {
    final filename = _getVersionFormattedString(forgeBaseFilename);
    return '${_getVersionFormattedString(forgeBaseUrl)}/$filename';
  }

  Future<void> download() async {
    final url = _getDownloadUrl();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      logger.severe('Failed to download Forge installer from $url');
      throw RequestException(url: url, statusCode: response.statusCode, response: response);
    }

    final filePath = await _getFilePath();
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    logger.info('Forge installer downloaded to: $filePath');
  }

  Future<void> cleanup() async {
    final file = File(await _getFilePath());
    if (file.existsSync()) {
      file.deleteSync();
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final customTempDirectory = Directory('${documentsDirectory.path}${Platform.pathSeparator}tmp');
    if (!customTempDirectory.existsSync()) return;
    try {
      customTempDirectory.deleteSync();
    } on FileSystemException {
      logger.fine("Couldn't delete $customTempDirectory. It might not exist.");
      return;
    }
  }

  Future<void> install([Function(String)? onLog, Function(String)? onError]) async {
    final installerFilePath = await _getFilePath();
    final file = File(installerFilePath);
    if (!file.existsSync()) {
      logger.severe("Can't install Forge. Installer file missing at $installerFilePath. Try downloading.");
      throw MissingFileException(filePath: installerFilePath);
    }

    final process = await Process.start(
      'java',
      ['-jar', installerFilePath, '--installClient', _getMinecraftDataPath()],
      mode: ProcessStartMode.normal,
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      if (onLog != null) {
        onLog(data);
      }
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      if (onError != null) {
        onError(data);
      }
    });

    int exitCode = await process.exitCode;

    if (exitCode == 0) {
      logger.fine('Forge installer executed successfully.');
    } else {
      logger.severe('Forge installer exited with error code: $exitCode');
      throw ForgeInstallerException(exitCode: exitCode, process: process);
    }
  }

  Future<void> fullInstall([Function(String)? onLog, Function(String)? onError]) async {
    if (!File(await _getFilePath()).existsSync()) {
      logger.fine('Forge Installer not found. Downloading...');
      await download();
    }
    await install(onLog, onError);
    await cleanup();
  }

  String _getMinecraftDataPath() {
    String minecraftPath;
    if (Platform.isWindows) {
      minecraftPath = '${Platform.environment['USERPROFILE']}\\AppData\\Roaming\\Qoxaria';
    } else if (Platform.isMacOS || Platform.isLinux) {
      minecraftPath = '${Platform.environment['HOME']}/.local/share/Qoxaria';
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} not supported.');
    }
    return minecraftPath;
  }
}
