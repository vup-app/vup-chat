import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lib5/identity.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/definitions/logger.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/widgets/restart_widget.dart';

Future<S5> initS5() async {
  // if in a state with a seed but a broken session, should attempt to log in, and if it fails it
  // should try again without the seed.
  try {
    return await _initS5();
  } catch (e) {
    logger.e(e);
    await logOutS5NoRestart();
    return await _initS5();
  }
}

Future<S5> _initS5() async {
  if (!kIsWeb) {
    Hive.init(await getHiveDBPath());
    final nowInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final lastEightDigits = nowInMilliseconds
        .toString()
        .substring(nowInMilliseconds.toString().length - 8);
    final S5 s5 = await S5.create(
        initialPeers: [
          'wss://z2DeVYsXdq3Rgt8252LRwNnreAtsGr3BN6FPc6Hvg6dTtRk@s5.jptr.tech/s5/p2p', // add my S5 node first
          'wss://z2Das8aEF7oNoxkcrfvzerZ1iBPWfm6D7gy3hVE4ALGSpVB@node.sfive.net/s5/p2p',
          'wss://z2DdbxV4xyoqWck5pXXJdVzRnwQC6Gbv6o7xDvyZvzKUfuj@s5.vup.dev/s5/p2p',
          'wss://z2DWuWNZcdSyZLpXFK2uCU3haaWMXrDAgxzv17sDEMHstZb@s5.garden/s5/p2p'
        ],
        logger: FileLogger(
            file: join(await getLogPath(), 'log-$lastEightDigits.txt')));
    return s5;
  } else {
    Hive.init("db");
    final S5 s5 = await S5.create();
    return s5;
  }
}

Future<void> logInS5(String seed, String nodeURL) async {
  if (s5 != null) {
    // Checks to make sure it is compliant with the S5 seed spec
    validatePhrase(seed, crypto: s5!.api.crypto);
    // make sure to persist this for later use
    await secureStorage.write(key: "seed", value: seed);
    preferences.setBool("disable-s5", false);
    await s5!.recoverIdentityFromSeedPhrase(seed);
    final nodeOfChoice = nodeURL.isEmpty ? "https://s5.ninja" : nodeURL;
    await s5!.registerOnNewStorageService(
      nodeOfChoice,
    );
  }
}

void logOutS5(BuildContext context) async {
  await secureStorage.delete(key: "seed");
  Directory(await getHiveDBPath()).delete(recursive: true);
  if (!context.mounted) return;
  RestartWidget.restartApp(context);
}

Future<void> logOutS5NoRestart() async {
  await secureStorage.delete(key: "seed");
  Directory(await getHiveDBPath()).delete(recursive: true);
}

Future<String> getHiveDBPath() async {
  if (!kIsWeb) {
    Directory appDir = await getApplicationSupportDirectory();
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
