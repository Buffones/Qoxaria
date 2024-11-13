
import 'package:flutter/material.dart';

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
  final ForgeInstallationService _service = ForgeInstallationService();

  void updateProgress(double newProgress) {
    setState(() { progress = newProgress; });
  }

  void addLog(String message) {
    setState(() { logMessages.add(message); });
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          child: const Text('Download Forge'),
          onPressed: () async {
            await _service.download(widget.version);
          }
        ),
        TextButton(
          child: const Text('Install Forge'),
          onPressed: () async {
            await _service.install();
            await _service.cleanup();
          }
        ),
        LinearProgressIndicator(value: progress / 100),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: logMessages.length,
            itemBuilder: (context, index) {
              return Text(logMessages[index]);
            },
          ),
        ),
      ],
    );
  }
}
