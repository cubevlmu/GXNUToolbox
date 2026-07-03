import 'package:class_tool/utils/storage_utils.dart';
import 'package:get/get.dart';

class DebugTimeService extends GetxService {
  static const String _clientTimeOverrideKey = 'debug_client_time_override';

  final Rxn<DateTime> clientTimeOverride = Rxn<DateTime>(
    _loadClientTimeOverride(),
  );

  DateTime get now => clientTimeOverride.value ?? DateTime.now();
  bool get hasOverride => clientTimeOverride.value != null;

  Future<void> setClientTimeOverride(DateTime value) async {
    clientTimeOverride.value = value;
    await StorageUtils.settings.put(
      _clientTimeOverrideKey,
      value.toIso8601String(),
    );
  }

  Future<void> clearClientTimeOverride() async {
    clientTimeOverride.value = null;
    await StorageUtils.settings.delete(_clientTimeOverrideKey);
  }

  static DateTime? _loadClientTimeOverride() {
    final raw = StorageUtils.settings.get(_clientTimeOverrideKey)?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
