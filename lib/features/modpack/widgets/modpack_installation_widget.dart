import 'package:flutter/material.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/modpack/services/modpack_installation_service.dart';

/* 
  TODO: Add a progress indicator for the download and extraction process
  TODO: Add a button to select the installation path
  TODO: Add a button to select between minecraft and multimc
 */

class ModpackInstallationWidget extends StatefulWidget {
  final QoxariaVersion version;

  const ModpackInstallationWidget({super.key, required this.version});

  @override
  ModpackInstallationWidgetState createState() =>
      ModpackInstallationWidgetState();
}

class ModpackInstallationWidgetState extends State<ModpackInstallationWidget> {
  late final ModpackInstallationService _serivce;

  @override
  void initState() {
    super.initState();
    _serivce = ModpackInstallationService(version: widget.version);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Modpack Installation'),
      ElevatedButton(
        onPressed: () {
          _serivce.download();
        },
        child: Text('Install Modpack'),
      ),
    ]);
  }
}
