import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/utils/files.dart';

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

  Future<String> download() async {
    final filePath = await _getFilePath();
    try {
      downloadFile('$zipballUrl/${version.modpack}', filePath);
    } on DownloadFailedException catch(e) {
      logger.severe('Failed to download modpack, statusCode: ${e.response.statusCode}');
      rethrow;
    }
    logger.fine('Modpack downloaded to: $filePath');
    return filePath;
  }

  Future<void> install(filePath, outputDir) async {
    await unzipFile(filePath, outputDir, filesToExclude: filesToExclude, isPrefixed: true, shouldDelete: true);
    logger.fine('Modpack extracted to: $outputDir');
  }

  Future<void> fullInstall(String outputDir) async {
    final filePath = await download();
    await install(filePath, outputDir);
  }

  Future<String> _getFilePath() async {
    if (_filePath == null) {
      final directory = await getTempDirectory();
      _filePath = '${directory.path}/qoxaria-modpack.zip';
    }
    return _filePath!;
  }

  Future<void> __unzipFile(String zipPath, String outputDir) async {
    final zipFile = File(zipPath);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final prefixLength = archive.first.name.length;
    for (final file in archive) {
      final filename = file.name.substring(prefixLength);
      if (filename == '') continue;

      final filePath = '$outputDir/$filename';

      if (file.isFile) {
        logger.fine(file.name.split('/').last);
        if (filesToExclude.contains(file.name.split('/').last)) {
          continue;
        }
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content as List<int>);
      } else if (file.name != Platform.pathSeparator) {
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
