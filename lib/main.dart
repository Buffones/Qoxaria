import 'dart:convert';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';


void main() {
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
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     // This is the theme of your application.
    //     //
    //     // TRY THIS: Try running your application with "flutter run". You'll see
    //     // the application has a purple toolbar. Then, without quitting the app,
    //     // try changing the seedColor in the colorScheme below to Colors.green
    //     // and then invoke "hot reload" (save your changes or press the "hot
    //     // reload" button in a Flutter-supported IDE, or press "r" if you used
    //     // the command line to start the app).
    //     //
    //     // Notice that the counter didn't reset back to zero; the application
    //     // state is not lost during the reload. To reset the state, use hot
    //     // restart instead.
    //     //
    //     // This works for code too, not just values: Most code changes can be
    //     // tested with just a hot reload.
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //   ),
    //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
    // );
  }
}


class Version {
  final int major;
  final int minor;
  final int patch;

  const Version({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
  });

  factory Version.fromString(String fullVersion) {
    final splitVersion = fullVersion.split('.');
    return Version(
      major: int.parse(splitVersion[0]),
      minor: int.parse(splitVersion[1]),
      patch: int.parse(splitVersion[2]),
    );
  }
}


class QoxariaVersion {
  final Version minecraft;
  final Version forge;
  final String modpack;

  const QoxariaVersion({
    required this.minecraft,
    required this.forge,
    required this.modpack,
  });

  factory QoxariaVersion.fromJson(Map<String, dynamic> json) {
    return switch(json) {
      {
        'minecraft': String minecraft,
        'forge': String forge,
        'modpack': String modpack,
      } =>
        QoxariaVersion(
          minecraft: Version.fromString(minecraft),
          forge: Version.fromString(forge),
          modpack: modpack
        ),
      _ => throw const FormatException('Failed to load version.'),
    };
  }
}


class ForgeInstallationWidget extends StatefulWidget {
  final QoxariaVersion version;

  const ForgeInstallationWidget({super.key, required this.version});

  @override _ForgeInstallationWidgetState createState() => _ForgeInstallationWidgetState();
}


class _ForgeInstallationWidgetState extends State<ForgeInstallationWidget> {
  double progress = 0.0;
  List<String> logMessages = [];
  final ScrollController _scrollController = ScrollController();

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
            final minecraftVersionString = '${widget.version.minecraft.major}.${widget.version.minecraft.minor}.${widget.version.minecraft.patch}';
            final forgeVersionString = '${widget.version.forge.major}.${widget.version.forge.minor}.${widget.version.forge.patch}';
            final forgeUri = (
              'https://maven.minecraftforge.net/net/minecraftforge/forge/'
              '$minecraftVersionString-$forgeVersionString/'
              'forge-$minecraftVersionString-$forgeVersionString-installer.jar'
            );
            await downloadFile(forgeUri);
            await installForge();
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

  Future<void> downloadFile(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/forge-installer.jar';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('File downloaded to $filePath');
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<void> installForge() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final forgeInstallerPath = '${directory.path}/forge-installer.jar';
      if (File(forgeInstallerPath).existsSync()) {
        final process = await Process.start(
          'java',
          ['-jar', forgeInstallerPath, '--installClient', 'C:\\Users\\franp\\AppData\\Roaming\\.minecraft'],
          mode: ProcessStartMode.normal,
        );

        process.stdout.transform(utf8.decoder).listen((data) {
          addLog(data);

          if (data.contains('Successfully installed client into launcher.')) {
            updateProgress(100);
          }
        });

        process.stderr.listen((data) {
          print(String.fromCharCodes(data));
        });

        int exitCode = await process.exitCode;

        if (exitCode == 0) {
          print('Forge installer executed successfully.');
        } else {
          print('Forge installer exited with error code: $exitCode');
        }
      } else {
        print('Forge installer file not found at $forgeInstallerPath');
      }
    } catch (e) {
      print('Error running Forge installer: $e');
    }
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


// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
