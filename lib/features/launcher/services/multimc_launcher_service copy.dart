import 'dart:io';

import 'package:qoxaria/features/launcher/services/launcher_service_mixin.dart';


class MultiMCLauncherService extends LauncherService {
  @override
  String getPath() {
    if (Platform.isWindows) {
      return (
        'C:\\Users\\franp\\AppData\\Local\\Microsoft\\WinGet\\Packages\\'
        'MultiMC.MultiMC_Microsoft.Winget.Source_8wekyb3d8bbwe\\MultiMC\\MultiMC.exe'
      );
    }
    if (Platform.isLinux) {
      return '';
    }
    throw '${Platform.operatingSystem} is not a supported platform.';
  }
}
