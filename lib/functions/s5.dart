import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/definitions/logger.dart';
import 'package:vup_chat/main.dart';

Future<void> initS5() async {
  if (!kIsWeb) {
    Directory appDir = await getApplicationCacheDirectory();
    await Directory(join(appDir.path, 'db')).create(recursive: true);
    Hive.init(join(appDir.path, 'db'));
    final nowInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final lastEightDigits = nowInMilliseconds
        .toString()
        .substring(nowInMilliseconds.toString().length - 8);
    await Directory(join(appDir.path, "logs")).create(recursive: true);
    s5 = await S5.create(
        logger: FileLogger(
            file: join(appDir.path, 'logs', 'log-$lastEightDigits.txt')));
  } else {
    Hive.init("db");
    s5 = await S5.create();
  }
}
