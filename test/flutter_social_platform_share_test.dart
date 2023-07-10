import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_social_platform_share');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await FlutterSocialPlatformSharePlugin.platformVersion, '42');
  });
}
