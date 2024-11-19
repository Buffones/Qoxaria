import 'dart:io';

import 'package:qoxaria/utils/files.dart';

class MultiMCConfiguration {
  final String path;
  final String javaPath;
  final int minMemory;
  final int maxMemory;

  const MultiMCConfiguration({
    required this.path,
    required this.javaPath,
    required this.minMemory,
    required this.maxMemory,
  });

  factory MultiMCConfiguration.fromJson(Map<String, dynamic> json) {
    return MultiMCConfiguration(
      path: json['path'],
      javaPath: json['javaPath'],
      minMemory: json['minMemory'],
      maxMemory: json['maxMemory'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'javaPath': javaPath,
      'minMemory': minMemory,
      'maxMemory': maxMemory,
    };
  }

  factory MultiMCConfiguration.fromDefaults() {
    return MultiMCConfiguration(
      path: _getDefaultPath(),
      javaPath: _getDefaultJavaPath(),
      minMemory: 1024,
      maxMemory: 2048,
    );
  }

  static String _getDefaultPath() {
    final sep = Platform.pathSeparator;
    return '${getProgramsDirectory()}${sep}Qoxaria${sep}MultiMC';
  }

  static String _getDefaultJavaPath() {
    return '';
  }
}


class Configuration {
  final String modpackVersion;
  final MultiMCConfiguration multiMC;

  const Configuration({required this.modpackVersion, required this.multiMC});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      modpackVersion: json['modpackVersion'],
      multiMC: MultiMCConfiguration.fromJson(json['multiMC']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modpackVersion': modpackVersion,
      'multiMC': multiMC.toJson(),
    };
  }

  factory Configuration.fromDefaults() {
    return Configuration(
      modpackVersion: '',
      multiMC: MultiMCConfiguration.fromDefaults(),
    );
  }
}
