import 'package:flutter_test/flutter_test.dart';
import 'package:chaldea/fgaa/settings.dart';
import 'package:chaldea/models/userdata/local_settings.dart';

void main() {
  test('host settings use original mirror fields and reject invalid patches before mutation', () {
    final settings = LocalSettings();
    final before = readHostSettings(settings);
    expect(() => patchHostSettings(settings, {'data': true, 'secrets': true}), throwsFormatException);
    expect(readHostSettings(settings), before);
    expect(() => patchHostSettings(settings, {'data': 'true'}), throwsFormatException);
    patchHostSettings(settings, {'data': true, 'atlasAsset': true, 'autoUpdateData': false});
    expect(settings.network.proxy.data, true);
    expect(settings.network.proxy.atlasAsset, true);
    expect(settings.network.autoUpdateData, false);
    expect(settings.network.proxy.api, before['api']);
    expect(readHostSettings(settings).containsKey('secrets'), false);
  });
}
