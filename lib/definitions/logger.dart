import 'dart:io';

import 'package:lib5/util.dart';

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
