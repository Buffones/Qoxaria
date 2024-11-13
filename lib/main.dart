import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/auth/services/microsoft_auth.dart';
import 'package:qoxaria/features/forge/widgets/forge_installation_widget.dart';


void main() {
  setupLogging();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Qoxaria',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  late Future<QoxariaVersion> futureVersion;

  MyAppState() {
    futureVersion = fetchVersion();
  }

  Future<QoxariaVersion> fetchVersion() async {
    final response = await http
      .get(Uri.parse('https://qoxaria.buffones.com/version'));
    if (response.statusCode == 200) {
      return QoxariaVersion.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load version.');
    }
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text(
            'Qoxaria',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            )
          ),
          FutureBuilder<QoxariaVersion>(
            future: appState.futureVersion,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fetching version from the server...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        'Error fetching version from the server.\nApp not available.',
                      ),
                    ],
                  )
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 650,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 10.0,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Minecraft: ${snapshot.data!.minecraft}'),
                              Text('Forge: ${snapshot.data!.forge}'),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Modpack: ${snapshot.data!.modpack}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ForgeInstallationWidget(version: snapshot.data!),
                ],
              );
            }
          ),

          ElevatedButton(
            onPressed: () => MicrosoftAuth().authenticate(),
            child: Text('Login with Microsoft'),
          ),
        ],
      ),
    );
  }
}
