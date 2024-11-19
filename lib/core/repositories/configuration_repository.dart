import 'dart:convert';
import 'dart:io';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/configuration.dart';
import 'package:qoxaria/utils/files.dart';


class ConfigurationRepository {
  late final String filePath;

  ConfigurationRepository([String? filePath]) {
    this.filePath = filePath ?? _getDefaultFilePath();
  }

  static String _getDefaultFilePath() {
    final sep = Platform.pathSeparator;
    return '${getConfigurationsDirectory()}${sep}Qoxaria${sep}config.json';
  }

  Configuration load() {
    try {
      final fileContents = File(filePath).readAsStringSync();
      final Map<String, dynamic> json = jsonDecode(fileContents);
      return Configuration.fromJson(json);
    } catch (e) {
      logger.warning('Configurations not found in $filePath, falling back to defaults.');
      return Configuration.fromDefaults();
    }
  }
}
