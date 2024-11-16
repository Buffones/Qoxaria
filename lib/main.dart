// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/features/auth/services/microsoft_auth.dart';
import 'package:qoxaria/features/forge/widgets/forge_installation_widget.dart';
import 'package:qoxaria/features/modpack/widgets/modpack_installation_widget.dart';
import 'package:qoxaria/features/modpack/widgets/version_widget.dart';

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
        debugShowCheckedModeBanner: false,
        title: 'Qoxaria',
        theme: ThemeData(
          textTheme: TextTheme(
              bodyMedium: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
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
    final response =
        await http.get(Uri.parse('https://qoxaria.buffones.com/version'));
    if (response.statusCode == 200) {
      return QoxariaVersion.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load version.');
    }
  }
}


class LoadingPage extends StatelessWidget {
  final String text;
  const LoadingPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(bottom: 16), child: Text(text)),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}


class ErrorPage extends StatelessWidget {
  final String text;
  const ErrorPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          textAlign: TextAlign.center,
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            backgroundColor: Colors.black,
            height: 2,
          ),
        ),
      ],
    ));
  }
}


class LandingPage extends StatelessWidget {
  final QoxariaVersion version;

  const LandingPage({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 75),
          ModpackInstallationWidget(version: version),
          VersionWidget(version: version),
        ]
      ),
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Stack(children: [
        Image.asset(
          'assets/background.jpg',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
        FutureBuilder<QoxariaVersion>(
          future: appState.futureVersion,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LoadingPage(text: 'Fetching version from the server...');
            }
            if (snapshot.hasError) {
              return const ErrorPage(text: 'Error fetching version from the server.\nApp not available.');
            }
            return LandingPage(version: snapshot.data!);
          }
        )
      ]),
    );
        // Padding(
        //   padding: const EdgeInsets.all(16),
          // child: Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Image.asset('assets/logo.png', height: 75),
          //       FutureBuilder<QoxariaVersion>(
          //           future: appState.futureVersion,
          //           builder: (context, snapshot) {
          //             if (!snapshot.hasData) {
          //               return Positioned(child: const LoadingPage(text: 'Fetching version from the server...'), bottom: 16, left: 16);
          //             }

          //             if (snapshot.hasError) {
          //               return const ErrorPage(text: 'Error fetching version from the server.\nApp not available.');
          //             }

          //             return LandingPage(version: snapshot.data!);
          //           }),
          //       /*           ElevatedButton(
          //         onPressed: () => MicrosoftAuth().authenticate(),
          //         child: Text('Login with Microsoft'),
          //       ), */
          //       ElevatedButton(
          //         onPressed: () async {
          //           final process = await Process.start(
          //             'cmd.exe',
          //             [
          //               '/c',
          //               'C:\\XboxGames\\Minecraft Launcher\\Content\\Minecraft.exe',
          //             ],
          //             // [],
          //             // ['-jar', installerFilePath, '--installClient', _getMinecraftDataPath()],
          //             mode: ProcessStartMode.normal,
          //           );
          //           process.stdout.transform(utf8.decoder).listen((data) {
          //             print(data);
          //           });

          //           process.stderr.transform(utf8.decoder).listen((data) {
          //             print(data);
          //           });
          //           int exitCode = await process.exitCode;
          //           print(exitCode);
          //         },
          //         child: Text('Open Launcher'),
          //       ),
          //     ],
          //   ),
    //       ),
    //     ),
    //   ]),
    // );
  }
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 75),
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
                    ));
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
                                  Text(
                                      'Minecraft: ${snapshot.data!.minecraft}'),
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
                }),
            ElevatedButton(
              onPressed: () => MicrosoftAuth().authenticate(),
              child: Text('Login with Microsoft'),
            ),
            ElevatedButton(
              onPressed: () async {
                final process = await Process.start(
                  'cmd.exe',
                  [
                    '/c',
                    'C:\\XboxGames\\Minecraft Launcher\\Content\\Minecraft.exe',
                  ],
                  // [],
                  // ['-jar', installerFilePath, '--installClient', _getMinecraftDataPath()],
                  mode: ProcessStartMode.normal,
                );
                process.stdout.transform(utf8.decoder).listen((data) {
                  print(data);
                });

                process.stderr.transform(utf8.decoder).listen((data) {
                  print(data);
                });
                int exitCode = await process.exitCode;
                print(exitCode);
              },
              child: Text('Open Launcher'),
            ),
          ],
        ),
      ),
    );
  }
}
