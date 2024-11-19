import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/utils/files.dart';

/* 
  TODO: Refactor a little bit for cleaner code!
 */


const filesToExclude = ['.gitignore', 'README.md', 'xaerominimap-common.txt', 'xaerominimap.txt'];
const zipballUrl =
    "https://api.github.com/repos/n-ull/qoxaria-modpack/zipball";
// We want to download config folder if not present, but avoid overwriting
// any existing files from there, so we don't mess with users' settings.
const protectedFolders = [];


class ModpackInstallationService {
  final QoxariaVersion version;
  String? _filePath;

  ModpackInstallationService({required this.version});

  Future<String> download() async {
    final filePath = await _getFilePath();
    try {
      await downloadFile('$zipballUrl/${version.modpack}', filePath);
    } on DownloadFailedException catch(e) {
      logger.severe('Failed to download modpack, statusCode: ${e.response.statusCode}');
      rethrow;
    }
    logger.fine('Modpack downloaded to: $filePath');
    return filePath;
  }

  Future<void> install(filePath, outputDir) async {
    await unzipFile(
      filePath,
      outputDir,
      filesToExclude: filesToExclude,
      isPrefixed: true,
      shouldDelete: true,
      prefixesToExclude: protectedFolders,
    );
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
}
