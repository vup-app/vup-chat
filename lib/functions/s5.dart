import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lib5/constants.dart';
import 'package:lib5/identity.dart';
import 'package:lib5/registry.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s5/s5.dart';
import 'package:vup_chat/definitions/logger.dart';
import 'package:vup_chat/main.dart';
import 'package:vup_chat/messenger/connections/native.dart';
import 'package:vup_chat/widgets/restart_widget.dart';

Future<S5> initS5() async {
  // if in a state with a seed but a broken session, should attempt to log in, and if it fails it
  // should try again without the seed.
  return _initS5();

  // this is a bad way to do things
  // try {
  //   return await _initS5();
  // } catch (e) {
  //   logger.e(e);
  //   await logOutS5NoRestart();
  //   return await _initS5();
  // }
}

// The internal init function
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
        logger: kDebugMode
            // logger: false
            ? FileLogger(
                file: join(await getLogPath(),
                    'log-$lastEightDigits.txt')) // If in debug mode I want everything dumped to stdout
            : FileLogger(
                file: join(await getLogPath(), 'log-$lastEightDigits.txt')));
    return s5;
  } else {
    Hive.init("db");
    final S5 s5 = await S5.create();
    return s5;
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

Future<void> backupSQLiteToS5() async {
  String? seed = await secureStorage.read(key: "seed");
  // TODO: Implement backups for web
  if (msg.s5 != null && msg.s5!.hasIdentity && seed != null && !kIsWeb) {
    S5 s5 = msg.s5!;
    // First we gotta upload the DB
    File db = await databaseFile;
    CID staticCID = await s5.api.uploadBlob(db.readAsBytesSync());

    // Then we get get an set the resolver
    final resolverSeed = s5.api.crypto.hashBlake3Sync(
      Uint8List.fromList(
        validatePhrase(seed, crypto: s5.api.crypto) +
            utf8.encode("VUP_CHAT_DB_BACKUP_KEY"), // this identifies the backup
      ),
    );

    final s5User = await s5.api.crypto.newKeyPairEd25519(seed: resolverSeed);

    SignedRegistryEntry? existing;

    try {
      final res = await s5.api.registryGet(s5User.publicKey);
      existing = res;
      logger.d(
        'Revision ${existing!.revision} -> ${existing.revision + 1}',
      );
    } catch (e) {
      existing = null;

      logger.d('Revision 1');
    }

    final sre = await signRegistryEntry(
      kp: s5User,
      data: staticCID.toRegistryEntry(),
      revision: (existing?.revision ?? -1) + 1,
      crypto: s5.api.crypto,
    );

    await s5.api.registrySet(sre);

    final resolverCID = CID(
        cidTypeResolver,
        Multihash(
          Uint8List.fromList(
            s5User.publicKey,
          ),
        ));
    logger.d(resolverCID);
  }
}
