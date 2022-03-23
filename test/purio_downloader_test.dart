import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purio_downloader/purio_downloader.dart';

void main() {
  const MethodChannel channel = MethodChannel('purio_downloader');

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
    expect(await PurioDownloader.platformVersion, '42');
  });
}
