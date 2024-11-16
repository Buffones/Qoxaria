import 'package:flutter/material.dart';
import 'package:qoxaria/features/launcher/services/minecraft_launcher_service.dart';

class LauncherWidget extends StatefulWidget {
  const LauncherWidget({super.key});

  @override
  LauncherWidgetState createState() => LauncherWidgetState();
}


class LauncherWidgetState extends State<LauncherWidget> {
  late bool _hasLauncher;
  late bool _hasMultiMc;
  late final MinecraftLauncherService _service;

  @override
  void initState() {
    super.initState();
    _service = MinecraftLauncherService();
    _hasLauncher = _service.isInstalled();
    _hasMultiMc = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ElevatedButton(
        onPressed: _hasLauncher ? _service.open : null,
        child: const Text('Open Launcher'),
      ),
      ElevatedButton(
        onPressed: _hasMultiMc ? _service.open : null,
        child: const Text('Open MultiMC'),
      ),
    ]);
  }
}
