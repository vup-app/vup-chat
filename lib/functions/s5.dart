import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:lib5/identity.dart';
import 'package:lib5/node.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/definitions/logger.dart';
import 'package:vup_chat/main.dart';

Future<void> initS5() async {
  if (!kIsWeb) {
    Hive.init(await getHiveDBPath());
    final nowInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final lastEightDigits = nowInMilliseconds
        .toString()
        .substring(nowInMilliseconds.toString().length - 8);
    s5 = await S5.create(
        logger: FileLogger(
            file: join(await getLogPath(), 'log-$lastEightDigits.txt')));
  } else {
    Hive.init("db");
    s5 = await S5.create();
  }
}

Future<void> logInS5(String seed, String nodeURL) async {
  validatePhrase(seed, crypto: s5.api.crypto);
  await s5.recoverIdentityFromSeedPhrase(seed);
  final nodeOfChoice = nodeURL.isEmpty ? "https://s5.ninja" : nodeURL;
  await s5.registerOnNewStorageService(
    nodeOfChoice,
  );
}

void logOutS5() async {
  Directory(await getHiveDBPath()).delete(recursive: true);
}

Future<String> getHiveDBPath() async {
  if (!kIsWeb) {
    Directory appDir = await getApplicationCacheDirectory();
    await Directory(join(appDir.path, 'db')).create(recursive: true);
    return join(appDir.path, 'db');
  } else {
    return "db";
  }
}

Future<String> getLogPath() async {
  if (!kIsWeb) {
    Directory appDir = await getApplicationCacheDirectory();
    await Directory(join(appDir.path, 'logs')).create(recursive: true);
    return join(appDir.path, 'logs');
  } else {
    return "db";
  }
}

Future<void> getAccountInfo() async {}
