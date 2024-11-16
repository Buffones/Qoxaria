import 'package:flutter/material.dart';
import 'package:qoxaria/features/launcher/services/launcher_service_mixin.dart';
import 'package:qoxaria/features/launcher/services/minecraft_launcher_service.dart';
import 'package:qoxaria/features/launcher/services/multimc_launcher_service.dart';
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
    _minecraftService = MinecraftLauncherService();
    _multiMcService = MultiMCLauncherService();
    _isInstalled = {
      'MinecraftLauncher': _minecraftService.isInstalled(),
      'MultiMC': _multiMcService.isInstalled()
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildButton(_minecraftService),
      Padding(padding: EdgeInsets.only(top: 8), child: _buildButton(_multiMcService)),
    ]);
  }

  _buildButton(LauncherService service) {
    Future<void> Function()? onPressed;
    Text text;
    if (_isInstalled[service.name]!) {
      onPressed = service.open;
      text = Text('Open ${service.name}');
    } else {
      onPressed = _installing[service.name]! ? null : () async => await _install(service);
      text = Text('Install ${service.name}');
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
}
