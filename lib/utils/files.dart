import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:qoxaria/core/logger.dart';


class DownloadFailedException implements Exception {
  final String url;
  final http.Response response;

  const DownloadFailedException({required this.url, required this.response});
}


Future<void> downloadFile(String url, String outputFilename) async {
  final http.Response response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw DownloadFailedException(url: url, response: response);
  }

  final file = File(outputFilename);
  await file.writeAsBytes(response.bodyBytes);
}


Future<Directory> getTempDirectory() async {
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


Future<void> uncompressFile(
  String compressedPath,
  String outputDir,
  {
    List<String> filesToExclude = const [],
    List<String> prefixesToExclude = const [],
    bool isPrefixed = false,
    bool shouldDelete = false,
  }
) async {
  final zipFile = File(compressedPath);
  final bytes = await zipFile.readAsBytes();
  final archive = _decodeArchiveFromBytes(compressedPath, bytes);
  final prefixLength = isPrefixed ? archive.first.name.length : 0;
  for (final file in archive) {
    final filename = isPrefixed ? file.name.substring(prefixLength) : file.name;
    // The first entry yield is the folder prefix itself,
    // skip it to avoid deleting the whole outputDir
    if (filename == '') continue;

    final isProtectedFile = prefixesToExclude.any((p) => filename.startsWith(p));
    final outputPath = '$outputDir/$filename';
    if (file.isFile) {
      if (filesToExclude.contains(file.name.split('/').last)) continue;

      final outputFile = File(outputPath);
      if (outputFile.existsSync() && isProtectedFile) continue;
      outputFile
        ..createSync(recursive: true)
        ..writeAsBytesSync(file.content as List<int>);
    } else {
      logger.info(filename);
      logger.info(isProtectedFile);
      final directory = Directory(outputPath);

      // Delete existing folders so all their content is changed with those from the zip
      if (directory.existsSync() && !isProtectedFile) {
        directory.deleteSync(recursive: true);
      }
      if (!directory.existsSync()) {
        await Directory(outputPath).create(recursive: true);
      }
    }
  }

  if (shouldDelete) {
    try {
      zipFile.deleteSync();
    } on FileSystemException {
      logger.warning("Couldn't delete zip file: $compressedPath. Might have been deleted already!");
    }
  }
}


Archive _decodeArchiveFromBytes(String filePath,Uint8List bytes) {
  if (filePath.endsWith('.zip')) {
    return ZipDecoder().decodeBytes(bytes);
  } else if (filePath.endsWith('.tar.gz')) {
    return TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
  }
  throw UnsupportedError("Can't uncompress file $filePath since format is not supported.");
}


String getProgramsDirectory() {
  if (Platform.isWindows) {
    return '${Platform.environment['USERPROFILE']}\\AppData\\Local\\Programs';
  } else if (Platform.isLinux) {
    return '${Platform.environment['HOME']}/.local/share';
  }
  throw UnsupportedError('Platform ${Platform.operatingSystem} not supported.');
}


String getConfigurationsDirectory() {
  if (Platform.isWindows) {
    return '${Platform.environment['USERPROFILE']}\\AppData\\Roaming';
  } else if (Platform.isLinux) {
    return '${Platform.environment['HOME']}/.config';
  }
  throw UnsupportedError('Platform ${Platform.operatingSystem} not supported.');
}
