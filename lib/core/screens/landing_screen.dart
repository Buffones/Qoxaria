
import 'package:flutter/material.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/launcher/widgets/multi_mc_launcher_widget.dart';
import 'package:qoxaria/features/modpack/widgets/modpack_installation_widget.dart';
import 'package:qoxaria/features/modpack/widgets/version_widget.dart';


class LandingScreen extends StatelessWidget {
  final QoxariaVersion version;

  const LandingScreen({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 75),
          Padding(padding: EdgeInsets.all(8), child: MultiMCLauncherWidget()),
          Padding(padding: EdgeInsets.all(8), child: ModpackInstallationWidget(version: version)),
          VersionWidget(version: version),
        ]
      ),
    );
  }
}
