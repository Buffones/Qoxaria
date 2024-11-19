import 'dart:io';

import 'package:qoxaria/utils/files.dart';


enum Workflow { unknown, modpackOnly, multiMC }


class MultiMCConfiguration {
  String path;
  String javaPath;
  int minMemory;
  int maxMemory;

  MultiMCConfiguration({
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
  String modpackVersion;
  Workflow workflow;
  final MultiMCConfiguration multiMC;

  Configuration({required this.modpackVersion, required this.multiMC, required this.workflow});

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      modpackVersion: json['modpackVersion'],
      multiMC: MultiMCConfiguration.fromJson(json['multiMC']),
      workflow: _workflowFromString(json['workflow']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modpackVersion': modpackVersion,
      'multiMC': multiMC.toJson(),
      'workflow': workflow.name,
    };
  }

  factory Configuration.fromDefaults() {
    return Configuration(
      modpackVersion: '',
      multiMC: MultiMCConfiguration.fromDefaults(),
      workflow: Workflow.unknown,
    );
  }

  static Workflow _workflowFromString(String? workflowName) {
    try {
      return Workflow.values.firstWhere((w) => w.name == workflowName);
    } catch (e) {
      return Workflow.unknown;
    }
  }
}
