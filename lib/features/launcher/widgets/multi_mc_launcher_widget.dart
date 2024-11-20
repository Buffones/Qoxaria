import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoxaria/core/logger.dart';
import 'package:toastification/toastification.dart';


import 'package:qoxaria/features/launcher/services/multimc_launcher_service.dart';
import 'package:qoxaria/main.dart';


class MultiMCLauncherWidget extends StatefulWidget {
  const MultiMCLauncherWidget({super.key});

  @override
  MultiMCLauncherWidgetState createState() => MultiMCLauncherWidgetState();
}


class MultiMCLauncherWidgetState extends State<MultiMCLauncherWidget> {
  bool _installing = false;
  late MultiMCLauncherService _service;
  late bool _isInstalled;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<MyAppState>(context, listen: false);
    _service = MultiMCLauncherService(configuration: appState.configuration.multiMC);
    _installing = false;
    _isInstalled = _service.isInstalled();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final multiMCFolder = appState.configuration.multiMC.path;
    return Column(children: [
      Text('MultiMC', style: TextStyle(fontSize: 18)),
      FilledButton(
        onPressed: _pickMultiMCFolder,
        child: Text('Pick a Folder'),
      ),
      Text('Selected folder: $multiMCFolder', style: TextStyle(fontSize: 14)),
      if (!_isInstalled)
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: FilledButton(
            onPressed: _installing ? null : _install,
            child: const Text('Install'),
          )
        ),
      if (_isInstalled) const Text('Is installed', style: TextStyle(fontSize: 14)),
    ]);
  }

  Future<void> _install() async {
    setState(() {
      _installing = true;
    });
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 7),
      title: const Text('Installation started'),
      description: Text('MultiMC is being downloaded and installed.'),
    );
    try {
      await _service.install();
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: Text('MultiMC installed.'),
        description: Text('MultiMC installed successfully.'),
      );
      setState(() => _isInstalled = true);
    } catch (e) {
      logger.warning("Couldn't install MultiMC.\n$e");
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: Text('MultiMC installation failed'),
        description: Text("Couldn't install MultiMC.\n$e"),
      );
    } finally {
      setState(() => _installing = false);
    }
  }

  Future<void> _pickMultiMCFolder() async {
    if (!mounted) return;
    final appState = Provider.of<MyAppState>(context, listen: false);

    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      _service.configuration.path = folderPath;
      appState.updateMultiMCPath(folderPath);
      setState(() => _isInstalled = _service.isInstalled());
    }
  }
}
