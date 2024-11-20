import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/modpack/services/modpack_installation_service.dart';
import 'package:qoxaria/main.dart';
import 'package:toastification/toastification.dart';


/* 
  TODO: Add a progress indicator for the download and extraction process
 */


const _instanceName = 'Qoxaria';


class ModpackInstallationWidget extends StatefulWidget {
  final QoxariaVersion version;
  final bool useMultiMCDir;

  const ModpackInstallationWidget({super.key, required this.version, this.useMultiMCDir = false});

  @override
  ModpackInstallationWidgetState createState() => ModpackInstallationWidgetState();
}


class ModpackInstallationWidgetState extends State<ModpackInstallationWidget> {
  late final ModpackInstallationService _service;
  String? _folderPath;
  bool _installing = false;


  @override
  void initState() {
    super.initState();
    _service = ModpackInstallationService(version: widget.version);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text('Modpack Installation', style: TextStyle(fontSize: 18)),
    ];
    if (widget.useMultiMCDir) {
      setState(() => _folderPath = _getPathForMultiMCVersion());
    } else {
      String text = _folderPath == null ? 'No folder selected' : 'Selected folder: $_folderPath';
      children.addAll([
        FilledButton(
          onPressed: _pickFolder,
          child: Text('Pick a Folder'),
        ),
        Text(text, style: TextStyle(fontSize: 14)),
      ]);
    }
    if (_folderPath != null && _service.versionFromDir(_folderPath!) == widget.version.modpack) {
      return const Text('Modpack is up to date.');
    }
    children.add(
      Padding(
        padding: EdgeInsets.only(top: 8),
        child: FilledButton(
          onPressed: (_folderPath != null && !_installing) ? () async => await _install() : null,
          child: Text('Install Modpack'),
        ),
      ),
    );
    return Column(children: children);
  }

  Future<void> _pickFolder() async {
    final folderPath = await FilePicker.platform.getDirectoryPath();
    setState(() => _folderPath = folderPath);
  }

  Future<void> _install() async {
    setState(() => _installing = true);
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 7),
      title: const Text('Installation started'),
      description: Text('Qoxaria Modpack is being downloaded and installed in $_folderPath'),
    );
    try {
      await _service.fullInstall(_folderPath!);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: const Text('Qoxaria Modpack installed.'),
        description: Text('Modpack installed successfully in $_folderPath'),
      );
      if (mounted) {
        final appState = Provider.of<MyAppState>(context, listen: false);
        appState.updateVersion(widget.version.modpack);
      }
      setState(() => _folderPath = null);
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: const Text('Qoxaria Modpack installation failed'),
        description: Text("Couldn't install the modpack.\n$e"),
      );
    } finally {
      if (mounted) setState(() => _installing = false);
    }
  }

  String _getPathForMultiMCVersion() {
    final appState = Provider.of<MyAppState>(context);
    final sep = Platform.pathSeparator;
    final multiMCFolder = appState.configuration.multiMC.path;
    return '$multiMCFolder${sep}instances$sep$_instanceName$sep.minecraft';
  }
}
