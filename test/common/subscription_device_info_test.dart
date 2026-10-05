import 'package:fl_clash/common/subscription_device_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = '12345678-1234-4234-8234-123456789abc';
  final info = SubscriptionDeviceInfo(
    isAndroid: true,
    readDevice: () async => {
      'device_id': id,
      'device_brand': 'Xiaomi',
      'device_model': '23116PN5BC',
    },
  );

  test('all subscription aliases carry the same device metadata', () async {
    for (final host in SubscriptionDeviceInfo.hosts) {
      final result = Uri.parse(
        await info.forUrl('https://$host/sub?token=customer'),
      );
      expect(result.queryParameters['token'], 'customer');
      expect(result.queryParameters['device_id'], id);
      expect(result.queryParameters['device_brand'], 'Xiaomi');
      expect(result.queryParameters['device_model'], '23116PN5BC');
    }
  });

  test('device fields are replaced and other query values preserved', () async {
    final result = Uri.parse(
      await info.forUrl(
        'https://vip1.959621.xyz/sub?token=customer&extra=one&extra=two&device_id=old&device_model=old#section',
      ),
    );
    expect(result.queryParametersAll['extra'], ['one', 'two']);
    expect(result.queryParametersAll['device_id'], [id]);
    expect(result.queryParametersAll['device_model'], ['23116PN5BC']);
    expect(result.fragment, 'section');
  });

  test('other destinations never read or attach device information', () async {
    final scoped = SubscriptionDeviceInfo(
      isAndroid: true,
      readDevice: () async => fail('Must not read device information'),
    );
    for (final source in [
      'https://example.com/sub?token=customer',
      'https://vip1.959621.xyz.example.com/sub',
      'http://vip1.959621.xyz/sub',
    ]) {
      expect(await scoped.forUrl(source), source);
    }
  });

  test('desktop and native channel failures preserve the request', () async {
    const source = 'https://vip1.959621.xyz/sub?token=customer';
    final desktop = SubscriptionDeviceInfo(
      isAndroid: false,
      readDevice: () async => fail('Must not read Android device information'),
    );
    expect(await desktop.forUrl(source), source);
    final failing = SubscriptionDeviceInfo(
      isAndroid: true,
      readDevice: () async => throw Exception('Unavailable'),
    );
    expect(await failing.forUrl(source), source);
  });
}
