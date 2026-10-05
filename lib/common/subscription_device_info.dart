typedef SubscriptionDeviceReader = Future<Map<String, String>?> Function();

class SubscriptionDeviceInfo {
  static const hosts = {
    'vip2027-1.pages.dev',
    'vip1.959621.xyz',
    'vip2-x3w.pages.dev',
    'vip2.959621.xyz',
    'vip4-2jc.pages.dev',
    'vip4.959621.xyz',
    'vip-5.pages.dev',
    'vip5.959621.xyz',
    'vip7-aiz.pages.dev',
    'vip7.959621.xyz',
    'v-ip9.pages.dev',
    'vip9.959621.xyz',
  };
  static const _parameterNames = {'device_id', 'device_brand', 'device_model'};

  final bool isAndroid;
  final SubscriptionDeviceReader readDevice;

  const SubscriptionDeviceInfo({
    required this.isAndroid,
    required this.readDevice,
  });

  Future<String> forUrl(String source) async {
    final uri = Uri.tryParse(source);
    if (!isAndroid ||
        uri == null ||
        uri.scheme != 'https' ||
        !hosts.contains(uri.host.toLowerCase())) {
      return source;
    }
    try {
      final device = await readDevice();
      if (device == null || device['device_id'] == null) return source;
      final parameters = {
        for (final entry in uri.queryParametersAll.entries)
          if (!_parameterNames.contains(entry.key)) entry.key: entry.value,
        for (final entry in device.entries)
          if (_parameterNames.contains(entry.key)) entry.key: [entry.value],
      };
      return uri.replace(queryParameters: parameters).toString();
    } catch (_) {
      return source;
    }
  }
}
