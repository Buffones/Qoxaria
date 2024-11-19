import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoxaria/core/models/configuration.dart';
import 'package:qoxaria/features/launcher/services/launcher_service_mixin.dart';
import 'package:qoxaria/features/launcher/services/minecraft_launcher_service.dart';
import 'package:qoxaria/features/launcher/services/multimc_launcher_service.dart';
import 'package:qoxaria/main.dart';
import 'package:toastification/toastification.dart';

class LauncherWidget extends StatefulWidget {
  const LauncherWidget({super.key});

  @override
  LauncherWidgetState createState() => LauncherWidgetState();
}


class LauncherWidgetState extends State<LauncherWidget> {
  late final MinecraftLauncherService _minecraftService;
  late final MultiMCLauncherService _multiMcService;
  late Map<String, bool> _isInstalled;
  final _installing = {'MinecraftLauncher': false, 'MultiMC': false};

  @override
  void initState() {
    super.initState();
    // final appState = Provider.of<MyAppState>(context);
    _minecraftService = MinecraftLauncherService();
    _multiMcService = MultiMCLauncherService(configuration: MultiMCConfiguration.fromDefaults());
    _isInstalled = {
      'MinecraftLauncher': _minecraftService.isInstalled(),
      'MultiMC': _multiMcService.isInstalled()
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final multiMCFolder = appState.configuration.multiMC.path;
    return Column(children: [
      // _buildButton(_minecraftService),
      Text('MultiMC', style: TextStyle(fontSize: 18)),
      FilledButton(
        onPressed: _pickMultiMCFolder,
        child: Text('Pick a Folder'),
      ),
      Text('Selected folder: $multiMCFolder', style: TextStyle(fontSize: 14)),
      Padding(padding: EdgeInsets.only(top: 8), child: _buildButton(_multiMcService)),
    ]);
  }

  _buildButton(LauncherService service) {
    Future<void> Function()? onPressed;
    Text text;
    if (_isInstalled[service.name]!) {
      onPressed = service.open;
      text = Text('Open');
    } else {
      onPressed = _installing[service.name]! ? null : () async => await _install(service);
      text = Text('Install');
    }
    return FilledButton(onPressed: onPressed, child: text);
  }

  Future<void> _install(LauncherService service) async {
    setState(() {
      _installing[service.name] = true;
    });
    toastification.show(
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 7),
      title: const Text('Installation started'),
      description: Text('${service.name} is being downloaded and installed.'),
    );
    try {
      await service.install();
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: Text('${service.name} installed.'),
        description: Text('${service.name} installed successfully.'),
      );
      setState(() => _isInstalled[service.name] = true);
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 7),
        title: Text('${service.name} installation failed'),
        description: Text("Couldn't install ${service.name}.\n$e"),
      );
    } finally {
      setState(() => _installing[service.name] = false);
    }
  }

  Future<void> _pickMultiMCFolder() async {
    if (!mounted) return;
    final appState = Provider.of<MyAppState>(context, listen: false);

    final folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      _multiMcService.configuration.path = folderPath;
      appState.updateMultiMCPath(folderPath);
      setState(() => _isInstalled['MultiMC'] = _multiMcService.isInstalled());
    }
  }
}
