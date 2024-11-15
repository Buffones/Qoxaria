import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:path_provider/path_provider.dart';
import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:http/http.dart' as http;

/* 
  TODO: Delete config, kubejs and mods folders before extracting the modpack
  TODO: Delete zip file after extracting
 */

const zipballUrl =
    "https://api.github.com/repos/n-ull/qoxaria-modpack/zipball/ ";

class ModpackInstallationService {
  final QoxariaVersion version;
  String? _filePath;

  ModpackInstallationService({required this.version});

  Future<void> download() async {
    final http.Response response = await http.get(Uri.parse(zipballUrl));

    final minecraftPath =
        '${Platform.environment['USERPROFILE']}\\AppData\\Roaming\\.minecraftata';

    if (response.statusCode != 200) {
      logger.severe(
          'Failed to download modpack, statusCode: ${response.statusCode}');
      throw Exception('Failed to download modpack');
    }

    final filePath = await _getFilePath();
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    logger.fine('Modpack downloaded to: $filePath');

    unzipFile(
      filePath, minecraftPath
    );
  }

  Future<void> install() async {}

  Future<String> _getFilePath() async {
    if (_filePath == null) {
      final directory = await _getTempDirectory();
      _filePath = '${directory.path}/qoxaria-modpack.zip';
    }
    return _filePath!;
  }

  Future<Directory> _getTempDirectory() async {
    Directory directory;
    try {
      directory = await getTemporaryDirectory();
    } on MissingPlatformDirectoryException catch (e) {
      directory = Directory('${await getApplicationDocumentsDirectory()}/tmp');
      logger.info(
          "Couldn't find temporary directory: $e\nCreated $directory to be used instead.");
    }
    return directory;
  }

  void unzipFile(String zipPath, String outputDir) async {
    // Read the Zip file as bytes
    final bytes = await File(zipPath).readAsBytes();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract each file
    for (final file in archive) {
      final filename = file.name;
      final filePath = '$outputDir/$filename';

      if (file.isFile) {
        // Write the file content to disk
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        // Create the directory
        await Directory(filePath).create(recursive: true);
      }
    }

    logger.fine('Modpack extracted to: $outputDir');
  }
}
