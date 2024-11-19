
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qoxaria/core/models/configuration.dart';

import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/launcher/widgets/multi_mc_launcher_widget.dart';
import 'package:qoxaria/features/modpack/widgets/modpack_installation_widget.dart';
import 'package:qoxaria/features/modpack/widgets/version_widget.dart';
import 'package:qoxaria/main.dart';


class LandingScreen extends StatelessWidget {
  final QoxariaVersion version;

  const LandingScreen({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    Widget child;
    switch (appState.configuration.workflow) {
      case Workflow.multiMC:
        child = Column(children: [
          MultiMCLauncherWidget(),
          ModpackInstallationWidget(version: version, useMultiMCDir: true),
        ]);
      case Workflow.modpackOnly:
        child = ModpackInstallationWidget(version: version);
      default:
        child = WorkflowChoosingWidget();
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 75),
          Padding(padding: const EdgeInsets.all(8), child: child),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              if (appState.configuration.workflow != Workflow.unknown)
                WorkflowWidget(),
              VersionWidget(version: version),
            ]
          ),
        ]
      ),
    );
  }
}


class WorkflowChoosingWidget extends StatelessWidget {
  const WorkflowChoosingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    return Column(children: [
      const Text('Choose Workflow'),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => appState.updateWorkflow(Workflow.multiMC),
              child: const Text('MultiMC'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilledButton(
                onPressed: () => appState.updateWorkflow(Workflow.modpackOnly),
                child: const Text('Modpack only'),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}


class WorkflowWidget extends StatelessWidget {
  const WorkflowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    return Column(
      children: [
        const Text('Workflow'),
        Text(
          'Current: ${_getWorkflowName(appState.configuration.workflow)}',
          style: TextStyle(fontSize: 12),
        ),
        FilledButton(
          onPressed: () => appState.updateWorkflow(Workflow.unknown),
          child: const Text('Change'),
        ),
      ]
    );
  }

  String _getWorkflowName(Workflow workflow) {
    switch (workflow) {
      case Workflow.multiMC:
        return 'Multi MC';
      case Workflow.modpackOnly:
        return 'Modpack only';
      default:
        return 'Unknown';
    }
  }
}
