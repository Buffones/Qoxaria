import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/modpack/widgets/modpack_installation_widget.dart';
import 'package:qoxaria/main.dart';


class ModpackWidget extends StatefulWidget {
  final QoxariaVersion version;
  final bool useMultiMCDir;

  const ModpackWidget({super.key, required this.version, this.useMultiMCDir = false});

  @override ModpackWidgetState createState() => ModpackWidgetState();
}


class ModpackWidgetState extends State<ModpackWidget> {
  bool _isUpToDate = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<MyAppState>(context, listen: false);
    _isUpToDate = appState.configuration.modpackVersion == widget.version.modpack;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUpToDate) {
      return ModpackInstallationWidget(version: widget.version, onInstall: _onInstall, useMultiMCDir: widget.useMultiMCDir);
    }
    return const Text('Modpack is up to date');
  }

  void _onInstall() {
    if (!mounted) return;
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.updateVersion(widget.version.modpack);
    setState(() => _isUpToDate = true);
  }
}
