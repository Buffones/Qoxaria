import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
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
  var current = WordPair.random();
  late Future<QoxariaVersion> futureVersion;

  MyAppState() {
    futureVersion = fetchVersion();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
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
          const Text('A random idea:'),
          Text(appState.current.asLowerCase),

          ElevatedButton(
            onPressed: () {
              appState.getNext();
            },
            child: const Text('Next'),
          ),

          FutureBuilder<QoxariaVersion>(
            future: appState.futureVersion,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Fetching Qoxaria versions...');
              }
              return Container(constraints: BoxConstraints(maxHeight: 200), child: ForgeInstallationWidget(version: snapshot.data!));
            }
          ),

          FutureBuilder<QoxariaVersion>(
            future: appState.futureVersion,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minecraft: '
                      '${snapshot.data!.minecraft.major}.'
                      '${snapshot.data!.minecraft.minor}.'
                      '${snapshot.data!.minecraft.patch}'
                    ),
                    Text(
                      'Forge: '
                      '${snapshot.data!.forge.major}.'
                      '${snapshot.data!.forge.minor}.'
                      '${snapshot.data!.forge.patch}',
                    ),
                    Text('Modpack: ${snapshot.data!.modpack}'),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
