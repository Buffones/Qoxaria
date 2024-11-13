import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:qoxaria/core/logger.dart';


class MicrosoftAuth {
  late final String clientId;
  late final String redirectUri;

  MicrosoftAuth() {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    clientId = env['MICROSOFT_CLIENT_ID']!;
    redirectUri = env['MICROSOFT_REDIRECT_URI']!;
  }

  Future<void> authenticate() async {
    final authUrl = Uri.parse(
      'https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize'
      '?client_id=$clientId'
      '&response_type=code'
      '&redirect_uri=$redirectUri'
      '&response_mode=query'
      '&scope=offline_access%20XboxLive.SignIn'
    );
    if (!await canLaunchUrl(authUrl)) {
      logger.severe("Can't launch OAuth URL.");
      throw 'Could not launch $authUrl';
    }
    await launchUrl(authUrl);

    await startLocalServer();
  }

  Future<void> startLocalServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 6969);
    try {
      await for (HttpRequest request in server) {
        if (request.uri.path != '/qoxaria/auth') continue;
        String? code = request.uri.queryParameters['code'];
        if (code != null) {
          await _exchangeCodeForToken(code);
        } else {
          logger.severe('Code not found: ${request.uri}');
          await request.response.close();
          await server.close();
          throw "Couldn't exchange code";
        }
        request.response.write('You may now return to the application.');
        await request.response.close();
      }
    } finally {
      await server.close();
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    final url = Uri.parse('https://login.microsoftonline.com/consumers/oauth2/v2.0/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': clientId,
        'code': code,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (response.statusCode != 200) {
      logger.severe("Failed to get access token: ${response.body}");
      throw "Couldn't get access token.";
    }
    final jsonResponse = jsonDecode(response.body);
    String accessToken = jsonResponse['access_token'];
    logger.info("Access token: $accessToken");
  }
}
