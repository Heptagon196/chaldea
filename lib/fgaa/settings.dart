import '../models/userdata/local_settings.dart';

Map<String, bool> readHostSettings(LocalSettings settings) => {
  'autoUpdateData': settings.network.autoUpdateData,
  'updateDataBeforeStart': settings.network.updateDataBeforeStart,
  'checkDataHash': settings.network.checkDataHash,
  'forceOnline': settings.network.forceOnline,
  'alertUploadUserData': settings.network.alertUploadUserData,
  'api': settings.network.proxy.api,
  'worker': settings.network.proxy.worker,
  'data': settings.network.proxy.data,
  'atlasApi': settings.network.proxy.atlasApi,
  'atlasAsset': settings.network.proxy.atlasAsset,
};

void patchHostSettings(LocalSettings settings, Map<String, dynamic> patch) {
  final allowed = readHostSettings(settings).keys.toSet();
  if (patch.entries.any((entry) => !allowed.contains(entry.key) || entry.value is! bool)) {
    throw const FormatException('Invalid host setting');
  }
  final values = {...readHostSettings(settings), ...patch.cast<String, bool>()};
  final network = settings.network;
  network.autoUpdateData = values['autoUpdateData']!;
  network.updateDataBeforeStart = values['updateDataBeforeStart']!;
  network.checkDataHash = values['checkDataHash']!;
  network.forceOnline = values['forceOnline']!;
  network.alertUploadUserData = values['alertUploadUserData']!;
  network.proxy.api = values['api']!;
  network.proxy.worker = values['worker']!;
  network.proxy.data = values['data']!;
  network.proxy.atlasApi = values['atlasApi']!;
  network.proxy.atlasAsset = values['atlasAsset']!;
}
