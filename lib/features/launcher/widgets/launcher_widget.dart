import 'package:flutter/material.dart';
import 'package:qoxaria/features/launcher/services/minecraft_launcher_service.dart';
import 'package:qoxaria/features/launcher/services/multimc_launcher_service%20copy.dart';

class LauncherWidget extends StatefulWidget {
  const LauncherWidget({super.key});

  @override
  LauncherWidgetState createState() => LauncherWidgetState();
}


class LauncherWidgetState extends State<LauncherWidget> {
  late bool _hasLauncher;
  late bool _hasMultiMc;
  late final MinecraftLauncherService _minecraftService;
  late final MultiMCLauncherService _multiMcService;

  @override
  void initState() {
    super.initState();
    _minecraftService = MinecraftLauncherService();
    _multiMcService = MultiMCLauncherService();
    _hasLauncher = _minecraftService.isInstalled();
    _hasMultiMc = _multiMcService.isInstalled();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ElevatedButton(
        onPressed: _hasLauncher ? _minecraftService.open : null,
        child: const Text('Open Launcher'),
      ),
      ElevatedButton(
        onPressed: _hasMultiMc ? _multiMcService.open : null,
        child: const Text('Open MultiMC'),
      ),
    ]);
  }
}
