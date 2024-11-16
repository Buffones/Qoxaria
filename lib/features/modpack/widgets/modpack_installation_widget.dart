import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/modpack/services/modpack_installation_service.dart';
import 'package:toastification/toastification.dart';


/* 
  TODO: Add a progress indicator for the download and extraction process
  TODO: Add a button to select between minecraft and multimc
 */


class ModpackInstallationWidget extends StatefulWidget {
  final QoxariaVersion version;

  const ModpackInstallationWidget({super.key, required this.version});

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
    return Column(children: [
      Text('Modpack Installation', style: TextStyle(fontSize: 18)),
      ElevatedButton(
        onPressed: _pickFolder,
        child: Text('Pick a Folder'),
      ),
      if (_folderPath != null)
        Text('Selected folder: $_folderPath', style: TextStyle(fontSize: 14)),
      if (_folderPath == null)
        Text('No folder selected', style: TextStyle(fontSize: 14)),
      
      Padding(
        padding: EdgeInsets.only(top: 8),
        child: ElevatedButton(
          onPressed: (_folderPath != null && !_installing) ? () async => await _install() : null,
          child: Text('Install Modpack'),
        ),
      ),
    ]);
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
      setState(() => _installing = false);
    }
  }
}
