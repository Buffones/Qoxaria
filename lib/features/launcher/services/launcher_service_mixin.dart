import 'dart:convert';
import 'dart:io';

import 'package:qoxaria/core/logger.dart';

abstract class LauncherService {
  String getPath();

  bool isInstalled() {
    return File(getPath()).existsSync();
  }

  Future<void> open() async {
    final process = await Process.start(
      getPath(),
      [],
      mode: ProcessStartMode.normal,
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      logger.fine('Launcher (Output): $data');
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      logger.warning('Launcher (Error): $data');
    });

    int exitCode = await process.exitCode;
    logger.fine('Minecraft Launcher was successfully started with exit code $exitCode');
  }

}
