import 'dart:io';

import 'package:lib5/util.dart';
import 'package:vup_chat/main.dart';

class FileLogger extends Logger {
  final String file;

  FileLogger({required this.file});

  // for now this is the only function I'm over-writing
  @override
  Future<void> info(String s) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(s);
    await sink.close();
  }

  @override
  void error(String s) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(s);
    await sink.close();
  }

  @override
  void verbose(String s) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(s);
    await sink.close();
  }

  @override
  void warn(String s) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(s);
    await sink.close();
  }

  @override
  void catched(e, st, [context]) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(e.toString() + (context == null ? '' : ' [$context]'));
    sink.write(st.toString());
    await sink.close();
  }
}

/// Logger only intended for debug logging, pipes warnings to file,
/// evething else goes to stdout
class DebugLogger extends Logger {
  final String file;

  DebugLogger({required this.file});

  @override
  Future<void> info(String s) async {
    logger.d(s);
  }

  @override
  void error(String s) async {
    logger.d(s);
  }

  @override
  void verbose(String s) async {
    logger.d(s);
  }

  // S5 is very spammy on the warn calls, so I'm dumping this to a file
  @override
  void warn(String s) async {
    final sink = File(file).openWrite(mode: FileMode.append);
    sink.write(s);
    await sink.close();
  }

  @override
  void catched(e, st, [context]) async {
    logger.d(e);
  }
}

void logLongMessage(String message) {
  const int chunkSize = 1000; // Set chunk size
  for (int i = 0; i < message.length; i += chunkSize) {
    logger.d(message.substring(
        i, i + chunkSize > message.length ? message.length : i + chunkSize));
  }
}
