import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../models/db.dart';
import 'settings.dart';

/// Only the same-origin embedding parent can read/update the public settings subset.
void installHostSettingsBridge() {
  Future<void> pending = Future.value();
  web.window.addEventListener('message', ((web.MessageEvent event) {
    if (event.source != web.window.parent || event.origin != web.window.location.origin) return;
    final data = event.data.dartify();
    if (data is! String || data.length > 16384) return;
    dynamic request;
    try { request = jsonDecode(data); } catch (_) { return; }
    if (request is! Map || request['type'] != 'fgaa.chaldea.settings' || request['version'] != 1
        || request['id'] is! String || (request['id'] as String).length > 80) return;
    pending = pending.then((_) async {
      String? error;
      try {
        if (request['operation'] == 'patch') {
          if (request['values'] is! Map<String, dynamic>) throw const FormatException();
          final before = readHostSettings(db.settings);
          patchHostSettings(db.settings, request['values']);
          try {
            await db.saveSettings(rethrowErrors: true);
          } catch (_) {
            patchHostSettings(db.settings, before);
            rethrow;
          }
          db.notifySettings();
        } else if (request['operation'] != 'read') {
          throw const FormatException();
        }
      } catch (_) { error = 'settings_failed'; }
      web.window.parent?.postMessage(jsonEncode({
        'type': 'fgaa.chaldea.settings.result', 'version': 1, 'id': request['id'],
        if (error != null) 'error': error,
        if (error == null) 'values': readHostSettings(db.settings),
      }).toJS, web.window.location.origin.toJS);
    });
  }).toJS);
}
