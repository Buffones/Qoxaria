import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:qoxaria/core/logger.dart';
import 'package:qoxaria/core/models/configuration.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/core/repositories/configuration_repository.dart';
import 'package:qoxaria/core/screens/error_screen.dart';
import 'package:qoxaria/core/screens/landing_screen.dart';
import 'package:qoxaria/core/screens/loading_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    const windowInitialWidth = 800.0;
    const windowInitialHeight = 600.0;
    final windowInfo = await getWindowInfo();
    if (windowInfo.screen != null) {
      final screenFrame = windowInfo.screen!.visibleFrame;
      final left = (screenFrame.width - windowInitialWidth) / 2 + screenFrame.left;
      final top = (screenFrame.height - windowInitialHeight) / 4 + screenFrame.top;
      setWindowFrame(Rect.fromLTWH(left, top, windowInitialWidth, windowInitialHeight));
    }
    setWindowMinSize(const Size(458, 458));
  }
  setupLogging();
  AppLifecycleObserver();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: ToastificationWrapper(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Qoxaria',
          theme: ThemeData(
            textTheme: TextTheme(
                bodyMedium: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
          ),
          home: const MyHomePage(),
        ),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  late Future<QoxariaVersion> futureVersion;
  late Configuration configuration;

  MyAppState() {
    configuration = ConfigurationRepository().load();
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

  void updateMultiMCPath(String newPath) {
    configuration.multiMC.path = newPath;
    notifyListeners();
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
              return const LoadingScreen(text: 'Fetching version from the server...');
            }
            if (snapshot.hasError) {
              return const ErrorScreen(text: 'Error fetching version from the server.\nApp not available.');
            }
            return LandingScreen(version: snapshot.data!);
          }
        )
      ]),
    );
  }
}


class AppLifecycleObserver with WindowListener {
  AppLifecycleObserver() {
    windowManager.addListener(this);
  }

  @override
  Future<bool> onWindowClose() async {
    logger.fine('App is closing!');
    await saveAppState();
    return true;
  }

  Future<void> saveAppState() async {
    final context = MyApp.navigatorKey.currentContext;
    if (context == null) {
      logger.warning("Context is null, can't save configurations.");
      return;
    }
    final appState = Provider.of<MyAppState>(context, listen: false);
    logger.info("Saving state...");
    ConfigurationRepository().store(appState.configuration);
  }
}
