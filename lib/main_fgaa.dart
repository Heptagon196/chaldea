import 'package:flutter/widgets.dart';

import 'app/chaldea.dart';
import 'app/modules/home/bootstrap/startup_failed_page.dart';
import 'main.dart' show initializeChaldeaForHost;
import 'fgaa/settings_web.dart';

/// Local Chaldea module inside the FGAA shell; the shell owns app updates/window.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeChaldeaForHost(storagePath: 'web');
    installHostSettingsBridge();
    runApp(Chaldea(embedded: true));
  } catch (error, stack) {
    runApp(StartupFailedPage(error: error, stackTrace: stack, wrapApp: true));
  }
}
