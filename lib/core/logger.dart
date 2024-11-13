import 'package:logging/logging.dart';


final Logger logger = Logger('Qoxaria');


void setupLogging() {
  // TODO: Make this configurable through the env or something (during relase?)!
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] (${record.time}) : ${record.message}');
  });
}
