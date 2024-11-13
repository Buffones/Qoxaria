
import 'package:flutter/material.dart';
import 'package:qoxaria/core/logger.dart';

import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/forge/services/forge_installation_service.dart';


class ForgeInstallationWidget extends StatefulWidget {
  final QoxariaVersion version;

  const ForgeInstallationWidget({super.key, required this.version});

  @override ForgeInstallationWidgetState createState() => ForgeInstallationWidgetState();
}


class ForgeInstallationWidgetState extends State<ForgeInstallationWidget> {
  double progress = 0.0;
  List<String> logMessages = [];
  final ScrollController _scrollController = ScrollController();
  late final ForgeInstallationService _service;

  void updateProgress(double newProgress) {
    setState(() { progress = newProgress; });
  }

  void addLog(String message) {
    setState(() { logMessages.add(message); });
    _scrollToBottom();
  }

  void setLog(String message) {
    setState(() { logMessages = [message]; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
   _service = ForgeInstallationService(version: widget.version);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        children: [
          TextButton(
            child: const Text('Install Forge'),
            onPressed: () async {
              try {
                logMessages.clear();
                await _service.fullInstall(onLog, onError);
              } on ForgeInstallerException catch(e) {
                onError(e.toString());
              }
            }
          ),
          LinearProgressIndicator(value: progress / 100),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Container(
                padding: EdgeInsets.all(20),
                color: Color(0XFF000000),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: logMessages.length,
                  itemBuilder: (context, index) {
                    return Text(
                      logMessages[index],
                      style: TextStyle(
                        color: Color(0xFF4AF626),
                      ),
                    );
                  },
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  onLog(String data) {
    addLog(data);
    if (data.contains('Successfully installed client into launcher.')) {
      updateProgress(100);
      setLog('Forge was correctly installed.');
    }
  }

  onError(String data) {
    print("\n\nLAST: ${logMessages.last}\n\n");
    if (logMessages.last.toLowerCase().contains("there is no minecraft launcher profile")) {
      logger.warning("Couldn't install Forge. Profile not found.");
      setLog(
        "ERROR: Couldn't install Forge.\n"
        'No profile found. You need to setup Minecraft through this installer first.'
        'Or provide a Minecraft folder already set up.'
      );
    } else {
      addLog("ERROR: $data\nCouldn't install Forge.");
    }
  }
}
