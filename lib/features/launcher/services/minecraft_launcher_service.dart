import 'dart:io';

import 'package:qoxaria/features/launcher/services/launcher_service_mixin.dart';


class MinecraftLauncherService extends LauncherService {
  @override
  final name = 'MinecraftLauncher';

  @override
  String getPath() {
    if (Platform.isWindows) {
      return 'C:\\XboxGames\\Minecraft Launcher\\Content\\Minecraft.exe';
    }
    if (Platform.isLinux) {
      return '';
    }
    throw '${Platform.operatingSystem} is not a supported platform.';
  }

  @override
  Future<void> download(String outputFilename) async {
    print("Downloading");
  }

  @override
  Future<void> install() async {
    await download('');
  }
}
