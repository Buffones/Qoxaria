import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:path_provider/path_provider.dart';
import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:http/http.dart' as http;

/* 
  TODO: Refactor a little bit for cleaner code!
 */


const filesToExclude = ['.gitignore', 'README.md'];
const zipballUrl =
    "https://api.github.com/repos/n-ull/qoxaria-modpack/zipball";


class ModpackInstallationService {
  final QoxariaVersion version;
  String? _filePath;

  ModpackInstallationService({required this.version});

  Future<void> download(String folder) async {
    final http.Response response = await http.get(Uri.parse('$zipballUrl/${version.modpack}'));

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
      filePath, folder
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

    final zipFile = File(zipPath);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    logger.info(zipPath);
    logger.info(Platform.pathSeparator);
    logger.info(zipPath.split(Platform.pathSeparator).last);
    final prefixLength = archive.first.name.length;
    for (final file in archive) {
      final filename = file.name.substring(prefixLength);
      final filePath = '$outputDir/$filename';

      if (file.isFile) {
        logger.fine(file.name.split('/').last);
        if (filesToExclude.contains(file.name.split('/').last)) {
          continue;
        }
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else {
        final directory = Directory(filePath);
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
        }
        await Directory(filePath).create(recursive: true);
      }
    }

    logger.fine('Modpack extracted to: $outputDir');

    try {
      zipFile.deleteSync();
    } on FileSystemException {
      logger.warning("Couldn't delete modpack zip file. Might have been deleted already!");
    }
  }
}
