import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/tools/app_window.dart';
import 'package:chaldea/packages/home_widget.dart';

import 'app/chaldea.dart';
import 'app/modules/common/blank_page.dart';
import 'app/modules/home/bootstrap/startup_failed_page.dart';
import 'models/db.dart';
import 'packages/analysis/analysis.dart';
import 'packages/network.dart';
import 'packages/packages.dart';
import 'packages/split_route/split_route.dart';
import 'utils/catcher/catcher_util.dart';
import 'utils/catcher/server_feedback_handler.dart';
import 'utils/http_override.dart';
import 'utils/notification.dart';
import 'utils/utils.dart';
import 'models/userdata/version.dart';
import 'packages/app_info.dart';

Future<void>? _hostInitialization;

/// Initializes data/services once without taking ownership of the host window.
/// The host must expose Chaldea's original res/ assets and own app lifecycle.
Future<void> initializeChaldeaForHost({required String storagePath}) {
  return _hostInitialization ??= _initializeForHost(storagePath);
}

Future<void> _initializeForHost(String storagePath) async {
  WidgetsFlutterBinding.ensureInitialized();
  db.paths.hostRootPath = storagePath;
  AppInfo.moduleVersion = AppVersion.tryParse('2.6.2+992');
  await _initiateCommon(embedded: true);
  await db.initiate();
}

void main() async {
  // make sure flutter packages like path_provider is working now
  WidgetsFlutterBinding.ensureInitialized();
  dynamic initError, initStack;
  Catcher2Options? catcherOptions;
  try {
    await _initiateCommon();
    await db.initiate();
    AppAnalysis.instance.initiate();
    // Silent migration of legacy Worker tokens now runs in
    // _ChaldeaState.afterFirstLayout() — after the first frame renders, so the
    // user never sees a black screen and the app stays interactive.
    catcherOptions = CatcherUtil.getOptions(
      logPath: db.paths.crashLog,
      feedbackHandler: ServerFeedbackHandler(
        screenshotController: db.runtimeData.screenshotController,
        screenshotPath: joinPaths(db.paths.tempDir, 'crash.jpg'),
        attachments: [db.paths.appLog, db.paths.crashLog, db.paths.userDataPath],
        onGenerateAttachments: () => {
          'userdata.memory.json': Uint8List.fromList(utf8.encode(jsonEncode(db.userData))),
          'settings.memory.json': Uint8List.fromList(utf8.encode(jsonEncode(db.settings))),
        },
      ),
    );
  } catch (e, s) {
    initError = e;
    initStack = s;
    try {
      logger.e('initiate app failed at startup', e, s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
  final app = initError == null ? Chaldea() : StartupFailedPage(error: initError, stackTrace: initStack, wrapApp: true);
  if (kDebugMode) {
    runApp(app);
  } else {
    Catcher2(
      rootWidget: app,
      debugConfig: catcherOptions,
      profileConfig: catcherOptions,
      releaseConfig: catcherOptions,
      navigatorKey: kAppKey,
      ensureInitialized: true,
      enableLogger: kDebugMode,
    );
  }
}

Future<void> _initiateCommon({bool embedded = false}) async {
  if (!embedded) await AppWindowUtil.init();

  LicenseRegistry.addLicense(() async* {
    Map<String, String> licenses = {
      'MOONCELL': 'res/license/CC-BY-NC-SA-4.0.txt',
      'FANDOM': 'res/license/CC-BY-SA-3.0.txt',
      'Atlas Academy': 'res/license/ODC-BY 1.0.txt',
    };
    for (final entry in licenses.entries) {
      String license = await rootBundle.loadString(entry.value).catchError((e, s) async {
        logger.e('load license(${entry.key}, ${entry.value}) failed.', e, s);
        return 'load license failed';
      });
      yield LicenseEntryWithLineBreaks([entry.key], license);
    }
  });
  network.init();
  if (!kIsWeb) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  SplitRoute.defaultMasterFillPageBuilder = (context) => const BlankPage();
  await LocalNotificationUtil.init();

  if (!embedded) HomeWidgetX.init();
}
