import 'dart:io';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/configuration.dart';
import 'package:qoxaria/features/launcher/services/launcher_service_mixin.dart';
import 'package:qoxaria/utils/files.dart';


const multiMcUrls = {
  'windows': 'https://files.multimc.org/downloads/mmc-develop-win32.zip',
  'linux': 'https://files.multimc.org/downloads/mmc-develop-lin64.tar.gz',
};


class MultiMCLauncherService extends LauncherService {
  @override
  final name = 'MultiMC';

  final MultiMCConfiguration configuration;

  MultiMCLauncherService({required this.configuration});


  @override
  Future<void> download(String outputFilename) async {
    logger.fine('Downloading MultiMC.');
    String url;
    if (Platform.isWindows) {
      url = multiMcUrls['windows']!;
    } else if (Platform.isLinux) {
      url = multiMcUrls['linux']!;
    } else {
      throw UnsupportedError('${Platform.operatingSystem} is not a supported platform.');
    }
    
    await downloadFile(url, outputFilename);
    logger.fine('MultiMC downloaded successfully.');
  }

  @override
  Future<void> install() async {
    final directory = await getTempDirectory();
    final format = Platform.isWindows ? 'zip' : 'tar.gz';
    final downloadFilename = '${directory.path}${Platform.pathSeparator}mmc.$format';
    await download(downloadFilename);
    await unzipFile(downloadFilename, configuration.path, shouldDelete: true, isPrefixed: true);
  }

  @override
  String getPath() {
    String path = '${configuration.path}${Platform.pathSeparator}MultiMC';
    if (Platform.isWindows) path += '.exe';
    return path;
  }
}
